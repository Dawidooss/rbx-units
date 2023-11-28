import Replicator from "./ServerReplicator";
import ServerGameStore from "./ServerGameStore";
import PlayersStore, { PlayerData } from "shared/DataStore/Stores/PlayersStoreBase";
import BitBuffer from "@rbxts/bitbuffer";
import ServerReplicator from "./ServerReplicator";
import ReplicationQueue from "shared/ReplicationQueue";

const replicator = ServerReplicator.Get();

export default class ServerPlayersStore extends PlayersStore {
	constructor(gameStore: ServerGameStore) {
		super(gameStore);
	}

	public Add(playerData: PlayerData, queue?: ReplicationQueue): PlayerData {
		super.Add(playerData);

		const queuePassed = !!queue;
		queue ||= new ReplicationQueue();
		queue.Add("player-added", (buffer: BitBuffer) => {
			this.Serialize(playerData, buffer);
		});

		if (!queuePassed) {
			replicator.ReplicateAll(queue);
		}

		return playerData;
	}

	public Remove(playerId: string, queue?: ReplicationQueue): void {
		super.Remove(playerId);

		const queuePassed = !!queue;
		queue ||= new ReplicationQueue();
		queue.Add("player-added", (buffer: BitBuffer) => {
			buffer.writeString(playerId);
		});

		if (!queuePassed) {
			replicator.ReplicateAll(queue);
		}
	}
}
