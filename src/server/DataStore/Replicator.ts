import Network from "shared/Network";
import BitBuffer from "@rbxts/bitbuffer";
import ReplicationQueue from "shared/ReplicationQueue";
import { Sedes } from "shared/Sedes";

export default class Replicator {
	private connections: {
		[key: string]: [
			Sedes.Serializer<any>,
			(player: Player, data: any, response: ReplicationQueue, replication: ReplicationQueue) => void,
		];
	} = {};

	private static instance: Replicator;
	constructor() {
		Replicator.instance = this;

		Network.BindFunctions({
			"chunked-data": (player: Player, queue: string[]) => {
				const response = new ReplicationQueue();
				const replication = new ReplicationQueue();
				for (const serializedData of queue) {
					const buffer = BitBuffer(serializedData);
					const key = buffer.readString();

					const data = this.connections[key][0].Des(buffer);

					this.connections[key][1](player, data, response, replication);
				}

				if (replication.queue.size() > 0) {
					this.ReplicateExcept(player, replication);
				}

				return response.Dump();
			},
		});
	}

	public Replicate(player: Player, queue: ReplicationQueue) {
		Network.FireClient(player, "chunked-data", queue.Dump());
	}

	public ReplicateExcept(player: Player, queue: ReplicationQueue) {
		Network.FireOtherClients(player, "chunked-data", queue.Dump());
	}

	public ReplicateAll(queue: ReplicationQueue) {
		Network.FireAllClients("chunked-data", queue.Dump());
	}

	public Connect<T extends {}>(
		key: string,
		deserializer: Sedes.Serializer<T>,
		callback: (player: Player, data: T, responseQueue: ReplicationQueue, replication: ReplicationQueue) => void,
	) {
		// TODO: add response to callbakc
		this.connections[key] = [deserializer, callback];
	}

	public static Get() {
		return Replicator.instance || new Replicator();
	}
}
