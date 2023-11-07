import { RunService } from "@rbxts/services";
import Selectable, { SelectionType } from "./Selectable";
import Selection from "./Selection";
import Unit from "./Unit";

export default class UnitsGroup extends Selectable {
	public units = new Set<Unit>();
	public offsets = new Map<Unit, CFrame>();

	constructor(units: Set<Unit>) {
		super();
		this.units = units;

		const position = this.GetPosition();

		for (const unit of units) {
			const offset = unit.model.GetPivot().mul(new CFrame(position).Inverse());
			this.offsets.set(unit, offset);
		}
	}

	public Select(selectionType: SelectionType): void {
		for (const unit of this.units) {
			unit.Select(selectionType);
		}
	}

	public static FormGroup(selectables: Set<Selectable>) {
		const units = new Set<Unit>();

		for (const unit of selectables) {
			if (unit instanceof Unit && !unit.group) {
				units.add(unit);
			}
		}

		if (units.size() === 0) return;

		const group = new UnitsGroup(units);

		const groupSet = new Set<UnitsGroup>();
		groupSet.add(group);

		Selection.ClearSelectedUnits();
		Selection.SelectUnits(groupSet);
	}

	public GetPosition(): Vector3 {
		let position = new Vector3();
		for (const unit of this.units) {
			unit.group = this;

			position = position.add(unit.model.GetPivot().Position);
		}
		position = position.div(this.units.size());
		return position;
	}
}
