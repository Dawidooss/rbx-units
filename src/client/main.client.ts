import { ContextActionService, Players, RunService, UserInputService, Workspace } from "@rbxts/services";
import Movement from "./Movement";
import UnitsManager from "./UnitsManager";
import Input from "./Input";
import Selection from "./Selection";
import Admin from "./Admin";
import UnitsRegroup from "./UnitsRegroup";

Selection.Init();
UnitsManager.Init();
Movement.Init();
Input.Init();
Admin.Init();
UnitsRegroup.Init();

RunService.RenderStepped.Connect((deltaTime) => {
	Movement.Update(deltaTime);
});
