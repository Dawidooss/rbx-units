import BitBuffer from "@rbxts/bitbuffer";
import { Workspace } from "@rbxts/services";
import Unit from "client/Units/Unit";
import UnitsStoreBase, { UnitData } from "shared/DataStore/Stores/UnitsStoreBase";
import Replicator from "./Replicator";

const replicator = Replicator.Get();

export default class UnitsStore extends UnitsStoreBase {
	public cache = new Map<number, Unit>();
	public folder = new Instance("Folder", Workspace);

	private static instance: UnitsStore;
	constructor() {
		super();
		this.folder.Name = "UnitsCache";
		UnitsStore.instance = this;
	}

	public Add(unit: Unit): Unit {
		super.Add(unit);
		return unit;
	}

	public Remove(unitId: number) {
		const unit = this.cache.get(unitId);
		unit?.Destroy();

		super.Remove(unitId);
	}

	public Clear() {
		this.cache.forEach((unitData) => {
			unitData.Destroy();
		});

		super.Clear();
	}

	public OverrideCache(newCache: Map<number, Unit>): void {
		this.Clear();
		this.cache = newCache;
	}

	public static Get() {
		return UnitsStore.instance || new UnitsStore();
	}
}
