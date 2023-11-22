import { RunService } from "@rbxts/services";
import Movement from "./Movement";
import Input from "./Input";
import Selection from "./Units/Selection";
import Admin from "./Admin";
import UnitsAction from "./Units/UnitsAction";
import HUDHandler from "./Units/HUDHandler";
import HUD from "./Units/HUD";
import ClientGameStore from "./DataStore/ClientGameStore";
import ClientTeamsStore from "./DataStore/ClientTeamsStore";
import ClientPlayersStore from "./DataStore/ClientPlayersStore";

const gameStore = ClientGameStore.Get();

HUD.Init();
HUDHandler.Init();
Selection.Init();
Movement.Init();
Input.Init();
Admin.Init();
UnitsAction.Init();

RunService.RenderStepped.Connect((deltaTime) => {
	Movement.Update(deltaTime);
});

wait(10);
const teamStore = gameStore.GetStore("TeamsStore") as ClientTeamsStore;
const playersStore = gameStore.GetStore("PlayersStore") as ClientPlayersStore;
