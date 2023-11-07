import { ReplicatedFirst, Workspace } from "@rbxts/services";
import UnitsAction from "../UnitsAction";
import Unit from "../Unit";
import Movement from "client/Movement";

const camera = Workspace.CurrentCamera!;

export default abstract class Formation {
	protected circle: ActionCircle;
	protected arrow: ActionCircle["Arrow"];
	protected destroyed = false;

	constructor(actionType: string) {
		this.circle = ReplicatedFirst.WaitForChild(actionType)!.Clone() as ActionCircle;
		this.arrow = this.circle.Arrow;
	}

	public static abstract GetCFramesInFormation(
		units: Set<Unit>,
		mainCFrame: CFrame,
		spread: number,
	): Map<Unit, CFrame>;

	public VisualisePositions(amountOfUnits: number, cframe: CFrame, spread: number) {
		if (this.destroyed) return;

		this.circle.PivotTo(cframe);

		this.circle.Parent = camera;
		this.arrow.Parent = spread < 2 ? undefined : this.circle;

		const arrowMiddle = cframe.mul(new CFrame(0, 0, -spread / 2)).Position;
		this.arrow.PivotTo(new CFrame(arrowMiddle, cframe.Position));
		this.arrow.Length.Size = new Vector3(spread, this.arrow.Length.Size.Y, this.arrow.Length.Size.Z);

		this.arrow.Length.Attachment.CFrame = new CFrame(spread / 2, 0, 0);
		this.arrow.Left.PivotTo(this.arrow.Length.Attachment.WorldCFrame);
		this.arrow.Right.PivotTo(this.arrow.Length.Attachment.WorldCFrame);

		// visualise positions
		const mainCFrame = this.circle.GetPivot();
		const cframes = this.GetCFramesInFormation(amountOfUnits, mainCFrame, spread);

		this.circle.Positions.ClearAllChildren();
		cframes.forEach((cframe, i) => {
			if (i === 0) return;
			const positionPart = this.circle.Middle.Clone() as BasePart;
			positionPart.PivotTo(cframe);
			positionPart.Parent = this.circle.Positions;
		});
	}

	public GetSpreadLimits(amountOfUnits: number): [number, number] {
		return [4, 12];
	}

	public Hide() {
		this.circle.Parent = undefined;
	}

	public Destroy() {
		this.destroyed = true;
		this.circle.Destroy();
	}
}
