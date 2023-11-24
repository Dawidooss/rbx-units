import Network from "shared/Network";
import BitBuffer from "@rbxts/bitbuffer";

export default class ClientReplicator {
	private static instance: ClientReplicator;
	constructor() {
		ClientReplicator.instance = this;
	}

	public Replicate(key: string, serializedData: any) {
		const response = Network.InvokeServer(key, serializedData);

		return response;
	}

	public Connect(key: string, callback: (buffer: BitBuffer) => void) {
		Network.BindEvents({
			[key]: (response: ServerResponse) => {
				const bufferStringified = response.data as string;
				const buffer = BitBuffer(bufferStringified);
				callback(buffer);
			},
		});
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
