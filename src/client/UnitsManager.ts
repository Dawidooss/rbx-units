import Network from "shared/Network";
import Unit, { UnitData } from "./Unit";
import { HttpService, Workspace } from "@rbxts/services";

const camera = Workspace.CurrentCamera!;

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

	public static SelectUnits(selectedUnits: Array<Unit>) {
		this.selectedUnits.forEach((unit) => {
			unit.Select(false);
		});
		selectedUnits.forEach((unit) => {
			unit?.Select(true);
		});
		this.selectedUnits = selectedUnits;
	}

	public static GetUnit(unitId: string) {
		return UnitsManager.units.get(unitId);
	}
}
