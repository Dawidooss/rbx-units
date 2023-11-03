import { ContextActionService, UserInputService, Workspace } from "@rbxts/services";
import UnitsManager from "./UnitsManager";
import inset from "./GuiInset";
import Unit from "./Unit";

const camera = Workspace.CurrentCamera!;

export default class Input {
	public static Init() {
		print("init");
		ContextActionService.BindAction(
			"input",
			this.HandleInput,
			false,
			Enum.KeyCode.F,
			Enum.UserInputType.MouseButton1,
		);
	}

	private static HandleInput = (action: string, state: Enum.UserInputState, input: InputObject) => {
		if (action !== "input") return;

		const begin = state === Enum.UserInputState.Begin;

		const mousePosition = UserInputService.GetMouseLocation().sub(new Vector2(0, inset));
		const rayData = camera.ScreenPointToRay(mousePosition.X, mousePosition.Y, 1);

		const raycastParams = new RaycastParams();
		raycastParams.FilterType = Enum.RaycastFilterType.Exclude;

		raycastParams.FilterDescendantsInstances = [camera, UnitsManager.cache];
		const terrainHit = Workspace.Raycast(rayData.Origin, rayData.Direction.mul(10000), raycastParams);
		raycastParams.FilterDescendantsInstances = [camera];
		const unitHit = Workspace.Raycast(rayData.Origin, rayData.Direction.mul(10000), raycastParams);

		if (input.UserInputType === Enum.UserInputType.Keyboard) {
			if (input.KeyCode === Enum.KeyCode.F && !begin) {
				if (terrainHit?.Position) {
					UnitsManager.CreateUnit(UnitsManager.GenerateUnitId(), "Dummy", terrainHit.Position);
				}
			}
		} else if (input.UserInputType === Enum.UserInputType.MouseButton1) {
			if (unitHit?.Instance && unitHit.Instance.Name !== "SelectionCircle") {
				const unitModel = unitHit.Instance.Parent;
				const unitId = unitModel!.Name;

				const unit = UnitsManager.GetUnit(unitId);
				if (unit) {
					UnitsManager.SelectUnits([unit]);
				} else {
					UnitsManager.SelectUnits([]);
				}
			} else {
				UnitsManager.SelectUnits([]);
			}
		}
	};
}
