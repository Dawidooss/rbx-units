import { ReplicatedFirst, Workspace } from "@rbxts/services";
import Unit from "../Unit";
import Formation from "./Formation";
import Utils from "client/Utils";

const camera = Workspace.CurrentCamera!;

export default class Circle extends Formation {
	constructor() {
		super("CircularAction");
	}

	public GetCFramesInFormation(size: number, mainCFrame: CFrame, spread: number): CFrame[] {
		const cframes = new Array<CFrame>();

		for (let i = 0; i < size; i++) {
			const rotation = (360 / size) * i;
			const cframe = mainCFrame
				.mul(CFrame.Angles(0, math.rad(rotation) + math.pi, 0))
				.mul(new CFrame(0, 0, -spread));

			cframes.push(cframe);
		}

		return cframes;
	}

	public VisualisePositions(units: Unit[], cframe: CFrame, spread: number): void {
		if (this.destroyed) return;

		this.circle.PivotTo(new CFrame(cframe.Position));
		this.circle.Parent = camera;

		this.circle.Middle.Size = new Vector3(this.circle.Middle.Size.X, spread * 2, spread * 2);
	}

	public GetSpreadLimits(unitsSize: number): [number, number] {
		let positionsUsed = 5;
		let minSpread = 4;
		while (positionsUsed < unitsSize) {
			minSpread += 2;
			positionsUsed = math.floor((3 / 2) * minSpread);
		}
		return [minSpread, math.max(minSpread, 20)];
	}
}
