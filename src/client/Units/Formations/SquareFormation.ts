import { StarterGui, Workspace } from "@rbxts/services";
import Formation from "./Formation";
import Selectable from "../Selectable";
import Utils from "client/Utils";

export default class SquareFormation extends Formation {
	constructor() {
		super("NormalAction");

		this.circle.Middle.Transparency = 1;
	}

	GetCFramesInFormation(units: Set<Selectable>, mainCFrame: CFrame, spread: number): CFrame[] {
		const cframes = new Array<CFrame>();

		const unitsPerRow = math.ceil(math.sqrt(units.size()));

		for (let i = 0; i < units.size(); i++) {
			const row = math.floor(i / unitsPerRow);
			const rowPosition = math.pow(-1, i) * math.ceil((i - row * unitsPerRow) / 2);

			const offset = new CFrame(rowPosition * spread, 0, row * spread);
			const cframe = mainCFrame.mul(offset);

			const groundPositionResult = Utils.RaycastBottom(
				cframe.Position.add(new Vector3(0, 10, 0)),
				[Workspace.TerrainParts],
				Enum.RaycastFilterType.Include,
			);
			if (!groundPositionResult) continue;

			const orientation = cframe.ToOrientation();
			const finalCFrame = new CFrame(groundPositionResult.Position).mul(
				CFrame.Angles(orientation[0], orientation[1], orientation[2]),
			);

			cframes.push(finalCFrame);
		}

		return cframes;
	}
}
