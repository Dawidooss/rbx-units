import { RunService, Workspace } from "@rbxts/services";
import Utils from "../Utils";
import Selectable from "./Selectable";
import Formation from "./Formations/Formation";
import Input from "client/Input";
import Selection from "./Selection";
import CircleFormation from "./Formations/CircleFormation";
import LineFormation from "./Formations/LineFormation";
import UnitsGroup from "./UnitsGroup";
import GroupFormation from "./Formations/GroupFormation";

const camera = Workspace.CurrentCamera!;

export default abstract class UnitsAction {
	public static enabled = false;

	private static units = new Set<Selectable>();
	private static formationSelected = new LineFormation();
	private static spreadLimits: [number, number];
	private static cframe = new CFrame();
	private static startPosition = new Vector3();
	private static spread = 0;

	public static Init() {
		let endCallback: Callback | undefined;
		Input.Bind(Enum.UserInputType.MouseButton2, Enum.UserInputState.Begin, () => {
			const units = Selection.selectedUnits;

			if (units.size() === 0) return;

			const groupSelected = Selection.IsGroupSelected();
			if (groupSelected) {
				UnitsAction.SetFormation(new GroupFormation(groupSelected));
			} else {
				UnitsAction.SetFormation(new LineFormation());
			}

			endCallback = UnitsAction.GetActionCFrame(units, (cframe: CFrame, spread: number) => {
				UnitsAction.MoveUnits(units, cframe, spread);
				this.formationSelected.Hide();
			});
		});

		Input.Bind(Enum.UserInputType.MouseButton2, Enum.UserInputState.End, () => {
			endCallback?.();
		});
	}

	public static SetFormation(formation: Formation) {
		const oldFormation = this.formationSelected;
		this.formationSelected = formation;

		oldFormation.Destroy();
	}

	public static GetActionCFrame(
		units: Set<Selectable>,
		resultCallback: (cframe: CFrame, spread: number) => void,
	): Callback {
		UnitsAction.units = units;
		UnitsAction.spreadLimits = UnitsAction.formationSelected.GetSpreadLimits(units.size());
		UnitsAction.Enable(true);

		const endCallback = () => {
			resultCallback(UnitsAction.cframe, UnitsAction.spread);
			UnitsAction.Enable(false);
		};

		return endCallback;
	}

	private static Enable(state: boolean) {
		if (UnitsAction.units.size() === 0) return;
		if (UnitsAction.enabled === state) return;

		if (state) {
			const mouseHitResult = Utils.GetMouseHit();
			if (!mouseHitResult) return;
			UnitsAction.startPosition = mouseHitResult.Position;
			RunService.BindToRenderStep("unitsAction", Enum.RenderPriority.Last.Value, () => UnitsAction.Update());
		} else {
			RunService.UnbindFromRenderStep("unitsAction");
		}

		UnitsAction.enabled = state;
	}

	private static Update() {
		const mouseHitResult = Utils.GetMouseHit();
		if (!mouseHitResult) return;

		const groundedMousePosition = new Vector3(
			mouseHitResult.Position.X,
			UnitsAction.startPosition.Y,
			mouseHitResult.Position.Z,
		);

		const arrowLength = groundedMousePosition.sub(UnitsAction.startPosition).Magnitude;
		const spread = math.clamp(arrowLength, UnitsAction.spreadLimits[0], UnitsAction.spreadLimits[1]);

		UnitsAction.spread = spread;
		// if (UnitsAction.startPosition === mouseHitResult.Position) {
		// 	let medianPosition = new Vector3();
		// 	UnitsAction.units.forEach((unit) => {
		// 		medianPosition = medianPosition.add(unit.model.GetPivot().Position);
		// 	});
		// 	medianPosition = medianPosition.div(UnitsAction.units.size());

		// 	const groundedMedianPosition = new Vector3(medianPosition.X, UnitsAction.startPosition.Y, medianPosition.Z);
		// 	UnitsAction.cframe = new CFrame(UnitsAction.startPosition, groundedMedianPosition).mul(
		// 		CFrame.Angles(0, math.pi, 0),
		// 	);
		// } else {
		// UnitsAction.cframe = new CFrame(UnitsAction.startPosition, groundedMousePosition);
		// }
		UnitsAction.cframe = new CFrame(UnitsAction.startPosition, groundedMousePosition);

		UnitsAction.formationSelected.VisualisePositions(UnitsAction.units, UnitsAction.cframe, spread);
	}

	public static async MoveUnits(units: Set<Selectable>, cframe: CFrame, spread: number) {
		const cframes = UnitsAction.formationSelected.GetCFramesInFormation(units, cframe, spread);
		const unitsAndCFrames = UnitsAction.formationSelected.MatchUnitsToCFrames(units, cframes, cframe);

		for (const [unit, cframe] of unitsAndCFrames) {
			unit.Move(cframe);
		}
	}
}
