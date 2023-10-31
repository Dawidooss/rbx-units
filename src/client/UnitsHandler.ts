import Network from "shared/Network";
import Unit, { UnitData } from "./Unit";

export default class UnitsManager {
	public static units = new Map<string, Unit>();

	public static Init() {
		Network.BindFunctions({
			createUnit: (unitType, unitId, position) => UnitsManager.CreateUnit(unitType, unitId, position),
		});
	}

	public static CreateUnit(unitType: string, unitId: string, position: Vector2) {
		const unit = new Unit(unitId, position);
		this.units.set(unitId, unit);
	}
	public static RemoveUnit(unitId: string) {
		const unit = this.units.get(unitId);
		if (!unit) return;
		this.units.delete(unitId);

		unit.Destroy();
	}
	public static UpdateUnit(unitId: string, data: { [key: string]: any }) {}
}
