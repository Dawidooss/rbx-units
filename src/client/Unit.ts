export class UnitData {
	constructor() {}
}

export default class Unit {
	public unitId: string;
	public position: Vector2;

	constructor(unitId: string, position: Vector2) {
		this.unitId = unitId;
		this.position = position;
	}

	public Destroy() {}
}
