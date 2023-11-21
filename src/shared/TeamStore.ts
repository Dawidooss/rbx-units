import Squash from "@rbxts/squash";
import { SerializedTeamData, TeamData } from "types";
import Store from "./Store";

export default class TeamsStore extends Store {
	public name = script.Name;

	public teams = new Map<string, TeamData>();

	public AddTeam(teamData: TeamData) {
		const teamId = teamData.id;
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