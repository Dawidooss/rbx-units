import BitBuffer from "@rbxts/bitbuffer";
import GameStore from "client/DataStore/GameStore";
import Replicator from "client/DataStore/Replicator";
import UnitsStore from "client/DataStore/UnitsStore";
import Unit from "client/Units/Unit";
import { UnitData } from "shared/DataStore/Stores/UnitsStoreBase";
import ReplicationQueue from "shared/ReplicationQueue";

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
			const unitId = buffer.readString();
			unitsStore.Remove(unitId);
		});

		replicator.Connect("unit-movement", (buffer: BitBuffer) => {
			const unitId = buffer.readString();
			const position = buffer.readVector3();
			const path = unitsStore.DeserializePath(buffer);

			const unit = unitsStore.cache.get(unitId);
			if (!unit) {
				// TODO: error? fetch-all
				return;
			}

			const fakeQueue = new ReplicationQueue();

			unit.position = position;
			unit.UpdatePosition(position);
			unit.movement.MoveAlongPath(path, fakeQueue);
		});

		UnitsReceiver.instance = this;
	}

	public static Get() {
		return UnitsReceiver.instance || new UnitsReceiver();
	}
}
