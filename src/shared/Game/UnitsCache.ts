import GameStore from "./GameStore";
import TeamStore from "./TeamStore";
import { UnitData } from "./UnitData";

export default class UnitsCache {
	public teamStore: TeamStore;

	private cache = new Map<string, UnitData>();

	constructor(teamStore: TeamStore) {
		this.teamStore = teamStore;
	}

	public SetUnits(units: Map<string, UnitData>) {}

	public AddUnit(unitData: UnitData) {
		this.cache.set(unitData.id, unitData);
	}

	public RemoveUnit(id: string) {
		return this.cache.delete(id);
	}
}
