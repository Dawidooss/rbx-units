import BitBuffer from "@rbxts/bitbuffer";
import ClientGameStore from "client/DataStore/ClientGameStore";
import ClientReplicator from "client/DataStore/ClientReplicator";
import ClientUnitsStore from "client/DataStore/ClientUnitsStore";

const replicator = ClientReplicator.Get();
const gameStore = ClientGameStore.Get();
const unitsStore = gameStore.GetStore("UnitsStore") as ClientUnitsStore;

export default class UnitsReplicator {
	private static instance: UnitsReplicator;
	constructor() {
		UnitsReplicator.instance = this;

		replicator.Connect("unit-movement", (buffer: BitBuffer) => {
			const unitId = buffer.readString();
			const position = buffer.readVector3();
			const startTick = buffer.readFloat32();
			const path = [];

			while (buffer.getPointerByte() !== buffer.getByteLength()) {
				path.push(buffer.readVector3());
			}

			const unit = unitsStore.cache.get(unitId);
			if (!unit) {
				replicator.FetchAll();
			}
		});
	}

	public static Get() {
		return UnitsReplicator.instance || new UnitsReplicator();
	}
}
