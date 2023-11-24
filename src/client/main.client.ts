import { RunService } from "@rbxts/services";
import Movement from "./Movement";
import Input from "./Input";
import Selection from "./Units/Selection";
import Admin from "./Admin";
import UnitsAction from "./Units/UnitsAction";
import HUDHandler from "./Units/HUDHandler";
import HUD from "./Units/HUD";
import ClientGameStore from "./DataStore/ClientGameStore";
import ClientPlayersStore from "./DataStore/ClientPlayersStore";
import TeamsStore from "shared/DataStore/Stores/TeamStore";
import ClientTeamsStore from "./DataStore/ClientTeamsStore";

const gameStore = ClientGameStore.Get();
const hud = HUD.Get();

HUDHandler.Init();
Selection.Init();
Movement.Init();
Input.Init();
Admin.Init();
UnitsAction.Init();

RunService.RenderStepped.Connect((deltaTime) => {
	Movement.Update(deltaTime);
});
