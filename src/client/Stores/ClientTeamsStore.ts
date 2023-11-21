import Squash from "@rbxts/squash";
import { SerializedTeamData, TeamData } from "types";
import ClientGameStore from "./GameStore";
import Replicator from "./Replicator";
import TeamsStore from "shared/DataStore/TeamStore";

export default class ClientTeamsStore extends TeamsStore {
	public replicator: Replicator;

	constructor(gameStore: ClientGameStore) {
		super(gameStore);
		this.replicator = gameStore.replicator;

		this.replicator.Connect("team-added", (serializedTeamData: SerializedTeamData) => {
			const teamData = TeamsStore.DeserializeTeamData(serializedTeamData);
			this.AddTeam(teamData);
		});
	}
}
