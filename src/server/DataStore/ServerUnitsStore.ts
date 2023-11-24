import Replicator, { ServerResponseBuilder } from "./ServerReplicator";
import { TeamData } from "shared/DataStore/Stores/TeamStore";
import ServerGameStore from "./ServerGameStore";
import PlayersStore, { PlayerData } from "shared/DataStore/Stores/PlayersStore";
import UnitsStore, { UnitData } from "shared/DataStore/Stores/UnitsStore";
import Utils from "shared/Utils";
import BitBuffer from "@rbxts/bitbuffer";
import ServerReplicator from "./ServerReplicator";

const replicator = ServerReplicator.Get();

export default class ServerUnitsStore extends UnitsStore {
	constructor(gameStore: ServerGameStore) {
		super(gameStore);

		replicator.Connect("create-unit", (player: Player, data: string) => {
			const buffer = BitBuffer(data);

			const unitData = this.Deserialize(buffer);
			this.Add(unitData);
			return new ServerResponseBuilder().Build();
		});
	}

	public Add(unitData: UnitData): UnitData {
		super.Add(unitData);
		replicator.ReplicateAll("unit-created", this.Serialize(unitData));

		return unitData;
	}

	public Remove(unitId: string): void {
		super.Remove(unitId);

		const buffer = BitBuffer();
		buffer.writeString(unitId);
		replicator.ReplicateAll("unit-removed", buffer);
	}

	public UpdateUnitPosition(unitData: UnitData) {
		const position = unitData.position.Lerp(
			unitData.targetPosition,
			math.clamp(Utils.Map(os.time(), unitData.movementStartTick, unitData.movementEndTick, 0, 1), 0, 1),
		);

		unitData.position = position;
		unitData.movementStartTick = os.time();
	}
}
