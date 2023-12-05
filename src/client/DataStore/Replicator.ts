import Network from "shared/Network";
import BitBuffer from "@rbxts/bitbuffer";
import ReplicationQueue from "../../shared/ReplicationQueue";

export default class Replicator {
	public replicationEnabled = false;
	private connections: { [key: string]: (buffer: BitBuffer) => void } = {};

	private static instance: Replicator;
	constructor() {
		Replicator.instance = this;

		Network.BindEvents({
			"chunked-data": (data: string) => {
				if (!this.replicationEnabled) return;
				ReplicationQueue.Divide(data, (key: string, buffer: BitBuffer) => {
					assert(this.connections[key], `Connection ${key} missing in ClientReplicator`);
					this.connections[key](buffer);
				});
			},
		});
	}

	public async Replicate(queue: ReplicationQueue): Promise<string> {
		const promise = new Promise<string>((resolve, reject) => {
			const response = Network.InvokeServer("chunked-data", queue.DumpString())[0] as string;
			resolve(response);
		});

		return promise;
	}

	public Connect(key: string, callback: (buffer: BitBuffer) => void) {
		this.connections[key] = callback;
	}

	public async FetchAll(): Promise<BitBuffer> {
		const promise = new Promise<BitBuffer>(async (resolve, reject) => {
			const queue = new ReplicationQueue();
			queue.Add("fetch-all", (buffer) => buffer);

			const data = await this.Replicate(queue);

			const buffer = BitBuffer(data);
			resolve(buffer);
		});

		return promise;
	}

	public static Get() {
		return Replicator.instance || new Replicator();
	}
}
