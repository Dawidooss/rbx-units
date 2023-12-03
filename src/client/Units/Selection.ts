import { ContextActionService, RunService, UserInputService } from "@rbxts/services";
import GetGuiInset from "../../shared/GuiInset";
import Utils from "shared/Utils";
import Unit from "./Unit";
import { SelectionType } from "shared/types";
import Input from "client/Input";
import { camera, player } from "client/Instances";
import GUI from "./GUI";
import UnitsStore from "client/DataStore/UnitsStore";
import GameStore from "client/DataStore/GameStore";
import Replicator from "client/DataStore/Replicator";
import ReplicationQueue from "shared/ReplicationQueue";
import bit from "shared/bit";

export enum SelectionMethod {
	Box,
	Single,
	None,
}

const input = Input.Get();

const gameStore = GameStore.Get();
const unitsStore = gameStore.GetStore("UnitsStore") as UnitsStore;
const gui = GUI.Get();

const replicator = Replicator.Get();

export default class Selection {
	public boxSize = new Vector2();
	public holding = false;
	public hoveringUnits = new Set<Unit>();
	public selectedUnits = new Set<Unit>();

	private selectionType = SelectionMethod.None;
	private boxCornerPosition = new Vector2();

	private static instance: Selection;
	constructor() {
		Selection.instance = this;

		ContextActionService.BindAction(
			"Selection",
			(actionName, state, input) => this.SetHolding(state === Enum.UserInputState.Begin),
			false,
			Enum.UserInputType.MouseButton1,
		);

		RunService.BindToRenderStep("Selection", Enum.RenderPriority.Last.Value + 1, () => this.Update());
	}

	private SetHolding(state: boolean) {
		const mouseLocation = UserInputService.GetMouseLocation().sub(new Vector2(0, GetGuiInset()));

		this.holding = state;
		this.boxCornerPosition = new Vector2(mouseLocation.X, mouseLocation.Y);

		// select all hovering units
		if (!state) {
			const shiftHold = input.IsButtonHolding(Enum.KeyCode.LeftShift);
			const ctrlHold = input.IsButtonHolding(Enum.KeyCode.LeftControl);

			if (!shiftHold && !ctrlHold) {
				this.ClearSelectedUnits();
			}

			if (ctrlHold) {
				this.DeselectUnits(this.hoveringUnits);
			} else {
				this.SelectUnits(this.hoveringUnits);
			}
		}
	}

	private FindHoveringUnits(): Set<Unit> {
		const units = new Set<Unit>();

		if (this.selectionType === SelectionMethod.Box) {
			for (const [unitId, unit] of unitsStore.cache) {
				const position = unit.GetPosition();
				const screenPosition = camera.WorldToScreenPoint(position)[0];

				if (
					screenPosition.X >=
						gui.hud.SelectionBox.Position.X.Offset - math.abs(gui.hud.SelectionBox.Size.X.Offset / 2) &&
					screenPosition.X <=
						gui.hud.SelectionBox.Position.X.Offset + math.abs(gui.hud.SelectionBox.Size.X.Offset / 2) &&
					screenPosition.Y >=
						gui.hud.SelectionBox.Position.Y.Offset - math.abs(gui.hud.SelectionBox.Size.Y.Offset / 2) &&
					screenPosition.Y <=
						gui.hud.SelectionBox.Position.Y.Offset + math.abs(gui.hud.SelectionBox.Size.Y.Offset / 2)
				) {
					units.add(unit);
				}
			}
		} else if (this.selectionType === SelectionMethod.Single) {
			const result = Utils.GetMouseHit();
			if (!result || !result.Instance) return units;

			const unitId = tonumber(result.Instance.Parent?.Name);
			if (!unitId) return units;
			const unit = unitsStore.cache.get(unitId);
			if (!unit) return units;
		}

		return units;
	}

	private Update() {
		const mouseLocation = UserInputService.GetMouseLocation().sub(new Vector2(0, GetGuiInset()));
		const hoveringUnits = this.FindHoveringUnits();

		const boxSize = this.boxCornerPosition!.sub(mouseLocation);
		const middle = this.boxCornerPosition!.sub(boxSize.div(2));

		// define if curently is box selecting or selecting single unit by just hovering
		this.selectionType = boxSize.Magnitude > 3 && this.holding ? SelectionMethod.Box : SelectionMethod.Single;
		gui.hud.SelectionBox.Visible = this.selectionType === SelectionMethod.Box && this.holding;

		// update selectionBox ui wether
		if (this.selectionType === SelectionMethod.Box) {
			this.selectionType = boxSize.Magnitude > 3 ? SelectionMethod.Box : SelectionMethod.Single;
			this.boxSize = boxSize;

			gui.hud.SelectionBox.Size = UDim2.fromOffset(boxSize.X, boxSize.Y);
			gui.hud.SelectionBox.Position = UDim2.fromOffset(middle.X, middle.Y);
		}
		gui.hud.SelectionBox.Visible = this.selectionType === SelectionMethod.Box;

		// unhover old units
		this.hoveringUnits.forEach((unit) => {
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

		this.hoveringUnits = hoveringUnits;
	}

	public ClearSelectedUnits() {
		for (const unit of this.selectedUnits) {
			unit.Select(SelectionType.None);
		}
		this.selectedUnits.clear();
	}

	public SelectUnits(units: Set<Unit>) {
		const queue = new ReplicationQueue();

		for (const unit of units) {
			if (this.selectedUnits.size() >= 100) return;
			if (this.selectedUnits.has(unit)) return;

			if (unit.playerId !== player.UserId) continue;

			// TEMPORARY
			unit.health -= 10;
			queue.Add("update-unit-heal", (buffer) => {
				buffer.writeBits(...bit.ToBits(unit.id, 12));
				buffer.writeBits(...bit.ToBits(unit.health, 7));
				return buffer;
			});

			unit.Select(SelectionType.Selected);
			this.selectedUnits.add(unit);
		}

		replicator.Replicate(queue);
	}

	public DeselectUnits(units: Set<Unit>) {
		units.forEach((unit) => {
			unit.Select(SelectionType.None);
			const deleted = this.selectedUnits.delete(unit);
		});
	}

	public static Get() {
		return Selection.instance || new Selection();
	}
}
