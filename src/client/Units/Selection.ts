import { ContextActionService, Debris, Players, RunService, UserInputService, Workspace } from "@rbxts/services";
import guiInset from "../GuiInset";
import Unit, { UnitSelectionType } from "./Unit";
import UnitsManager from "./UnitsManager";
import Input from "../Input";

const player = Players.LocalPlayer;
const playerGui = player.WaitForChild("PlayerGui") as PlayerGui;
const camera = Workspace.CurrentCamera!;

enum SelectionType {
	Box,
	Single,
	None,
}

export default abstract class Selection {
	private static gui: GuiObject;
	private static selectionType = SelectionType.None;
	private static boxCornerPosition = new Vector2();
	public static boxSize = new Vector2();
	public static holding: boolean;

	public static hoveringUnits: Array<Unit> = [];
	public static selectedUnits = new Array<Unit>();

	public static Init() {
		Selection.gui = playerGui.WaitForChild("HUD").WaitForChild("SelectionBox") as GuiObject;

		// handle if LMB pressed and relesed
		ContextActionService.BindAction(
			"selection",
			(actionName, state, input) => Selection.SetHolding(state === Enum.UserInputState.Begin),
			false,
			Enum.UserInputType.MouseButton1,
		);

		RunService.BindToRenderStep("Selection", Enum.RenderPriority.Last.Value + 1, () => Selection.Update());
	}

	private static SetHolding(state: boolean) {
		const mouseLocation = UserInputService.GetMouseLocation().sub(new Vector2(0, guiInset));

		Selection.holding = state;
		Selection.boxCornerPosition = new Vector2(mouseLocation.X, mouseLocation.Y);

		// select all hovering units
		if (!state) {
			const shiftHold = Input.IsButtonHolding(Enum.KeyCode.LeftShift);
			const ctrlHold = Input.IsButtonHolding(Enum.KeyCode.LeftControl);

			if (!shiftHold && !ctrlHold) {
				Selection.ClearSelectedUnits();
			}

			if (ctrlHold) {
				Selection.DeselectUnits(this.hoveringUnits);
			} else {
				Selection.SelectUnits(this.hoveringUnits);
			}
		}
	}

	public static GetUnits(): Array<Unit> {
		const units = new Array<Unit>();

		if (Selection.selectionType === SelectionType.Box) {
			UnitsManager.GetUnits().forEach((unit) => {
				const pivot = unit.model.GetPivot();
				const screenPosition = camera.WorldToScreenPoint(pivot.Position)[0];

				if (
					screenPosition.X >= Selection.gui.Position.X.Offset - math.abs(Selection.gui.Size.X.Offset / 2) &&
					screenPosition.X <= Selection.gui.Position.X.Offset + math.abs(Selection.gui.Size.X.Offset / 2) &&
					screenPosition.Y >= Selection.gui.Position.Y.Offset - math.abs(Selection.gui.Size.Y.Offset / 2) &&
					screenPosition.Y <= Selection.gui.Position.Y.Offset + math.abs(Selection.gui.Size.Y.Offset / 2)
				) {
					units.push(unit);
				}
			});
		} else if (Selection.selectionType === SelectionType.Single) {
			const mouseLocation = UserInputService.GetMouseLocation();
			const mouseRay = camera.ViewportPointToRay(mouseLocation.X, mouseLocation.Y);

			const result = Workspace.Raycast(mouseRay.Origin, mouseRay.Direction.mul(10000));
			if (!result || !result.Instance) return [];

			const unit = UnitsManager.GetUnit(result.Instance.Parent?.Name || "");
			if (!unit) return [];

			units.push(unit);
		}

		return units;
	}

	private static Update() {
		const mouseLocation = UserInputService.GetMouseLocation().sub(new Vector2(0, guiInset));
		const hoveringUnits = Selection.GetUnits();

		const boxSize = Selection.boxCornerPosition!.sub(mouseLocation);
		const middle = Selection.boxCornerPosition!.sub(boxSize.div(2));

		// define if curently is box selecting or selecting single unit by just hovering
		Selection.selectionType = boxSize.Magnitude > 3 && Selection.holding ? SelectionType.Box : SelectionType.Single;
		Selection.gui.Visible = Selection.selectionType === SelectionType.Box && Selection.holding;

		// update selectionBox ui wether
		if (Selection.selectionType === SelectionType.Box) {
			Selection.selectionType = boxSize.Magnitude > 3 ? SelectionType.Box : SelectionType.Single;
			Selection.boxSize = boxSize;

			Selection.gui.Size = UDim2.fromOffset(boxSize.X, boxSize.Y);
			Selection.gui.Position = UDim2.fromOffset(middle.X, middle.Y);
		}
		Selection.gui.Visible = Selection.selectionType === SelectionType.Box;

		// unhover old units
		Selection.hoveringUnits.forEach((unit) => {
			if (unit.selectionType === UnitSelectionType.Hovering && !hoveringUnits.find((v) => v === unit)) {
				unit.Select(UnitSelectionType.None);
			}
		});

		// hover new units
		hoveringUnits.forEach((unit) => {
			if (unit.selectionType === UnitSelectionType.None) {
				unit.Select(UnitSelectionType.Hovering);
			}
		});

		Selection.hoveringUnits = hoveringUnits;
	}

	public static ClearSelectedUnits() {
		Selection.selectedUnits.forEach((unit) => {
			unit.Select(UnitSelectionType.None);
		});
		Selection.selectedUnits = [];
	}

	public static SelectUnits(units: Array<Unit>) {
		units.forEach((unit) => {
			if (this.selectedUnits.size() >= 100) return;
			if (this.selectedUnits.find((v) => v === unit)) return;
			unit.Select(UnitSelectionType.Selected);
			Selection.selectedUnits.push(unit);
		});
	}

	public static DeselectUnits(units: Array<Unit>) {
		units.forEach((unit) => {
			unit.Select(UnitSelectionType.None);

			const unitIndex = Selection.selectedUnits.findIndex((v) => v === unit);
			if (unitIndex) {
				Selection.selectedUnits.remove(unitIndex);
			}
		});
	}
}
