import { Players, Workspace } from "@rbxts/services";

const player = Players.LocalPlayer;
const playerGui = player.WaitForChild("PlayerGui") as PlayerGui;
const camera = Workspace.CurrentCamera!;

const screenGui = new Instance("ScreenGui", playerGui);
const frame = new Instance("Frame", screenGui);
frame.Size = new UDim2(1, 0, 1, 0);

const inset = camera.ViewportSize.Y - frame.AbsoluteSize.Y;

screenGui.Destroy();

export default inset;
