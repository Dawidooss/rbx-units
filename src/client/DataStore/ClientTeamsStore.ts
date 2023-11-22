import ClientGameStore from "./ClientGameStore";
import Replicator from "./ClientReplicator";
import TeamsStore, { SerializedTeamData } from "shared/DataStore/Stores/TeamStore";
import { ServerResponse } from "types";

export default class ClientTeamsStore extends TeamsStore {
	public replicator: Replicator;

	constructor(gameStore: ClientGameStore) {
		super(gameStore);
		this.replicator = gameStore.replicator;

		this.replicator.Connect("team-added", (response: ServerResponse) => {
			const serializedTeamData = response.data as SerializedTeamData;
			const teamData = this.Deserialize(serializedTeamData);

			if (this.cache.get(teamData.id)) return;

			this.AddTeam(teamData);
		});

		this.replicator.Connect("team-removed", (response: ServerResponse) => {
			const serializedTeamId = response.data as string;
			const teamId = serializedTeamId;
			this.RemoveTeam(teamId);
		});
	}
}
