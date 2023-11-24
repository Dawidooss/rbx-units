import { Players, Workspace } from "@rbxts/services";

const player = Players.LocalPlayer;
const playerGui = player.WaitForChild("PlayerGui") as PlayerGui;
const camera = Workspace.CurrentCamera!;

export default class HUD {
	public gui: HUDGui;

	private static instance: HUD;
	constructor() {
		HUD.instance = this;

		this.gui = playerGui.WaitForChild("HUD") as HUDGui;
	}

	public static Get() {
		return HUD.instance || new HUD();
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
