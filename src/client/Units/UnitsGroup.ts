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
		for (let unit of this.units) {
			unit.Select(selectionType);
		}
		this.selectionType = selectionType;
	}

	public static FormGroup(selectables: Set<Selectable>) {
		const units = new Set<Unit>();

		for (const unit of selectables) {
			if (unit instanceof Unit && !unit.group) {
				units.add(unit);
			}
		}

		if (units.size() === 0) return;

		return new UnitsGroup(units);
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

	public Move(cframe: CFrame): void {
		for (const unit of this.units) {
			const offset = this.offsets.get(unit);
			if (!offset) continue;
			unit.Move(cframe.mul(offset));
		}
	}
}
