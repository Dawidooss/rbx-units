import { HttpService, Players, Workspace } from "@rbxts/services";
import Input from "./Input";
import Utils from "../shared/Utils";
import ClientGameStore from "./DataStore/ClientGameStore";
import ClientUnitsStore, { ClientUnitData } from "./DataStore/ClientUnitsStore";
import ClientPlayersStore from "./DataStore/ClientPlayersStore";
import Unit from "./Units/Unit";

const camera = Workspace.CurrentCamera!;
const player = Players.LocalPlayer;

const gameStore = ClientGameStore.Get();
const unitsStore = gameStore.GetStore("UnitsStore") as ClientUnitsStore;
const playersStore = gameStore.GetStore("PlayersStore") as ClientPlayersStore;

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
				playerData: playersStore.cache.get(tostring(player.UserId))!,
			} as ClientUnitData;

			unitData.instance = new Unit(unitData);
			unitsStore.AddUnit(unitData);

			gameStore.replicator.Replicate("create-unit", unitsStore.Serialize(unitData));
		}
	}
}
