import Network from "shared/Network";
import BitBuffer from "@rbxts/bitbuffer";
import ReplicationQueue from "../../shared/ReplicationQueue";

export default class ClientReplicator {
	private connections: { [key: string]: (buffer: BitBuffer) => void } = {};

	private static instance: ClientReplicator;
	constructor() {
		ClientReplicator.instance = this;

		Network.BindEvents({
			"chunked-data": (response: ServerResponse) => {
				const data = response.data as string;
				if (!data) return;

				ReplicationQueue.Divide(data, (key: string, buffer: BitBuffer) => {
					assert(this.connections[key], `Connection ${key} missing in ClientReplicator`);

					this.connections[key](buffer);
				});
			},
		});
	}

	public async Replicate(key: string, queue: ReplicationQueue): Promise<any[]> {
		const promise = new Promise<any[]>((resolve, reject) => {
			const response = Network.InvokeServer(key, queue.DumpString());
			resolve(response);
		});

		return promise;
	}

	public Connect(key: string, callback: (buffer: BitBuffer) => void) {
		this.connections[key] = callback;
	}

	public FetchAll(): BitBuffer | undefined {
		let response = Network.InvokeServer("fetch-all")[0] as ServerResponse;
		if (!response) return;

		const bufferStringified = response.data as string;
		if (response.error || !bufferStringified) {
			// TODO notify error
			return;
		}

		const buffer = BitBuffer(bufferStringified);
		return buffer;
	}

	public static Get() {
		return ClientReplicator.instance || new ClientReplicator();
	}
}
