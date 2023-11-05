import { ReplicatedFirst, Workspace } from "@rbxts/services";
import Unit from "../Unit";
import Formation from "./Formation";

const camera = Workspace.CurrentCamera!;

export default class Circle extends Formation {
	constructor() {
		super("CircularAction");
	}

	public GetCFramesInFormation(size: number, mainCFrame: CFrame, spread: number): CFrame[] {
		const cframes = new Array<CFrame>();

		for (let i = 0; i < size; i++) {
			const row = math.floor(i / 10);
			const rowPosition = math.pow(-1, i) * math.ceil((i - row * 10) / 2);

			const offset = new CFrame(rowPosition * spread, 0, row * spread);
			const cframe = mainCFrame.mul(offset);

			cframes.push(cframe);
		}

		return cframes;
	}

	public VisualisePositions(units: Unit[], cframe: CFrame, spread: number): void {
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
		const cframes = this.GetCFramesInFormation(units.size(), mainCFrame, spread);

		this.circle.Positions.ClearAllChildren();
		cframes.forEach((cframe, i) => {
			if (i === 0) return;
			const positionPart = this.circle.Middle.Clone() as BasePart;
			positionPart.PivotTo(cframe);
			positionPart.Parent = this.circle.Positions;
		});
	}
}
