import { HttpService } from "@rbxts/services";
import Utils from "../shared/Utils";
import { UnitData } from "shared/DataStore/Stores/UnitsStoreBase";
import ReplicationQueue from "../shared/ReplicationQueue";
import BitBuffer from "@rbxts/bitbuffer";
import Input from "./Input";
import ClientGameStore from "./DataStore/GameStore";
import ClientUnitsStore from "./DataStore/UnitsStore";
import ClientReplicator from "./DataStore/Replicator";
import Unit from "./Units/Unit";

const input = Input.Get();
const replicator = ClientReplicator.Get();

const gameStore = ClientGameStore.Get();
const unitsStore = gameStore.GetStore("UnitsStore") as ClientUnitsStore;

export default class Admin {
	private static instance: Admin;
	constructor() {
		Admin.instance = this;

		// let x = false;

		input.Bind(Enum.KeyCode.F, Enum.UserInputState.End, () => this.SpawnUnit());
		// input.Bind(Enum.KeyCode.F, Enum.UserInputState.Begin, () => {
		// 	x = true;
		// });
		// input.Bind(Enum.KeyCode.F, Enum.UserInputState.End, () => {
		// 	x = false;
		// });

		// spawn(() => {
		// 	while (wait(0.05)) {
		// 		if (x) {
		// 			this.SpawnUnit();
		// 		}
		// 	}
		// });
	}

	private SpawnUnit() {
		const mouseHitResult = Utils.GetMouseHit([unitsStore.folder]);

		if (mouseHitResult?.Position) {
			const id = HttpService.GenerateGUID(false);
			const name = "Dummy";
			const position = mouseHitResult.Position;

			const unit = new Unit(gameStore, id, name, position);
			unitsStore.Add(unit);

			const queue = new ReplicationQueue();
			queue.Add("create-unit", (buffer: BitBuffer) => {
				unitsStore.Serialize(unit, buffer);
			});

			replicator.Replicate(queue);
		}
	}

	public static Get() {
		return Admin.instance || new Admin();
	}
}
