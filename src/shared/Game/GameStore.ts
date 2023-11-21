import TeamStore from "./TeamStore";
import { UnitData } from "./UnitData";

export default class GameStore {
	private static instance: GameStore;

	public teams = new Map<string, TeamStore>();
	public players = new Map<Player, TeamStore | Unasigned>();
	public units = new Map<string, UnitData>();

	constructor() {}

	public static Get() {
		return GameStore.instance || new GameStore();
	}
}

export class Unasigned {}
