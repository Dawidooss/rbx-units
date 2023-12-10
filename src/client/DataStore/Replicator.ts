import Network from "shared/Network";
import ReplicationQueue from "../../shared/ReplicationQueue";
import { Sedes } from "shared/Sedes";
import BitBuffer from "@rbxts/bitbuffer";
import { RunService } from "@rbxts/services";
import { Replicable } from "./Replicable";

export default class Replicator {
	private replicables: Replicable[] = [];
	public replicationEnabled = false;
	private connections: { [key: string]: [Sedes.Serializer<any>, (data: any) => void] } = {};

	private queue: ReplicationQueue[] = [];

	private static instance: Replicator;
	constructor() {
		Replicator.instance = this;

		Network.BindEvents({
			"chunked-data": (queue: string[]) => () => {
				if (!this.replicationEnabled) return;
				for (const data of queue) {
					const buffer = BitBuffer(data);
					const key = buffer.readString();

					this.connections[key][1](data);
				}
			},
		});

		RunService.RenderStepped.Connect(() => this.OnStep());
	}

	public async Replicate(queue: ReplicationQueue) {
		if (this.queue.size() > 0) {
			this.queue.push(queue);
		}

		const response = Network.InvokeServer("chunked-data", queue.Dump()) as string[];

		// TODO: handle response
	}

	public Connect<T extends {}>(key: string, deserializer: Sedes.Serializer<T>, callback: (data: T) => void) {
		this.connections[key] = [deserializer, callback];
	}

	private OnStep() {
		const replicationQueue = new ReplicationQueue();
		for (const replicable of this.replicables) {
			const action = replicable.actionsQueue.NextAction();
			if (!action) continue;

			const [key, method] = action;
			const result = method();
			if (!result) {
				replicable.actionsQueue.active = undefined;
				continue;
			}
			replicationQueue.Append(key, ...result);
		}

		this.Replicate(replicationQueue);
	}

	public AddReplicable(replicable: Replicable) {
		this.replicables.push(replicable);
	}

	public static Get() {
		return Replicator.instance || new Replicator();
	}
}
