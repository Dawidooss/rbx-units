import bit from "shared/bit";
import Store from "../Store";
import BitBuffer from "@rbxts/bitbuffer";
import GameStoreBase from "./GameStoreBase";

export default class UnitsStoreBase extends Store<UnitData> {
	public name = "UnitsStore";

	constructor(gameStore: GameStoreBase) {
		super(gameStore, 4096);
	}

	public SerializePath(path: Vector3[], buffer: BitBuffer) {
		for (const position of path) {
			buffer.writeBits(1);
			buffer.writeBits(...bit.ToBits(math.floor(position.X), 10));
			buffer.writeBits(...bit.ToBits(math.floor(position.Z), 10));
		}
		buffer.writeBits(0);
	}

	public DeserializePath(buffer: BitBuffer): Vector3[] {
		let path = [];
		while (buffer.readBits(1)[0] === 1) {
			const position = new Vector3(
				bit.FromBits(buffer.readBits(10)),
				10, // TODO: heightmap
				bit.FromBits(buffer.readBits(10)),
			);
			path.push(position);
		}
		return path;
	}

	public Serialize(unitData: UnitData, buffer?: BitBuffer): BitBuffer {
		buffer ||= BitBuffer();
		buffer.writeBits(...bit.ToBits(unitData.id, 12));
		buffer.writeBits(...bit.ToBits(math.floor(unitData.position.X), 10));
		buffer.writeBits(...bit.ToBits(math.floor(unitData.position.Z), 10));
		this.SerializePath(unitData.path, buffer);
		buffer.writeBits(...bit.ToBits(unitData.health, 7));
		buffer.writeString(tostring(unitData.playerId));
		buffer.writeString(unitData.name);

		return buffer;
	}

	public Deserialize(buffer: BitBuffer): UnitData {
		const id = bit.FromBits(buffer.readBits(12));
		const position = new Vector3(
			bit.FromBits(buffer.readBits(10)),
			10, // TODO: heightmap
			bit.FromBits(buffer.readBits(10)),
		);
		const path = this.DeserializePath(buffer);
		const health = bit.FromBits(buffer.readBits(7));
		const playerId = tonumber(buffer.readString())!;
		const name = buffer.readString();

		let unitData = new UnitData(id, name, position, playerId, path, health);

		return unitData;
	}
}

export class UnitData {
	public id: number;
	public name: string;
	public position: Vector3;
	public playerId: number;
	public path: Vector3[];
	public health: number;
	constructor(id: number, name: string, position: Vector3, playerId: number, path?: Vector3[], health?: number) {
		this.id = id;
		this.name = name;
		this.position = position;
		this.playerId = playerId;

		this.health = health || 100;
		this.path = path || [];
	}
}
