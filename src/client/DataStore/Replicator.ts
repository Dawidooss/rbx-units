import Network from "shared/Network";
import ReplicationQueue from "../../shared/ReplicationQueue";
import { Sedes } from "shared/Sedes";
import BitBuffer from "@rbxts/bitbuffer";

export default class Replicator {
	public replicationEnabled = false;
	private connections: { [key: string]: [Sedes.Serializer<any>, (data: any) => void] } = {};

	private async ChunkedDataReceived(data: string) {
		// QueueDeserializer.Divide(data, (key: string, buffer: BitBuffer) => {
		// 	assert(this.connections[key], `Connection ${key} missing in ClientReplicator`);
		// 	const data = this.connections[key][0].Deserialize(buffer); // deserialize data
		// 	this.connections[key][1](data); // send deserialized data to callback
		// });
	}

	private static instance: Replicator;
	constructor() {
		Replicator.instance = this;

		Network.BindEvents({
			"chunked-data":
				(...queue: string[]) =>
				() => {
					if (!this.replicationEnabled) return;
					for (const data of queue) {
						const buffer = BitBuffer(data);
						const key = buffer.readString();

						this.connections[key][1](data);
					}
				},
		});
	}

	public async Replicate(queue: ReplicationQueue) {
		const response = Network.InvokeServer("chunked-data", queue.Dump());
		// TODO: handle response
	}

	public Connect<T extends {}>(key: string, deserializer: Sedes.Serializer<T>, callback: (data: T) => void) {
		this.connections[key] = [deserializer, callback];
	}

	public static Get() {
		return Replicator.instance || new Replicator();
	}
}
