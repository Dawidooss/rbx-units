import { RunService } from "@rbxts/services";
import Movement from "./Movement";
import UnitsManager from "./Units/UnitsManager";
import Input from "./Input";
import Selection from "./Units/Selection";
import Admin from "./Admin";
import UnitsAction from "./Units/UnitsAction";
import HUDHandler from "./Units/HUDHandler";
import HUD from "./Units/HUD";
import GameStore from "./Stores/GameStore";
import TeamsStore from "./Stores/ClientTeamsStore";

HUD.Init();
HUDHandler.Init();
Selection.Init();
UnitsManager.Init();
Movement.Init();
Input.Init();
Admin.Init();
UnitsAction.Init();

const gameStore = GameStore.Get();

RunService.RenderStepped.Connect((deltaTime) => {
	Movement.Update(deltaTime);
});

wait(10);
const teamStore = gameStore.GetStore("TeamsStore") as TeamsStore;
print(teamStore.teams);
