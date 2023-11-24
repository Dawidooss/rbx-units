import Replicator from "./ServerReplicator";
import ServerGameStore from "./ServerGameStore";
import PlayersStore, { PlayerData } from "shared/DataStore/Stores/PlayersStore";
import BitBuffer from "@rbxts/bitbuffer";
import ServerReplicator from "./ServerReplicator";

const replicator = ServerReplicator.Get();

export default class ServerPlayersStore extends PlayersStore {
	constructor(gameStore: ServerGameStore) {
		super(gameStore);
	}

	public Add(playerData: PlayerData): PlayerData {
		super.Add(playerData);
		replicator.ReplicateAll("player-added", this.Serialize(playerData));

		return playerData;
	}

	public Remove(playerId: string): void {
		super.Remove(playerId);

		const buffer = BitBuffer();
		buffer.writeUInt32(tonumber(playerId) || 0);

		replicator.ReplicateAll("player-removed", buffer);
	}
}
