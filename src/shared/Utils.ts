import { UserInputService, Workspace } from "@rbxts/services";
import GetGuiInset from "./GuiInset";

const camera = Workspace.CurrentCamera!;

export default abstract class Utils {
	public static GetMouseHit(
		filterDescendantsInstances?: Instance[],
		filterType?: Enum.RaycastFilterType,
	): RaycastResult | undefined {
		const mouseLocation = UserInputService.GetMouseLocation().sub(new Vector2(0, GetGuiInset()));
		const rayData = camera.ScreenPointToRay(mouseLocation.X, mouseLocation.Y, 1);

		const raycastParams = new RaycastParams();
		raycastParams.FilterType = filterType || Enum.RaycastFilterType.Exclude;
		raycastParams.FilterDescendantsInstances = filterDescendantsInstances || [camera];

		const terrainHit = Workspace.Raycast(rayData.Origin, rayData.Direction.mul(10000), raycastParams);

		return terrainHit;
	}

	public static RaycastBottom(
		position: Vector3,
		filterDescendantsInstances?: Instance[],
		filterType?: Enum.RaycastFilterType,
	): RaycastResult | undefined {
		const raycastParams = new RaycastParams();
		raycastParams.FilterType = filterType || Enum.RaycastFilterType.Exclude;
		raycastParams.FilterDescendantsInstances = filterDescendantsInstances || [camera];
		const result = Workspace.Raycast(position, new Vector3(0, -100000000, 0), raycastParams);

		return result;
	}

	public static Map(x: number, in_min: number, in_max: number, out_min: number, out_max: number) {
		return out_min + ((x - in_min) * (out_max - out_min)) / (in_max - in_min);
	}
}
