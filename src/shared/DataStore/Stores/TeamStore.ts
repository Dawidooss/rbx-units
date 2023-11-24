import BitBuffer from "@rbxts/bitbuffer";
import Store from "../Store";

export default class TeamsStore extends Store<TeamData> {
	public name = "TeamsStore";

	public Add(teamData: TeamData): TeamData {
		const teamId = teamData.id;
		this.cache.set(teamId, teamData);
		return teamData;
	}

	public Serialize(teamData: TeamData, buffer?: BitBuffer): BitBuffer {
		buffer ||= BitBuffer();
		buffer.writeString(teamData.id);
		buffer.writeString(teamData.name);
		buffer.writeColor3(teamData.color);

		return buffer;
	}

	public Deserialize(buffer: BitBuffer): TeamData {
		return {
			id: buffer.readString(),
			name: buffer.readString(),
			color: buffer.readColor3(),
		};
	}
}

export type TeamData = {
	name: string;
	id: string;
	color: Color3;
};
