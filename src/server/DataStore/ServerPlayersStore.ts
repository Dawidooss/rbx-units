import Replicator from "./ServerReplicator";
import { TeamData } from "shared/DataStore/Stores/TeamStore";
import ServerGameStore from "./ServerGameStore";
import PlayersStore, { PlayerData } from "shared/DataStore/Stores/PlayersStore";

export default class ServerPlayersStore extends PlayersStore {
	public replicator: Replicator;

	constructor(gameStore: ServerGameStore) {
		super(gameStore);
		this.replicator = gameStore.replicator;
	}

	public AddPlayer(playerData: PlayerData): PlayerData {
		super.AddPlayer(playerData);
		this.replicator.ReplicateAll("player-added", this.Serialize(playerData));

		return playerData;
	}

	public RemovePlayer(playerId: string): void {
		super.RemovePlayer(playerId);
		this.replicator.ReplicateAll("player-removed", playerId);
	}
}
