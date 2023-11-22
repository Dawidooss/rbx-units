import Replicator, { ServerResponseBuilder } from "./ServerReplicator";
import { TeamData } from "shared/DataStore/Stores/TeamStore";
import ServerGameStore from "./ServerGameStore";
import PlayersStore, { PlayerData } from "shared/DataStore/Stores/PlayersStore";
import UnitsStore, { SerializedUnitData, UnitData } from "shared/DataStore/Stores/UnitsStore";
import Utils from "shared/Utils";

export default class ServerUnitsStore extends UnitsStore {
	public replicator: Replicator;

	constructor(gameStore: ServerGameStore) {
		super(gameStore);
		this.replicator = gameStore.replicator;

		this.replicator.Connect("create-unit", (player: Player, serializedUnitData: SerializedUnitData) => {
			const unitData = this.Deserialize(serializedUnitData);
			this.AddUnit(unitData);
			return new ServerResponseBuilder().Build();
		});
	}

	public AddUnit(unitData: UnitData): UnitData {
		super.AddUnit(unitData);
		this.replicator.ReplicateAll("unit-created", this.Serialize(unitData));

		return unitData;
	}

	public RemoveUnit(unitId: string): void {
		super.RemoveUnit(unitId);
		this.replicator.ReplicateAll("unit-removed", unitId);
	}

	public UpdateUnitPosition(unitData: UnitData) {
		const position = unitData.position.Lerp(
			unitData.targetPosition,
			math.clamp(Utils.Map(tick(), unitData.movementStartTick, unitData.movementEndTick, 0, 1), 0, 1),
		);

		unitData.position = position;
		unitData.movementStartTick = tick();
	}
}
