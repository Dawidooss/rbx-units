import { UserInputService, Workspace } from "@rbxts/services";
import guiInset from "./GuiInset";
import UnitsManager from "./Units/UnitsManager";

const camera = Workspace.CurrentCamera!;

export default abstract class Utils {
	public static GetMouseHit(): RaycastResult | undefined {
		const mouseLocation = UserInputService.GetMouseLocation().sub(new Vector2(0, guiInset));
		const rayData = camera.ScreenPointToRay(mouseLocation.X, mouseLocation.Y, 1);

		const raycastParams = new RaycastParams();
		raycastParams.FilterType = Enum.RaycastFilterType.Exclude;

		raycastParams.FilterDescendantsInstances = [camera, UnitsManager.cache];
		const terrainHit = Workspace.Raycast(rayData.Origin, rayData.Direction.mul(10000), raycastParams);

		return terrainHit;
	}

	public static RaycastBottom(position: Vector3, exclude?: Instance[]): Vector3 | undefined {
		const raycastParams = new RaycastParams();
		raycastParams.FilterType = Enum.RaycastFilterType.Exclude;
		if (exclude) {
			raycastParams.FilterDescendantsInstances = exclude;
		}
		const result = Workspace.Raycast(position, new Vector3(0, -math.huge, 0), raycastParams);

		if (!result) return;

		return result.Position;
	}
}
