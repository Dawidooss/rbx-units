import BitBuffer from "@rbxts/bitbuffer";
import GameStore from "./GameStore";
import { Workspace } from "@rbxts/services";
import Unit from "client/Units/Unit";
import UnitsStoreBase from "shared/DataStore/Stores/UnitsStoreBase";

export default class UnitsStore extends UnitsStoreBase {
	public cache = new Map<number, Unit>();
	public folder = new Instance("Folder", Workspace);

	constructor(gameStore: GameStore) {
		super(gameStore);
		this.folder.Name = "UnitsCache";
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

	public OverrideData(buffer: BitBuffer): void {
		this.Clear();

		while (buffer.readBits(1)[0] === 1) {
			const unitData = this.Deserialize(buffer);
			const unit = new Unit(
				this.gameStore as GameStore,
				unitData.id,
				unitData.name,
				unitData.position,
				unitData.playerId,
				unitData.path,
				unitData.health,
			);
			this.Add(unit);
		}
	}
}