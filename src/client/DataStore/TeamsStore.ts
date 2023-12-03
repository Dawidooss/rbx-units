import ClientGameStore from "./GameStore";
import BitBuffer = require("@rbxts/bitbuffer");
import Replicator from "./Replicator";
import TeamsStoreBase from "shared/DataStore/Stores/TeamStoreBase";
import GameStore from "./GameStore";
import bit from "shared/bit";

const replicator = Replicator.Get();

export default class TeamsStore extends TeamsStoreBase {
	constructor(gameStore: GameStore) {
		super(gameStore);

		replicator.Connect("team-added", (buffer: BitBuffer) => {
			const teamData = this.Deserialize(buffer);

			if (this.cache.get(teamData.id)) return;

			this.Add(teamData);
		});

		replicator.Connect("team-removed", (buffer: BitBuffer) => {
			const teamId = bit.FromBits(buffer.readBits(4));
			this.Remove(teamId);
		});
	}
}
