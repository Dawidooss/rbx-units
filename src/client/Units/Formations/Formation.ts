import { ReplicatedFirst, Workspace } from "@rbxts/services";
import Selectable from "../Selectable";
import Utils from "shared/Utils";

const camera = Workspace.CurrentCamera!;

export default abstract class Formation {
	protected circle: ActionCircle;
	protected arrow: ActionCircle["Arrow"];
	protected destroyed = false;

	constructor(actionType: string) {
		this.circle = ReplicatedFirst.WaitForChild(actionType)!.Clone() as ActionCircle;
		this.arrow = this.circle.Arrow;
	}

	public MatchUnitsToCFrames(units: Set<Selectable>, cframes: CFrame[], mainCFrame: CFrame): Map<Selectable, CFrame> {
		const matchedUnitsToCFrames = new Map<Selectable, CFrame>();

		let distancesArray = new Array<[Selectable, number, CFrame]>();
		for (const unit of units) {
			const pivotPosition = unit.GetPosition();
			for (const cframe of cframes) {
				const distance = pivotPosition.sub(cframe.Position).Magnitude;
				distancesArray.push([unit, distance, cframe]);
			}
		}
		distancesArray.sort((a, b) => {
			return a[1] < b[1];
		});

		const visitedUnits = new Set<Selectable>();
		const visitedCFrames = new Set<CFrame>();

		for (const [unit, , cframe] of distancesArray) {
			if (visitedUnits.has(unit) || visitedCFrames.has(cframe)) {
				continue;
			}
			matchedUnitsToCFrames.set(unit, cframe);
			visitedUnits.add(unit);
			visitedCFrames.add(cframe);
		}

		return matchedUnitsToCFrames;
	}

	public abstract GetCFramesInFormation(units: Set<Selectable>, mainCFrame: CFrame, spread: number): CFrame[];

	public VisualisePositions(units: Set<Selectable>, cframe: CFrame, spread: number) {
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
		const matchedCframes = this.GetCFramesInFormation(units, mainCFrame, spread);

		this.circle.Positions.ClearAllChildren();
		matchedCframes.forEach((cframe) => {
			const positionPart = this.circle.Middle.Clone() as BasePart;
			positionPart.Transparency = 0;

			const groundPositionResult = Utils.RaycastBottom(
				cframe.Position.add(new Vector3(0, 100, 0)),
				[Workspace.TerrainParts],
				Enum.RaycastFilterType.Include,
			);

			if (!groundPositionResult) return;

			positionPart.PivotTo(
				new CFrame(
					groundPositionResult.Position,
					groundPositionResult.Position.add(groundPositionResult.Normal),
				).mul(CFrame.Angles(math.pi / 2, 0, 0)),
			);
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
