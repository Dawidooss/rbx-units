import PlayersStoreBase, { PlayerData } from "shared/DataStore/Stores/PlayersStoreBase";
import BitBuffer from "@rbxts/bitbuffer";
import ServerReplicator from "./Replicator";
import ReplicationQueue from "shared/ReplicationQueue";

const replicator = ServerReplicator.Get();

export default class PlayersStore extends PlayersStoreBase {
	private static instance: PlayersStore;

	constructor() {
		super();
		PlayersStore.instance = this;
	}

	public Add(playerData: PlayerData, queue?: ReplicationQueue): PlayerData {
		super.Add(playerData);

		const queuePassed = !!queue;
		queue ||= new ReplicationQueue();
		queue.Add("player-added", (buffer: BitBuffer) => {
			return this.serializer.Ser(playerData, buffer);
		});

		if (!queuePassed) {
			replicator.ReplicateAll(queue);
		}

		return playerData;
	}

	public Remove(playerId: number, queue?: ReplicationQueue): void {
		super.Remove(playerId);

		const queuePassed = !!queue;
		queue ||= new ReplicationQueue();
		queue.Add("player-removed", (buffer: BitBuffer) => {
			buffer.writeString(tostring(playerId));
			return buffer;
		});

		if (!queuePassed) {
			replicator.ReplicateAll(queue);
		}
	}

	public static Get() {
		return PlayersStore.instance || new PlayersStore();
	}
}
