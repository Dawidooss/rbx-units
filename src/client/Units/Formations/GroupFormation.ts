import { ReplicatedFirst, Workspace } from "@rbxts/services";
import Unit from "../Unit";
import Formation from "./Formation";
import Utils from "client/Utils";
import UnitsGroup from "../UnitsGroup";

const camera = Workspace.CurrentCamera!;

export default class CircleFormation extends Formation {
	public group: UnitsGroup;

	constructor(group: UnitsGroup) {
		super("CircularAction");

		this.group = group;
	}

	public GetCFramesInFormation(units: Set<Unit>, mainCFrame: CFrame, spread: number): Map<Unit, CFrame> {
		const cframes = new Array<CFrame>();

		return this.group.offsets;
	}

	public VisualisePositions(amountOfUnits: number, cframe: CFrame, spread: number): void {
		if (this.destroyed) return;
	}

	public GetSpreadLimits(amountOfUnits: number): [number, number] {
		return [0, 0];
	}
}
