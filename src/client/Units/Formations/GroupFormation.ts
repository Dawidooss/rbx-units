import { ReplicatedFirst, Workspace } from "@rbxts/services";
import Unit from "../Unit";
import Formation from "./Formation";
import Utils from "client/Utils";
import UnitsGroup from "../UnitsGroup";
import Selectable from "../Selectable";

const camera = Workspace.CurrentCamera!;

export default class GroupFormation extends Formation {
	public group: UnitsGroup;

	constructor(group: UnitsGroup) {
		super("NormalAction");

		this.group = group;
	}

	public GetCFramesInFormation(units: Set<Selectable>, mainCFrame: CFrame, spread: number): CFrame[] {
		const cframes = new Array<CFrame>();

		for (const [unit, offset] of this.group.offsets) {
			cframes.push(mainCFrame.mul(offset));
		}

		return cframes;
	}

	public GetSpreadLimits(amountOfUnits: number): [number, number] {
		return [0, 0];
	}

	public MatchUnitsToCFrames(units: Set<Selectable>, cframes: CFrame[], mainCFrame: CFrame): Map<Selectable, CFrame> {
		const map = new Map<Selectable, CFrame>();

		for (const unit of units) {
			map.set(unit, mainCFrame);
		}

		return map;
	}
}
