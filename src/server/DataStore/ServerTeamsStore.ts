import Squash from "@rbxts/squash";
import { SerializedTeamData, TeamData } from "types";
import ClientGameStore from "./GameStore";
import Replicator from "./Replicator";
import TeamsStore from "shared/DataStore/TeamStore";
import ServerGameStore from "./GameStore";

export default class ServerTeamsStore extends TeamsStore {
	public replicator: Replicator;

	constructor(gameStore: ServerGameStore) {
		super(gameStore);
		this.replicator = gameStore.replicator;

		this.replicator.Connect("team-added", (serializedTeamData: SerializedTeamData) => {
			const teamData = TeamsStore.DeserializeTeamData(serializedTeamData);
			this.AddTeam(teamData);
		});
	}
}
