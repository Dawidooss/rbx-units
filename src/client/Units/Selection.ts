import { ContextActionService, Players, RunService, UserInputService, Workspace } from "@rbxts/services";
import GetGuiInset from "../../shared/GuiInset";
import Input from "../Input";
import HUD from "./HUD";
import Selectable, { SelectionType } from "./Selectable";
import Utils from "shared/Utils";
import ClientGameStore from "client/DataStore/ClientGameStore";
import ClientUnitsStore from "client/DataStore/ClientUnitsStore";

const player = Players.LocalPlayer;
const playerGui = player.WaitForChild("PlayerGui") as PlayerGui;
const camera = Workspace.CurrentCamera!;

export enum SelectionMethod {
	Box,
	Single,
	None,
}

const gameStore = ClientGameStore.Get();
const unitsStore = gameStore.GetStore("UnitsStore") as ClientUnitsStore;

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
		const mouseLocation = UserInputService.GetMouseLocation().sub(new Vector2(0, GetGuiInset()));

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
			for (const unit of unitsStore.GetUnitsInstances()) {
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
					units.add(unit);
				}
			}
		} else if (Selection.selectionType === SelectionMethod.Single) {
			const result = Utils.GetMouseHit();
			if (!result || !result.Instance) return units;

			const unit = unitsStore.cache.get(result.Instance.Parent?.Name || "");
			if (!unit) return units;
		}

		return units;
	}

	private static Update() {
		const mouseLocation = UserInputService.GetMouseLocation().sub(new Vector2(0, GetGuiInset()));
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

			unit.Select(SelectionType.Selected);
			Selection.selectedUnits.add(unit);
		}
	}

	public static DeselectUnits(units: Set<Selectable>) {
		units.forEach((unit) => {
			unit.Select(SelectionType.None);
			const deleted = Selection.selectedUnits.delete(unit);
		});
	}
}
