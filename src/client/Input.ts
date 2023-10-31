import { ContextActionService, UserInputService, Workspace } from "@rbxts/services";
import UnitsManager from "./UnitsManager";
import inset from "./GuiInset";

const camera = Workspace.CurrentCamera!;

export default class Input {
	public static Init() {
		ContextActionService.BindAction(
			"input",
			this.HandleInput,
			false,
			Enum.KeyCode.F,
			Enum.UserInputType.MouseButton1,
		);
	}

	private static HandleInput = (action: string, state: Enum.UserInputState, input: InputObject) => {
		const begin = state === Enum.UserInputState.Begin;

		const mousePosition = UserInputService.GetMouseLocation().sub(new Vector2(0, inset));
		const rayData = camera.ScreenPointToRay(mousePosition.X, mousePosition.Y, 1);

		const raycastParams = new RaycastParams();
		raycastParams.FilterDescendantsInstances = [camera, UnitsManager.cache];
		raycastParams.FilterType = Enum.RaycastFilterType.Exclude;

		const mouseHit = Workspace.Raycast(rayData.Origin, rayData.Direction.mul(10000), raycastParams);

		if (action === "input") {
			if (input.UserInputType === Enum.UserInputType.Keyboard) {
				if (input.KeyCode === Enum.KeyCode.F && !begin) {
					if (mouseHit?.Position) {
						UnitsManager.CreateUnit(UnitsManager.GenerateUnitId(), "Dummy", mouseHit.Position);
					}
				}
			} else if (input.UserInputType === Enum.UserInputType.MouseButton1) {
				if (mouseHit?.Position) {
					UnitsManager.SelectUnitsAt(mouseHit.Position, mouseHit.Position);
				}
			}
		}
	};
}
