import { ContextActionService, Players, RunService, UserInputService, Workspace } from "@rbxts/services";
import Movement from "./Movement";
import UnitsManager from "./UnitsManager";
import Input from "./Input";

UnitsManager.Init();
Movement.Init();
Input.Init();

RunService.RenderStepped.Connect((deltaTime) => {
	Movement.Update(deltaTime);
});
