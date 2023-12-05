import Network from "shared/Network";
import BitBuffer from "@rbxts/bitbuffer";
import ReplicationQueue from "shared/ReplicationQueue";

export default class Replicator {
	private connections: {
		[key: string]: (
			player: Player,
			buffer: BitBuffer,
			responseQueue: ReplicationQueue,
			replicationQueue: ReplicationQueue,
		) => void;
	} = {};

	private static instance: Replicator;
	constructor() {
		Replicator.instance = this;

		Network.BindFunctions({
			"chunked-data": (player: Player, data: string) => {
				const responseQueue = new ReplicationQueue();
				const replicationQueue = new ReplicationQueue();
				ReplicationQueue.Divide(data, (key: string, buffer: BitBuffer) => {
					assert(this.connections[key], `Connection ${key} missing in ServerReplicator`);
					this.connections[key](player, buffer, responseQueue, replicationQueue);
				});

				if (replicationQueue.DumpString() !== "") {
					// is not empty
					this.ReplicateExcept(player, replicationQueue);
				}

				return [responseQueue.DumpString()];
			},
		});
	}

	public Replicate(player: Player, queue: ReplicationQueue) {
		Network.FireClient(player, "chunked-data", queue.DumpString());
	}

	public ReplicateExcept(player: Player, queue: ReplicationQueue) {
		Network.FireOtherClients(player, "chunked-data", queue.DumpString());
	}

	public ReplicateAll(queue: ReplicationQueue) {
		Network.FireAllClients("chunked-data", queue.DumpString());
	}

	public Connect(
		key: string,
		callback: (player: Player, buffer: BitBuffer, replicationQueue: ReplicationQueue) => string | void,
	) {
		this.connections[key] = callback;
	}

	public static Get() {
		return Replicator.instance || new Replicator();
	}
}
