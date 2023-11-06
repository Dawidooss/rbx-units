import { RunService, Workspace } from "@rbxts/services";
import Utils from "../Utils";
import Unit from "./Unit";
import Formation from "./Formations/Formation";
import Input from "client/Input";
import Selection from "./Selection";
import Normal from "./Formations/Normal";
import Circle from "./Formations/Circle";

const camera = Workspace.CurrentCamera!;

export default abstract class UnitsAction {
	public static enabled = false;

	private static units: Unit[];
	private static formationSelected: Formation;
	private static spreadLimits: [number, number];
	private static cframe = new CFrame();
	private static startPosition = new Vector3();
	private static spread = 0;

	public static Init() {
		let endCallback: Callback | undefined;
		Input.Bind(Enum.UserInputType.MouseButton2, Enum.UserInputState.Begin, () => {
			const units = Selection.selectedUnits;
			const formation = new Circle();
			endCallback = UnitsAction.GetActionCFrame(units, formation, (cframe: CFrame, spread: number) => {
				UnitsAction.MoveUnits(units, cframe, formation, spread);
				formation.Destroy();
			});
		});

		Input.Bind(Enum.UserInputType.MouseButton2, Enum.UserInputState.End, () => {
			endCallback?.();
		});
	}

	public static GetActionCFrame(
		units: Unit[],
		formation: Formation,
		resultCallback: (cframe: CFrame, spread: number) => void,
	): Callback {
		UnitsAction.units = units;
		UnitsAction.formationSelected = formation;
		UnitsAction.spreadLimits = formation.GetSpreadLimits(units.size());
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
		if (UnitsAction.startPosition === mouseHitResult.Position) {
			UnitsAction.cframe = new CFrame(UnitsAction.startPosition);
		} else {
			UnitsAction.cframe = new CFrame(UnitsAction.startPosition, groundedMousePosition);
		}

		UnitsAction.formationSelected.VisualisePositions(UnitsAction.units, UnitsAction.cframe, spread);
	}

	public static async MoveUnits(units: Array<Unit>, cframe: CFrame, formation: Formation, spread: number) {
		const cframes = formation.GetCFramesInFormation(units.size(), cframe, spread);
		let distancesArray = new Array<[Unit, number, CFrame]>();

		for (const unit of units) {
			const pivotPosition = unit.model.GetPivot().Position;
			for (const cframe of cframes) {
				const distance = pivotPosition.sub(cframe.Position).Magnitude;
				distancesArray.push([unit, distance, cframe]);
			}
		}

		distancesArray.sort((a, b) => {
			return a[1] < b[1];
		});

		while (distancesArray.size() > 0) {
			const closest = distancesArray[0];
			closest[0].Move(closest[2]);

			const newDistancesArray = new Array<[Unit, number, CFrame]>();
			distancesArray.forEach((v) => {
				if (v[0] !== closest[0] && v[2] !== closest[2]) {
					newDistancesArray.push(v);
				}
			});
			distancesArray = newDistancesArray;
		}
	}
}
