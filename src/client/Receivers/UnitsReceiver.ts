import BitBuffer from "@rbxts/bitbuffer";
import GameStore from "client/DataStore/GameStore";
import Replicator from "client/DataStore/Replicator";
import UnitsStore from "client/DataStore/UnitsStore";
import Unit from "client/Units/Unit";
import { UnitData } from "shared/DataStore/Stores/UnitsStoreBase";
import ReplicationQueue from "shared/ReplicationQueue";
import bit from "shared/bit";

const replicator = Replicator.Get();

const gameStore = GameStore.Get();
const unitsStore = gameStore.GetStore("UnitsStore") as UnitsStore;

export default class UnitsReceiver {
	private static instance: UnitsReceiver;
	constructor() {
		replicator.Connect("unit-created", (buffer: BitBuffer) => {
			const unitData = unitsStore.Deserialize(buffer) as UnitData;

			if (unitsStore.cache.has(unitData.id)) return;
			const unit = new Unit(
				gameStore,
				unitData.id,
				unitData.name,
				unitData.position,
				unitData.playerId,
				unitData.path,
			);

			unitsStore.Add(unit);
		});

		replicator.Connect("unit-removed", (buffer: BitBuffer) => {
			const unitId = bit.FromBits(buffer.readBits(12));
			unitsStore.Remove(unitId);
		});

		replicator.Connect("unit-movement", (buffer: BitBuffer) => {
			const unitId = bit.FromBits(buffer.readBits(12));
			const position = new Vector3(bit.FromBits(buffer.readBits(10)), 10, bit.FromBits(buffer.readBits(10)));
			const path = unitsStore.DeserializePath(buffer);

			const unit = unitsStore.cache.get(unitId);
			if (!unit) {
				// TODO: error? fetch-all
				return;
			}

			const fakeQueue = new ReplicationQueue();

			unit.UpdatePosition(position);
			unit.movement.MoveAlongPath(path, fakeQueue);
		});

		replicator.Connect("update-unit-heal", (buffer: BitBuffer) => {
			const unitId = bit.FromBits(buffer.readBits(12));
			const health = bit.FromBits(buffer.readBits(7));
			const unit = unitsStore.cache.get(unitId);

			if (!unit) {
				// TODO: error? fetch-all
				return;
			}

			unit.health = health;
			unit.UpdateVisuals();
		});

		UnitsReceiver.instance = this;
	}

	public static Get() {
		return UnitsReceiver.instance || new UnitsReceiver();
	}
}
