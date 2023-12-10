import Store from "../Store";
import { Sedes } from "shared/Sedes";

export default class UnitsStoreBase extends Store<UnitData> {
	public name = "UnitsStore";

	constructor() {
		const serializer = new Sedes.Serializer<UnitData>([
			["id", Sedes.ToUnsigned(12)],
			["position", UnitsStoreBase.SedesPosition],
			["path", Sedes.ToArray(UnitsStoreBase.SedesPosition)],
			["health", Sedes.ToUnsigned(7)],
			["playerId", Sedes.ToUnsigned(40)],
			["name", Sedes.ToString()],
		]);
		super(serializer, 128);
	}

	public static SedesPosition: Sedes.Method<Vector3> = {
		Ser: (data, buffer) => {
			print(data);
			buffer.writeUnsigned(10, math.floor(data.X));
			buffer.writeUnsigned(10, math.floor(data.Z));
			return buffer;
		},
		Des: (buffer) => {
			return new Vector3(buffer.readUnsigned(10), 10, buffer.readUnsigned(10));
		},
	};

	// public SerializePosition(position: Vector3, buffer: BitBuffer) {
	// 	buffer.writeBits(...bit.ToBits(math.floor(position.X), 10));
	// 	buffer.writeBits(...bit.ToBits(math.floor(position.Z), 10));
	// }
}

export type UnitDataType = {
	id: number;
	name: string;
	position: Vector3;
	playerId: number;
	path: Vector3[];
	health: number;
};

export class UnitData implements UnitDataType {
	public id: number;
	public name: string;
	public position: Vector3;
	public playerId: number;
	public path: Vector3[];
	public health: number;

	constructor(data: UnitDataType) {
		this.id = data.id;
		this.name = data.name;
		this.position = data.position;
		this.playerId = data.playerId;
		this.path = data.path;
		this.health = data.health;
	}
}
