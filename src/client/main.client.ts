import { RunService } from "@rbxts/services";
import Movement from "./Movement";
import UnitsManager from "./Units/UnitsManager";
import Input from "./Input";
import Selection from "./Units/Selection";
import Admin from "./Admin";
import UnitsAction from "./Units/UnitsAction";

Selection.Init();
UnitsManager.Init();
Movement.Init();
Input.Init();
Admin.Init();
UnitsAction.Init();

RunService.RenderStepped.Connect((deltaTime) => {
	Movement.Update(deltaTime);
});
