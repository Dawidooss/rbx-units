import Formation from "./Formation";

export default class Normal implements Formation {
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
}
