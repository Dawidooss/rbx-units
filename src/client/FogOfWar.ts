export default class FogOfWar {
	private static instance: FogOfWar | undefined;
	public fogMap: FogMap;

	constructor() {
		this.fogMap = new FogMap();
		FogOfWar.instance = this;
	}

	public static get(): FogOfWar {
		return FogOfWar.instance || new FogOfWar();
	}

	public SetMap() {}

	public Render() {
		for (let [i, fogType] of this.fogMap.map) {
			const coords = this.fogMap.indexToCoords(i);
		}
	}
}

export enum FogType {
	Visible,
	SemiVisible,
	Hidden,
}

export class FogMap {
	public map: Map<number, FogType>;
	public width: number;

	constructor();
	constructor(width?: number, map?: Map<number, FogType>) {
		this.map = map || new Map();
		this.width = width || 0;
	}

	public getAtCoords(x: number, y: number): FogType | undefined {
		const i = x + y * this.width;

		return this.map.get(i);
	}

	public indexToCoords(i: number): { x: number; y: number } {
		const y = math.floor(i / this.width);
		const x = i % this.width;

		return { x, y };
	}
}
