import Network from "shared/Network";
import ReceiverBase from "./ReceiverBase";
import Squash from "@rbxts/squash";
import { RunService } from "@rbxts/services";
import { UnitData } from "shared/Game/UnitData";

export default class UnitsReceiver implements ReceiverBase {
	public type = "UnitReplicator";

	constructor() {
		Network.BindEvents({
			createUnit: (player: Player, unitType: any, position: any) => {
				unitType = Squash.string.des(unitType);
				position = Squash.Vector3.des(position);

				// this.gameStore.teams;
			},
		});

		Network.BindFunctions({
			[this.type]: (player: Player, unitType: any, position: any) => {},
		});
	}

	public FetchAll() {
		if (!RunService.IsClient()) return;

		let serializedData = Network.InvokeServer(this.type);
		let deserializedData = new Map<string, UnitData>();
	}

	public Serialize() {}

	public Destroy(): void {}
}
