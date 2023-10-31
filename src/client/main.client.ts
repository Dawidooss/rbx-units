import { ContextActionService, Players, RunService, UserInputService, Workspace } from "@rbxts/services";
import Movement from "./Movement";

Movement.Init();

RunService.RenderStepped.Connect((deltaTime) => {
	Movement.Update(deltaTime);
});
