import Formation from "./Formation";

export default class Line extends Formation {
	constructor() {
		super("NormalAction");
	}

	GetCFramesInFormation(size: number, mainCFrame: CFrame, spread: number): CFrame[] {
		const cframes = new Array<CFrame>();

		for (let i = 0; i < size; i++) {
			const rowPosition = math.pow(-1, i) * math.ceil(i / 2);
			const offset = new CFrame(rowPosition * spread, 0, 0);
			const newCFrame = mainCFrame.mul(offset);

			cframes.push(newCFrame);
		}

		return cframes;
	}
}
