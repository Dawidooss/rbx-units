import { ContextActionService, ReplicatedFirst, RunService, Workspace } from "@rbxts/services";
import Selection from "./Selection";
import Utils from "../Utils";
import Unit, { UnitSelectionType } from "./Unit";
import Formation from "./Formations/Formation";
import Normal from "./Formations/Normal";

const camera = Workspace.CurrentCamera!;

export default abstract class UnitsMovement {
	public static formationSelected = new Normal();

	private static actionCFramePromise: Promise<CFrame> | undefined;
	private static regroupPosition = new Vector3();

	private static circle: MovementCircle;
	private static arrow: MovementCircle["Arrow"];
	private static enabled = false;

	public static Init() {
		UnitsMovement.circle = ReplicatedFirst.WaitForChild("MovementCircle")!.Clone() as MovementCircle;
		UnitsMovement.arrow = UnitsMovement.circle.Arrow;
	}

	public static GetActionCFrame(formation: Formation, keycode: Enum.KeyCode): Promise {
		UnitsMovement.Enable(true);

		return new Promise<CFrame>((resolve, d) => {});
	}

	private static Enable(state: boolean) {
		if (Selection.selectedUnits.size() === 0) return;
		if (UnitsMovement.enabled === state) return;

		const mouseHitResult = Utils.GetMouseHit();
		if (!mouseHitResult) return;

		UnitsMovement.regroupPosition = mouseHitResult.Position;
		UnitsMovement.enabled = state;

		if (state) {
			RunService.BindToRenderStep("UnitsMovement", Enum.RenderPriority.Last.Value, () => UnitsMovement.Update());
		} else {
			RunService.UnbindFromRenderStep("UnitsMovement");
		}
	}

	private static Update() {
		const mouseHitResult = Utils.GetMouseHit();
		if (!mouseHitResult) return;

		const groundedMousePosition = new Vector3(
			mouseHitResult.Position.X,
			UnitsMovement.regroupPosition.Y,
			mouseHitResult.Position.Z,
		);

		const arrowLength = groundedMousePosition.sub(UnitsMovement.regroupPosition).Magnitude;
		const fixedArrowLength = math.clamp(arrowLength, 2, 12);

		if (arrowLength > 2) {
			UnitsMovement.circle.PivotTo(new CFrame(UnitsMovement.regroupPosition, mouseHitResult.Position));
		} else {
			let medianPosition = new Vector3();
			Selection.selectedUnits.forEach((unit) => {
				medianPosition = medianPosition.add(unit.model.GetPivot().Position);
			});
			UnitsMovement.circle.PivotTo(
				new CFrame(UnitsMovement.regroupPosition, medianPosition.div(Selection.selectedUnits.size())).mul(
					CFrame.Angles(0, math.pi, 0),
				),
			);
		}

		UnitsMovement.circle.Parent = camera;

		const arrowMiddle = new CFrame(UnitsMovement.regroupPosition, groundedMousePosition).mul(
			new CFrame(0, 0, -fixedArrowLength / 2),
		).Position;

		UnitsMovement.arrow.Parent = arrowLength < 2 ? undefined : UnitsMovement.circle;

		UnitsMovement.arrow.PivotTo(new CFrame(arrowMiddle, UnitsMovement.regroupPosition));
		UnitsMovement.arrow.Length.Size = new Vector3(
			fixedArrowLength,
			UnitsMovement.arrow.Length.Size.Y,
			UnitsMovement.arrow.Length.Size.Z,
		);

		UnitsMovement.arrow.Length.Attachment.CFrame = new CFrame(fixedArrowLength / 2, 0, 0);
		UnitsMovement.arrow.Left.PivotTo(UnitsMovement.arrow.Length.Attachment.WorldCFrame);
		UnitsMovement.arrow.Right.PivotTo(UnitsMovement.arrow.Length.Attachment.WorldCFrame);

		UnitsMovement.spread = fixedArrowLength;

		// visualise positions
		const mainCFrame = UnitsMovement.circle.GetPivot();
		const cframes = UnitsMovement.formationSelected.GetCFramesInFormation(
			Selection.selectedUnits.size(),
			mainCFrame,
			UnitsMovement.spread,
		);

		UnitsMovement.circle.Positions.ClearAllChildren();
		cframes.forEach((cframe, i) => {
			if (i === 0) return;
			const positionPart = UnitsMovement.circle.Middle.Clone() as BasePart;
			positionPart.PivotTo(cframe);
			positionPart.Parent = UnitsMovement.circle.Positions;
		});
	}

	public static MoveGroup(units: Array<Unit>, cframe: CFrame, formation: Formation, spread: number) {
		const cframes = formation.GetCFramesInFormation(units.size(), cframe, spread);
		let distancesArray = new Array<[Unit, number, CFrame]>();

		units.forEach((unit) => {
			cframes.forEach((cframe) => {
				const distance = unit.model.GetPivot().Position.sub(cframe.Position).Magnitude;
				distancesArray.push([unit, distance, cframe]);
			});
		});

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
