import BitBuffer from "@rbxts/bitbuffer";
import ClientGameStore from "./ClientGameStore";
import PlayersStore from "shared/DataStore/Stores/PlayersStore";
import ClientReplicator from "./ClientReplicator";

const replicator = ClientReplicator.Get();

export default class ClientPlayersStore extends PlayersStore {
	constructor(gameStore: ClientGameStore) {
		super(gameStore);

		replicator.Connect("player-added", (buffer: BitBuffer) => {
			print(buffer.dumpString());
			const playerData = this.Deserialize(buffer);

			this.Add(playerData);
		});

		replicator.Connect("player-removed", (buffer: BitBuffer) => {
			const playerId = buffer.readUInt32();
			this.Remove(tostring(playerId));
		});
	}
}
