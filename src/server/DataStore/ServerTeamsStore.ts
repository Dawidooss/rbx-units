import Replicator from "./ServerReplicator";
import TeamsStore, { SerializedTeamData, TeamData } from "shared/DataStore/Stores/TeamStore";
import ServerGameStore from "./ServerGameStore";

export default class ServerTeamsStore extends TeamsStore {
	public replicator: Replicator;

	constructor(gameStore: ServerGameStore) {
		super(gameStore);
		this.replicator = gameStore.replicator;
	}

	public AddTeam(teamData: TeamData): TeamData {
		super.AddTeam(teamData);
		this.replicator.ReplicateAll("team-created", this.Serialize(teamData));

		return teamData;
	}

	public RemoveTeam(teamId: string): void {
		super.RemoveTeam(teamId);
		this.replicator.ReplicateAll("team-removed", teamId);
	}
}
