import ClientGameStore from "./ClientGameStore";
import Replicator from "./ClientReplicator";
import TeamsStore from "shared/DataStore/Stores/TeamStore";
import BitBuffer = require("@rbxts/bitbuffer");
import ClientReplicator from "./ClientReplicator";

const replicator = ClientReplicator.Get();

export default class ClientTeamsStore extends TeamsStore {
	constructor(gameStore: ClientGameStore) {
		super(gameStore);

		replicator.Connect("team-added", (buffer: BitBuffer) => {
			const teamData = this.Deserialize(buffer);

			if (this.cache.get(teamData.id)) return;

			this.Add(teamData);
		});

		replicator.Connect("team-removed", (buffer: BitBuffer) => {
			const teamId = buffer.readString();
			this.Remove(teamId);
		});
	}
}
