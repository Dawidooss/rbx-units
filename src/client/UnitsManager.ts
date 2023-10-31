import Network from "shared/Network";
import Unit, { UnitData } from "./Unit";
import { HttpService, Workspace } from "@rbxts/services";

export default class UnitsManager {
	public static units = new Map<string, Unit>();
	public static cache = new Instance("Folder", Workspace);

	public static selectedUnits = new Array<Unit>();

	public static Init() {
		UnitsManager.cache.Name = "UnitsCache";

		Network.BindFunctions({
			createUnit: (unitType, unitId, position) => UnitsManager.CreateUnit(unitType, unitId, position),
		});
	}

	public static GenerateUnitId(): string {
		return HttpService.GenerateGUID(false);
	}

	public static CreateUnit(unitId: string, unitType: string, position: Vector3) {
		const unit = new Unit(unitId, unitType, position);
		unit.model.Parent = UnitsManager.cache;

		this.units.set(unitId, unit);
	}
	public static RemoveUnit(unitId: string) {
		const unit = this.units.get(unitId);
		if (!unit) return;
		this.units.delete(unitId);

		unit.Destroy();
	}
	public static UpdateUnit(unitId: string, data: { [key: string]: any }) {}

	public static SelectUnitsAt(min: Vector3, max?: Vector3) {
		let selectedUnits = new Array<Unit>();

		if (max) {
			// select units at bounds
			UnitsManager.units.forEach((unit) => {
				if (
					unit.position.X >= min.X &&
					unit.position.X <= max.X &&
					unit.position.Y >= min.Y &&
					unit.position.Y <= max.Y &&
					unit.position.Z >= min.Z &&
					unit.position.Z <= max.Z
				) {
					selectedUnits.push(unit);
				}
			});
		} else {
			let closestUnit;
			let closestUnitDistance = math.huge;
			// select unit at position
			for (let [_, unit] of UnitsManager.units) {
				const distance = unit.position.sub(min).Magnitude;
				if (distance <= 2 && distance < closestUnitDistance) {
					closestUnit = unit;
					closestUnitDistance = distance;
				}
			}
			if (closestUnit) {
				selectedUnits.push(closestUnit);
			}
		}
	}
}
