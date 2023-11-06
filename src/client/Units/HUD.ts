import { Players, Workspace } from "@rbxts/services";

const player = Players.LocalPlayer;
const playerGui = player.WaitForChild("PlayerGui") as PlayerGui;
const camera = Workspace.CurrentCamera!;

export default abstract class HUD {
	public static gui: HUDGui;

	public static Init() {
		this.gui = playerGui.WaitForChild("HUD") as HUDGui;
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
