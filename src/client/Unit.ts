import { ReplicatedFirst, Workspace } from "@rbxts/services";

export class UnitData {
	constructor() {}
}

export default class Unit {
	public unitId: string;
	public unitName: string;
	public model: UnitModel;

	public position: Vector3;

	constructor(unitId: string, unitName: string, position: Vector3) {
		this.unitId = unitId;
		this.position = position;
		this.unitName = unitName;

		this.model = ReplicatedFirst.Units[unitName].Clone();

		this.UpdatePosition();
	}

	public UpdatePosition() {
		this.model.PivotTo(new CFrame(this.position));
	}

	public Destroy() {}
}
