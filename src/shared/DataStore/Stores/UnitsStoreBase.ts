import Store from "../Store";
import BitBuffer from "@rbxts/bitbuffer";

export default class UnitsStoreBase extends Store<UnitData> {
	public name = "UnitsStore";

	public Add(unitData: UnitData): UnitData {
		this.cache.set(unitData.id, unitData);
		return unitData;
	}

	public SerializePath(path: Vector3[], buffer: BitBuffer) {
		for (const position of path) {
			buffer.writeString("+");
			buffer.writeVector3(position);
		}
		buffer.writeString("-");
	}

	public DeserializePath(buffer: BitBuffer): Vector3[] {
		let path = [];
		while (buffer.readString() === "+") {
			const position = buffer.readVector3();
			path.push(position);
		}
		return path;
	}

	public Serialize(unitData: UnitData, buffer?: BitBuffer): BitBuffer {
		buffer ||= BitBuffer();
		buffer.writeString(unitData.id);
		buffer.writeString(unitData.name);
		buffer.writeVector3(unitData.position);
		buffer.writeString(tostring(unitData.playerId));
		this.SerializePath(unitData.path, buffer);

		return buffer;
	}

	public Deserialize(buffer: BitBuffer): UnitData {
		const id = buffer.readString();
		const name = buffer.readString();
		const position = buffer.readVector3();
		const playerId = tonumber(buffer.readString())!;
		const path = this.DeserializePath(buffer);

		let unitData = new UnitData(id, name, position, playerId, path);

		return unitData;
	}
}

export class UnitData {
	public id: string;
	public name: string;
	public position: Vector3;
	public playerId: number;
	public path: Vector3[] = [];
	constructor(id: string, name: string, position: Vector3, playerId: number, path?: Vector3[]) {
		this.id = id;
		this.name = name;
		this.position = position;
		this.playerId = playerId;

		if (path) {
			this.path = path;
		}
	}
}
