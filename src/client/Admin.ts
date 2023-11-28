import { HttpService, Players, ReplicatedFirst } from "@rbxts/services";
import Input from "./Input";
import Utils from "../shared/Utils";
import ClientGameStore from "./DataStore/ClientGameStore";
import ClientUnitsStore, { ClientUnitData } from "./DataStore/ClientUnitsStore";
import Unit from "./Units/Unit";
import ClientReplicator from "./DataStore/ClientReplicator";
import { UnitData } from "shared/DataStore/Stores/UnitsStore";
import ReplicationQueue from "../shared/ReplicationQueue";
import BitBuffer from "@rbxts/bitbuffer";

const player = Players.LocalPlayer;

const gameStore = ClientGameStore.Get();
const unitsStore = gameStore.GetStore("UnitsStore") as ClientUnitsStore;

const replicator = ClientReplicator.Get();

export default abstract class Admin {
	public static Init() {
		Input.Bind(Enum.KeyCode.F, Enum.UserInputState.End, () => this.SpawnUnit());
	}

	private static SpawnUnit() {
		const mouseHitResult = Utils.GetMouseHit([unitsStore.folder]);

		if (mouseHitResult?.Position) {
			let unitData = {
				id: HttpService.GenerateGUID(false),
				type: "Dummy",
				position: mouseHitResult.Position,
				playerId: player.UserId,
				path: [],
			} as UnitData;

			let clientUnitData = unitData as ClientUnitData;
			clientUnitData.instance = new Unit(unitData);

			unitsStore.Add(clientUnitData);

			const queue = new ReplicationQueue();
			queue.Add("create-unit", (buffer: BitBuffer) => {
				unitsStore.Serialize(unitData, buffer);
			});
			replicator.Replicate("create-unit", queue);
		}
	}
}
