import { Players } from "@rbxts/services";
import { player } from "client/Instances";

const playerGui = player.WaitForChild("PlayerGui") as PlayerGui;

export default class GUI {
	public hud: HUDGui;

	private static instance: GUI;
	constructor() {
		GUI.instance = this;

		this.hud = playerGui.WaitForChild("HUD") as HUDGui;
	}

	public static Get() {
		return GUI.instance || new GUI();
	}
}

type HUDGui = ScreenGui & {
	Formations: Frame & {
		Line: TextButton;
		Square: TextButton;
		Circle: TextButton;
	};
	SelectionBox: Frame & {
		UIStroke: UIStroke;
	};
};
