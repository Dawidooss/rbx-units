import ClientGameStore from "./ClientGameStore";
import Replicator from "./ClientReplicator";
import UnitsStore, { UnitData } from "shared/DataStore/Stores/UnitsStore";
import Unit from "client/Units/Unit";
import { ServerScriptService, Workspace } from "@rbxts/services";
import BitBuffer from "@rbxts/bitbuffer";
import ClientReplicator from "./ClientReplicator";

const replicator = ClientReplicator.Get();

export default class ClientUnitsStore extends UnitsStore {
	public cache = new Map<string, ClientUnitData>();
	public folder = new Instance("Folder", Workspace);

	constructor(gameStore: ClientGameStore) {
		super(gameStore);
		this.folder.Name = "UnitsCache";

		replicator.Connect("unit-created", (buffer: BitBuffer) => {
			const unitData = this.Deserialize(buffer) as ClientUnitData;

			if (this.cache.has(unitData.id)) return;

			unitData.instance = new Unit(unitData);

			this.Add(unitData);
		});

		replicator.Connect("unit-removed", (buffer: BitBuffer) => {
			const unitId = buffer.readString();
			this.Remove(unitId);
		});
	}

	public GetUnitsInstances() {
		const instances: Unit[] = [];
		for (const [_, unit] of this.cache) {
			instances.push(unit.instance);
		}
		return instances;
	}

	public OverrideData(buffer: BitBuffer): void {
		this.cache.forEach((unitData) => {
			unitData.instance.Destroy();
		});
		super.OverrideData(buffer);
	}
}

export type ClientUnitData = UnitData & {
	instance: Unit;
};
