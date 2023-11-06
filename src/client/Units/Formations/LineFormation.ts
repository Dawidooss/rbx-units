import { StarterGui } from "@rbxts/services";
import Formation from "./Formation";

export default class LineFormation extends Formation {
	constructor() {
		super("NormalAction");
	}

	GetCFramesInFormation(unitsAmount: number, mainCFrame: CFrame, spread: number): CFrame[] {
		const cframes = new Array<CFrame>();

		const unitsPerRow = 15;

		for (let i = 0; i < unitsAmount; i++) {
			const row = math.floor(i / unitsPerRow);
			const rowPosition = math.pow(-1, i) * math.ceil((i - row * unitsPerRow) / 2);

			const offset = new CFrame(rowPosition * spread, 0, row * spread);
			const cframe = mainCFrame.mul(offset);

			cframes.push(cframe);
		}

		return cframes;
	}
}
