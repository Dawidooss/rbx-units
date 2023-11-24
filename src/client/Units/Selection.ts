import { ContextActionService, Players, RunService, UserInputService, Workspace } from "@rbxts/services";
import GetGuiInset from "../../shared/GuiInset";
import Input from "../Input";
import HUD from "./HUD";
import Utils from "shared/Utils";
import ClientGameStore from "client/DataStore/ClientGameStore";
import ClientUnitsStore from "client/DataStore/ClientUnitsStore";
import Unit from "./Unit";
import { SelectionType } from "shared/types";

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

const hud = HUD.Get();

export default abstract class Selection {
	private static selectionType = SelectionMethod.None;
	private static boxCornerPosition = new Vector2();
	public static boxSize = new Vector2();
	public static holding: boolean;

	public static hoveringUnits = new Set<Unit>();
	public static selectedUnits = new Set<Unit>();

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

	private static FindHoveringUnits(): Set<Unit> {
		const units = new Set<Unit>();

		if (Selection.selectionType === SelectionMethod.Box) {
			for (const unit of unitsStore.GetUnitsInstances()) {
				const pivot = unit.model.GetPivot();
				const screenPosition = camera.WorldToScreenPoint(pivot.Position)[0];

				if (
					screenPosition.X >=
						hud.gui.SelectionBox.Position.X.Offset - math.abs(hud.gui.SelectionBox.Size.X.Offset / 2) &&
					screenPosition.X <=
						hud.gui.SelectionBox.Position.X.Offset + math.abs(hud.gui.SelectionBox.Size.X.Offset / 2) &&
					screenPosition.Y >=
						hud.gui.SelectionBox.Position.Y.Offset - math.abs(hud.gui.SelectionBox.Size.Y.Offset / 2) &&
					screenPosition.Y <=
						hud.gui.SelectionBox.Position.Y.Offset + math.abs(hud.gui.SelectionBox.Size.Y.Offset / 2)
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
		hud.gui.SelectionBox.Visible = Selection.selectionType === SelectionMethod.Box && Selection.holding;

		// update selectionBox ui wether
		if (Selection.selectionType === SelectionMethod.Box) {
			Selection.selectionType = boxSize.Magnitude > 3 ? SelectionMethod.Box : SelectionMethod.Single;
			Selection.boxSize = boxSize;

			hud.gui.SelectionBox.Size = UDim2.fromOffset(boxSize.X, boxSize.Y);
			hud.gui.SelectionBox.Position = UDim2.fromOffset(middle.X, middle.Y);
		}
		hud.gui.SelectionBox.Visible = Selection.selectionType === SelectionMethod.Box;

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

	public static SelectUnits(units: Set<Unit>) {
		for (const unit of units) {
			if (this.selectedUnits.size() >= 100) return;
			if (this.selectedUnits.has(unit)) return;

			if (unit.data.playerId !== player.UserId) continue;
			unit.Select(SelectionType.Selected);
			Selection.selectedUnits.add(unit);
		}
	}

	public static DeselectUnits(units: Set<Unit>) {
		units.forEach((unit) => {
			unit.Select(SelectionType.None);
			const deleted = Selection.selectedUnits.delete(unit);
		});
	}
}
