import ClientGameStore from "./ClientGameStore";
import Replicator from "./ClientReplicator";
import TeamsStore, { SerializedTeamData } from "shared/DataStore/Stores/TeamStore";
import { ServerResponse } from "types";
import UnitsStore, { SerializedUnitData, UnitData } from "shared/DataStore/Stores/UnitsStore";
import Unit from "client/Units/Unit";
import { Workspace } from "@rbxts/services";

export default class ClientUnitsStore extends UnitsStore {
	public replicator: Replicator;
	public cache = new Map<string, ClientUnitData>();
	public folder = new Instance("Folder", Workspace);

	constructor(gameStore: ClientGameStore) {
		super(gameStore);
		this.replicator = gameStore.replicator;
		this.folder.Name = "UnitsCache";

		this.replicator.Connect("unit-created", (response: ServerResponse) => {
			const serializedUnitData = response.data as SerializedUnitData;
			const unitData = this.Deserialize(serializedUnitData) as ClientUnitData;

			if (this.cache.has(unitData.id)) return;

			unitData.instance = new Unit(unitData);

			this.AddUnit(unitData);
		});

		this.replicator.Connect("unit-removed", (response: ServerResponse) => {
			const serializedUnitId = response.data as string;
			const unitId = serializedUnitId;
			this.RemoveUnit(unitId);
		});
	}

	public AddUnit(unitData: ClientUnitData): ClientUnitData {
		super.AddUnit(unitData);

		return unitData;
	}

	public GetUnitsInstances() {
		const instances: Unit[] = [];
		for (const [_, unit] of this.cache) {
			instances.push(unit.instance);
		}
		return instances;
	}

	public OverrideData(serializedUnitDatas: SerializedUnitData[]): void {
		this.cache.forEach((unitData) => {
			unitData.instance.Destroy();
		});
		super.OverrideData(serializedUnitDatas);
	}
}

export type ClientUnitData = UnitData & {
	instance: Unit;
};
