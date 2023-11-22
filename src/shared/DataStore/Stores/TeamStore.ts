import Store from "../Store";

export default class TeamsStore extends Store<TeamData, SerializedTeamData> {
	public name = "TeamsStore";
	public cache = new Map<string, TeamData>();

	public AddTeam(teamData: TeamData): TeamData {
		const teamId = teamData.id;
		this.cache.set(teamId, teamData);
		return teamData;
	}

	public RemoveTeam(teamId: string) {
		this.cache.delete(teamId);
	}

	public OverrideData(serializedTeamDatas: SerializedTeamData[]) {
		this.cache.clear();

		for (const serializedTeamData of serializedTeamDatas) {
			const teamData = this.Deserialize(serializedTeamData);
			this.AddTeam(teamData);
		}
	}

	public Serialize(teamData: TeamData): SerializedTeamData {
		return teamData;
		// return {
		// 	name: Squash.string.ser(teamData.name),
		// 	id: Squash.string.ser(teamData.id),
		// 	color: Squash.Color3.ser(teamData.color),
		// };
	}

	public Deserialize(serializedTeamData: SerializedTeamData): TeamData {
		return serializedTeamData;
		// return {
		// 	name: Squash.string.des(serializedTeamData.name),
		// 	id: Squash.string.des(serializedTeamData.id),
		// 	color: Squash.Color3.des(serializedTeamData.color),
		// };
	}
}

export type TeamData = {
	name: string;
	id: string;
	color: Color3;
};

export type SerializedTeamData = {
	name: string;
	id: string;
	color: Color3;
};
