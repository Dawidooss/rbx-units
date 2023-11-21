import Squash from "@rbxts/squash";
import GameStore from "./GameStore";
import { SerializedTeamData, TeamData } from "types";
import TeamsStore from "shared/TeamStore";
import Replicator from "./Replicator";

export default class ClientTeamsStore extends TeamsStore {
	public gameStore: GameStore;
	public replicator: Replicator;

	public teams = new Map<string, TeamData>();

	constructor(gameStore: GameStore) {
		super();

		this.gameStore = gameStore;
		this.replicator = gameStore.replicator;

		this.replicator.Connect("team-added", (serializedTeamData: SerializedTeamData) => {
			const teamData = TeamsStore.DeserializeTeamData(serializedTeamData);
			this.AddTeam(teamData);
		});
	}

	public AddTeam(teamData: TeamData) {
		const teamId = teamData.id;
		if (this.teams.has(teamId)) {
			this.DataMissmatch();
			return;
		}

		this.teams.set(teamData.id, teamData);
	}

	public DataMissmatch() {
		this.replicator.FetchAll();
	}

	public OverrideData(serializedTeamDatas: SerializedTeamData[]) {
		this.teams.clear();

		let teamDatas: TeamData[] = [];
		for (const serializedTeamData of serializedTeamDatas) {
			const teamData = TeamsStore.DeserializeTeamData(serializedTeamData);
			this.AddTeam(teamData);
		}
	}

	public static SerializeTeamData(teamData: TeamData): SerializedTeamData {
		return {
			name: Squash.string.ser(teamData.name),
			id: Squash.string.ser(teamData.id),
			color: Squash.Color3.ser(teamData.color),
		};
	}

	public static DeserializeTeamData(serializedTeamData: SerializedTeamData): TeamData {
		return {
			name: Squash.string.des(serializedTeamData.name),
			id: Squash.string.des(serializedTeamData.id),
			color: Squash.Color3.des(serializedTeamData.color),
		};
	}
}
