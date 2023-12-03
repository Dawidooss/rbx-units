import BitBuffer from "@rbxts/bitbuffer";
import Store from "../Store";
import bit from "shared/bit";
import GameStoreBase from "./GameStoreBase";

export default class TeamsStoreBase extends Store<TeamData> {
	public name = "TeamsStore";

	constructor(gameStore: GameStoreBase) {
		super(gameStore, 16);
	}

	public Serialize(teamData: TeamData, buffer?: BitBuffer): BitBuffer {
		buffer ||= BitBuffer();
		buffer.writeBits(...bit.ToBits(teamData.id, 4));
		buffer.writeString(teamData.name);
		buffer.writeColor3(teamData.color);

		return buffer;
	}

	public Deserialize(buffer: BitBuffer): TeamData {
		return {
			id: bit.FromBits(buffer.readBits(4)),
			name: buffer.readString(),
			color: buffer.readColor3(),
		};
	}
}

export type TeamData = {
	id: number;
	name: string;
	color: Color3;
};
