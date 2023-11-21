import Squash from "@rbxts/squash";
import GameStore from "./GameStore";
import Store from "./Store";
import { SerializedTeamData, TeamData } from "types";

export default class TeamsStore extends Store {
	public name = script.Name;

	public teams = new Map<string, TeamData>();

	constructor(gameStore: GameStore) {
		super(gameStore);

		this.receiver.Connect("team-added", (serializedTeamData: SerializedTeamData) => {
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
