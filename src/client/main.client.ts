import { RunService } from "@rbxts/services";
import Movement from "./Movement";
import Admin from "./Admin";
import Selection from "./Units/Selection";
import UnitsReceiver from "./Receivers/UnitsReceiver";
import UnitsAction from "./Units/UnitsAction";
import HUDHandler from "./Units/HUDHandler";

const unitsReceiver = UnitsReceiver.Get();

const movement = Movement.Get();
const selection = Selection.Get();
const admin = Admin.Get();
const unitsAction = UnitsAction.Get();
const hudHandler = HUDHandler.Get();

RunService.RenderStepped.Connect((deltaTime) => {
	movement.Update(deltaTime);
});
