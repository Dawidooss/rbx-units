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

		buffer.writeVector3(unitData.targetPosition);
		buffer.writeUInt32(unitData.movementStartTick);
		buffer.writeUInt32(unitData.movementEndTick);

		return buffer;
	}

	public Deserialize(buffer: BitBuffer): UnitData {
		return {
			id: buffer.readString(),
			type: buffer.readString(),
			position: buffer.readVector3(),
			playerId: buffer.readUInt16(),

			targetPosition: buffer.readVector3(),
			movementStartTick: buffer.readUInt16(),
			movementEndTick: buffer.readUInt16(),
		};
	}
}

export type UnitData = {
	id: string;
	type: string;
	position: Vector3;
	playerId: number;

	targetPosition: Vector3;
	movementStartTick: number;
	movementEndTick: number;
};
