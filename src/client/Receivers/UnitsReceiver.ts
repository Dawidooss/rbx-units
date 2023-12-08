import Replicator from "client/DataStore/Replicator";
import UnitsStore from "client/DataStore/UnitsStore";
import Unit from "client/Units/Unit";
import { UnitData } from "shared/DataStore/Stores/UnitsStoreBase";
import { Sedes } from "shared/Sedes";

const replicator = Replicator.Get();
const unitsStore = UnitsStore.Get();

export default class UnitsReceiver {
	private static instance: UnitsReceiver;
	constructor() {
		replicator.Connect("unit-created", unitsStore.serializer, (unitData) => {
			if (unitsStore.cache.has(unitData.id)) return;

			const unit = new Unit(unitData.id, unitData);
			unitsStore.Add(unit);
		});

		// replicator.Connect("unit-removed", (buffer: BitBuffer) => {
		// 	const unitId = bit.FromBits(buffer.readBits(12));
		// 	unitsStore.Remove(unitId);
		// });

		// replicator.Connect("unit-movement", (buffer: BitBuffer) => {
		// 	const unitId = bit.FromBits(buffer.readBits(12));
		// 	const position = new Vector3(bit.FromBits(buffer.readBits(10)), 10, bit.FromBits(buffer.readBits(10)));
		// 	const path = unitsStore.DeserializePath(buffer);

		// 	const unit = unitsStore.cache.get(unitId);
		// 	if (!unit) {
		// 		// TODO: error? fetch-all
		// 		return;
		// 	}

		// 	const fakeQueue = new ReplicationQueue();

		// 	unit.UpdatePosition(position);
		// 	unit.movement.MoveAlongPath(path, fakeQueue);
		// });

		// replicator.Connect("update-unit-heal", (buffer: BitBuffer) => {
		// 	const unitId = bit.FromBits(buffer.readBits(12));
		// 	const health = bit.FromBits(buffer.readBits(7));
		// 	const unit = unitsStore.cache.get(unitId);

		// 	if (!unit) {
		// 		// TODO: error? fetch-all
		// 		return;
		// 	}

		// 	unit.health = health;
		// 	unit.UpdateVisuals();
		// });

		// fetching connection
		const fetchSerializer = new Sedes.Serializer<{
			data: Map<number, UnitData>;
		}>([["data", Sedes.ToDict<number, UnitData>(Sedes.ToUnsigned(12), unitsStore.serializer)]]);

		replicator.Connect("units-store", fetchSerializer, (data) => {
			const newCache = new Map<number, Unit>();
			for (const [unitId, unitData] of data.data) {
				newCache.set(unitId, new Unit(unitId, unitData));
			}

			unitsStore.OverrideCache(newCache);
		});

		UnitsReceiver.instance = this;
	}

	public static Get() {
		return UnitsReceiver.instance || new UnitsReceiver();
	}
}
