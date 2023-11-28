import BitBuffer from "@rbxts/bitbuffer";
import ClientReplicator from "./Replicator";
import PlayersStoreBase from "shared/DataStore/Stores/PlayersStoreBase";
import GameStoreBase from "shared/DataStore/Stores/GameStoreBase";

const replicator = ClientReplicator.Get();

export default class PlayersStore extends PlayersStoreBase {
	constructor(gameStore: GameStoreBase) {
		super(gameStore);

		replicator.Connect("player-added", (buffer: BitBuffer) => {
			const playerData = this.Deserialize(buffer);

			this.Add(playerData);
		});

		replicator.Connect("player-removed", (buffer: BitBuffer) => {
			const playerId = buffer.readString();
			this.Remove(playerId);
		});
	}
}
