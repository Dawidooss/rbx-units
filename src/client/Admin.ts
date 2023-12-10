import Utils from "../shared/Utils";
import ReplicationQueue from "../shared/ReplicationQueue";
import BitBuffer from "@rbxts/bitbuffer";
import Input from "./Input";
import ClientReplicator from "./DataStore/Replicator";
import Unit from "./Units/Unit";
import UnitsStore from "./DataStore/UnitsStore";
import { player } from "./Instances";

const input = Input.Get();
const replicator = ClientReplicator.Get();
const unitsStore = UnitsStore.Get();

export default class Admin {
	private static instance: Admin;
	constructor() {
		Admin.instance = this;

		let x = false;

		// input.Bind(Enum.KeyCode.F, Enum.UserInputState.End, () => this.SpawnUnit());
		input.Bind(Enum.KeyCode.F, Enum.UserInputState.Begin, () => {
			x = true;
		});
		input.Bind(Enum.KeyCode.F, Enum.UserInputState.End, () => {
			x = false;
		});

		spawn(() => {
			while (wait(0.05)) {
				if (x) {
					this.SpawnUnit();
				}
			}
		});
	}

	private SpawnUnit() {
		const mouseHitResult = Utils.GetMouseHit([unitsStore.folder]);

		if (mouseHitResult?.Position) {
			const name = "Dummy";
			const position = mouseHitResult.Position;
			const unitId = unitsStore.freeIds.shift();
			if (!unitId) return;

			const unit = new Unit(unitId, {
				id: unitId,
				position: position,
				name: name,
				playerId: player.UserId,
				path: [],
				health: 100,
			});
			unitsStore.Add(unit);

			const queue = new ReplicationQueue();
			queue.Append("create-unit", unitsStore.serializer.Ser(unit));

			replicator.Replicate(queue);
		}
	}

	public static Get() {
		return Admin.instance || new Admin();
	}
}
