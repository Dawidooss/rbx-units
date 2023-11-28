import Network from "shared/Network";
import BitBuffer from "@rbxts/bitbuffer";
import ReplicationQueue from "../../shared/ReplicationQueue";

export default class ClientReplicator {
	public replicationEnabled = false;
	private connections: { [key: string]: (buffer: BitBuffer) => void } = {};

	private static instance: ClientReplicator;
	constructor() {
		ClientReplicator.instance = this;

		Network.BindEvents({
			"chunked-data": (response: ServerResponse) => {
				if (!this.replicationEnabled) return;

				const data = response.data as string;
				if (!data) return;

				ReplicationQueue.Divide(data, (key: string, buffer: BitBuffer) => {
					print(key);
					assert(this.connections[key], `Connection ${key} missing in ClientReplicator`);
					this.connections[key](buffer);
				});
			},
		});
	}

	public async Replicate(queue: ReplicationQueue): Promise<ServerResponse> {
		const promise = new Promise<ServerResponse>((resolve, reject) => {
			const response = Network.InvokeServer("chunked-data", queue.DumpString())[0] as ServerResponse;
			print(response);
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
			queue.Add("fetch-all");

			const response = await this.Replicate(queue);

			if (response.error || !response.data) {
				// CRASH GAME!?!? TODO
				reject();
				return;
			}

			const buffer = BitBuffer(response.data);
			resolve(buffer);
		});

		return promise;
	}

	public static Get() {
		return ClientReplicator.instance || new ClientReplicator();
	}
}
