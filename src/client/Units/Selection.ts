import { ContextActionService, Debris, Players, RunService, UserInputService, Workspace } from "@rbxts/services";
import guiInset from "../GuiInset";
import UnitsManager from "./UnitsManager";
import Input from "../Input";
import HUD from "./HUD";
import Selectable, { SelectionType } from "./Selectable";
import UnitsGroup from "./UnitsGroup";

const player = Players.LocalPlayer;
const playerGui = player.WaitForChild("PlayerGui") as PlayerGui;
const camera = Workspace.CurrentCamera!;

export enum SelectionMethod {
	Box,
	Single,
	None,
}

export default abstract class Selection {
	private static selectionType = SelectionMethod.None;
	private static boxCornerPosition = new Vector2();
	public static boxSize = new Vector2();
	public static holding: boolean;

	public static hoveringUnits = new Set<Selectable>();
	public static selectedUnits = new Set<Selectable>();

	public static Init() {
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

	private static FindHoveringUnits(): Set<Selectable> {
		const units = new Set<Selectable>();

		if (Selection.selectionType === SelectionMethod.Box) {
			for (const [_, unit] of UnitsManager.GetUnits()) {
				const pivot = unit.model.GetPivot();
				const screenPosition = camera.WorldToScreenPoint(pivot.Position)[0];

				if (
					screenPosition.X >=
						HUD.gui.SelectionBox.Position.X.Offset - math.abs(HUD.gui.SelectionBox.Size.X.Offset / 2) &&
					screenPosition.X <=
						HUD.gui.SelectionBox.Position.X.Offset + math.abs(HUD.gui.SelectionBox.Size.X.Offset / 2) &&
					screenPosition.Y >=
						HUD.gui.SelectionBox.Position.Y.Offset - math.abs(HUD.gui.SelectionBox.Size.Y.Offset / 2) &&
					screenPosition.Y <=
						HUD.gui.SelectionBox.Position.Y.Offset + math.abs(HUD.gui.SelectionBox.Size.Y.Offset / 2)
				) {
					if (unit.group) {
						units.clear();
						units.add(unit.group);
						break;
					}
					units.add(unit);
				}
			}
		} else if (Selection.selectionType === SelectionMethod.Single) {
			const mouseLocation = UserInputService.GetMouseLocation();
			const mouseRay = camera.ViewportPointToRay(mouseLocation.X, mouseLocation.Y);

			const result = Workspace.Raycast(mouseRay.Origin, mouseRay.Direction.mul(10000));
			if (!result || !result.Instance) return units;

			const unit = UnitsManager.GetUnit(result.Instance.Parent?.Name || "");
			if (!unit) return units;

			units.add(unit.group || unit);
		}

		return units;
	}

	private static Update() {
		const mouseLocation = UserInputService.GetMouseLocation().sub(new Vector2(0, guiInset));
		const hoveringUnits = Selection.FindHoveringUnits();

		const boxSize = Selection.boxCornerPosition!.sub(mouseLocation);
		const middle = Selection.boxCornerPosition!.sub(boxSize.div(2));

		// define if curently is box selecting or selecting single unit by just hovering
		Selection.selectionType =
			boxSize.Magnitude > 3 && Selection.holding ? SelectionMethod.Box : SelectionMethod.Single;
		HUD.gui.SelectionBox.Visible = Selection.selectionType === SelectionMethod.Box && Selection.holding;

		// update selectionBox ui wether
		if (Selection.selectionType === SelectionMethod.Box) {
			Selection.selectionType = boxSize.Magnitude > 3 ? SelectionMethod.Box : SelectionMethod.Single;
			Selection.boxSize = boxSize;

			HUD.gui.SelectionBox.Size = UDim2.fromOffset(boxSize.X, boxSize.Y);
			HUD.gui.SelectionBox.Position = UDim2.fromOffset(middle.X, middle.Y);
		}
		HUD.gui.SelectionBox.Visible = Selection.selectionType === SelectionMethod.Box;

		// unhover old units
		Selection.hoveringUnits.forEach((unit) => {
			if (unit.selectionType === SelectionType.Hovering && !hoveringUnits.has(unit)) {
				unit.Select(SelectionType.None);
			}
		});

		// hover new units
		hoveringUnits.forEach((unit) => {
			if (unit.selectionType === SelectionType.None) {
				unit.Select(SelectionType.Hovering);
			}
		});

		Selection.hoveringUnits = hoveringUnits;
	}

	public static ClearSelectedUnits() {
		for (const unit of Selection.selectedUnits) {
			unit.Select(SelectionType.None);
		}
		Selection.selectedUnits.clear();
	}

	public static SelectUnits(units: Set<Selectable>) {
		for (const unit of units) {
			if (this.selectedUnits.size() >= 100) return;
			if (this.selectedUnits.has(unit)) return;

			if (unit instanceof UnitsGroup) {
				Selection.ClearSelectedUnits();

				unit.Select(SelectionType.Selected);
				Selection.selectedUnits.add(unit);
				// Selection.groupSelected = true;
				return; // only 1 selected group allowed
			} else {
				if (Selection.IsGroupSelected() && !(unit instanceof UnitsGroup)) {
					Selection.ClearSelectedUnits();
				}

				unit.Select(SelectionType.Selected);
				Selection.selectedUnits.add(unit);
				// Selection.groupSelected = false;
			}
		}
	}

	public static DeselectUnits(units: Set<Selectable>) {
		units.forEach((unit) => {
			unit.Select(SelectionType.None);
			const deleted = Selection.selectedUnits.delete(unit);

			// if (deleted && unit instanceof UnitsGroup) {
			// 	Selection.groupSelected = false;
			// }
		});
	}

	public static IsGroupSelected(): UnitsGroup | undefined {
		for (const unit of Selection.selectedUnits) {
			if (unit instanceof UnitsGroup) {
				return unit;
			}
			break;
		}
	}
}
