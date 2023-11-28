import Store from "../Store";
import BitBuffer from "@rbxts/bitbuffer";

export default class UnitsStore extends Store<UnitData> {
	public name = "UnitsStore";

	public Add(unitData: UnitData): UnitData {
		this.cache.set(unitData.id, unitData);
		return unitData;
	}

	public Serialize(unitData: UnitData, buffer?: BitBuffer): BitBuffer {
		buffer ||= BitBuffer();
		buffer.writeString(unitData.id);
		buffer.writeString(unitData.type);
		buffer.writeVector3(unitData.position);
		buffer.writeUInt32(unitData.playerId);
		for (const position of unitData.path) {
			buffer.writeString("+");
			buffer.writeVector3(position);
		}
		buffer.writeString("-");

		return buffer;
	}

	public Deserialize(buffer: BitBuffer): UnitData {
		let unitData = {} as UnitData;

		(unitData.id = buffer.readString()),
			(unitData.type = buffer.readString()),
			(unitData.position = buffer.readVector3()),
			(unitData.playerId = buffer.readUInt16()),
			(unitData.path = []);

		while (buffer.readString() === "+") {
			const position = buffer.readVector3();
			unitData.path.push(position);
		}

		return unitData;
	}
}

export type UnitData = {
	id: string;
	type: string;
	position: Vector3;
	playerId: number;
	path: Vector3[];
};
