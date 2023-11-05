import { UserInputService, Workspace } from "@rbxts/services";
import guiInset from "./GuiInset";
import UnitsManager from "./Units/UnitsManager";

const camera = Workspace.CurrentCamera!;

export default class Utils {
	public static GetMouseHit(): RaycastResult | undefined {
		const mouseLocation = UserInputService.GetMouseLocation().sub(new Vector2(0, guiInset));
		const rayData = camera.ScreenPointToRay(mouseLocation.X, mouseLocation.Y, 1);

		const raycastParams = new RaycastParams();
		raycastParams.FilterType = Enum.RaycastFilterType.Exclude;

		raycastParams.FilterDescendantsInstances = [camera, UnitsManager.cache];
		const terrainHit = Workspace.Raycast(rayData.Origin, rayData.Direction.mul(10000), raycastParams);

		return terrainHit;
	}
	public static FixCFrame(cframe: CFrame): CFrame {
		const c = cframe.GetComponents();
		return new CFrame(
			c[0] || 0,
			c[1] || 0,
			c[2] || 0,
			c[3] || 0,
			c[4] || 0,
			c[5] || 0,
			c[6] || 0,
			c[7] || 0,
			c[8] || 0,
			c[9] || 0,
			c[10] || 0,
			c[11] || 0,
		);
	}
}
