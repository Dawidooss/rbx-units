import ClientGameStore from "./ClientGameStore";
import Replicator from "./ClientReplicator";
import PlayersStore, { SerializedPlayerData } from "shared/DataStore/Stores/PlayersStore";
import { ServerResponse } from "types";

export default class ClientPlayersStore extends PlayersStore {
	public replicator: Replicator;

	constructor(gameStore: ClientGameStore) {
		super(gameStore);
		this.replicator = gameStore.replicator;

		this.replicator.Connect("player-added", (response: ServerResponse) => {
			const serializedPlayerData = response.data as SerializedPlayerData;
			const playerData = this.Deserialize(serializedPlayerData);

			this.AddPlayer(playerData);
		});

		this.replicator.Connect("player-removed", (response: ServerResponse) => {
			const serializedPlayerId = response.data as string;
			const playerId = serializedPlayerId;
			this.RemovePlayer(playerId);
		});
	}
}
