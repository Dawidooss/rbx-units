import { ContextActionService, ReplicatedFirst, RunService, Workspace } from "@rbxts/services";
import Selection from "./Selection";
import Utils from "./Utils";
import UnitsGroup, { Formation } from "./UnitsGroup";
import { UnitSelectionType } from "./Unit";

const camera = Workspace.CurrentCamera!;

export default abstract class UnitsRegroup {
	private static circle: MovementCircle;
	private static arrow: MovementCircle["Arrow"];
	private static regroupPosition = new Vector3();
	private static enabled = false;
	private static rotation = 0;
	private static spread = 2;

	public static Init() {
		UnitsRegroup.circle = ReplicatedFirst.WaitForChild("MovementCircle")!.Clone() as MovementCircle;
		UnitsRegroup.arrow = UnitsRegroup.circle.Arrow;

		// handle if LMB pressed and relesed
		ContextActionService.BindAction(
			"unitsActions",
			(actionName, state, input) => UnitsRegroup.Enable(state === Enum.UserInputState.Begin),
			false,
			Enum.UserInputType.MouseButton2,
		);
	}

	private static Regroup() {
		UnitsGroup.Move(
			Selection.selectedUnits,
			UnitsRegroup.circle.GetPivot().Position,
			Formation.Normal,
			UnitsRegroup.rotation,
			UnitsRegroup.spread,
		);
	}

	private static Enable(state: boolean) {
		if (Selection.selectedUnits.size() === 0) return;
		if (UnitsRegroup.enabled === state) return;

		const mouseHitResult = Utils.GetMouseHit();
		if (!mouseHitResult) return;

		UnitsRegroup.regroupPosition = mouseHitResult.Position;
		UnitsRegroup.enabled = state;

		if (state) {
			RunService.BindToRenderStep("UnitsRegroup", Enum.RenderPriority.Last.Value, () => UnitsRegroup.Update());
		} else {
			UnitsRegroup.Regroup();
			RunService.UnbindFromRenderStep("UnitsRegroup");
			UnitsRegroup.circle.Parent = undefined;
		}
	}

	private static Update() {
		const mouseHitResult = Utils.GetMouseHit();
		if (!mouseHitResult) return;

		const groundedMousePosition = new Vector3(
			mouseHitResult.Position.X,
			UnitsRegroup.regroupPosition.Y,
			mouseHitResult.Position.Z,
		);

		UnitsRegroup.circle.PivotTo(new CFrame(UnitsRegroup.regroupPosition).mul(CFrame.Angles(0, 0, -math.pi / 2)));
		UnitsRegroup.circle.Parent = camera;

		const arrowLength = groundedMousePosition.sub(UnitsRegroup.regroupPosition).Magnitude;
		const fixedArrowLength = math.clamp(arrowLength, 4, 12);

		const arrowMiddle = new CFrame(UnitsRegroup.regroupPosition, groundedMousePosition).mul(
			new CFrame(0, 0, -fixedArrowLength / 2),
		).Position;

		UnitsRegroup.arrow.Parent = arrowLength < 3 ? undefined : UnitsRegroup.circle;

		UnitsRegroup.arrow.PivotTo(new CFrame(arrowMiddle, UnitsRegroup.regroupPosition));
		UnitsRegroup.arrow.Length.Size = new Vector3(
			fixedArrowLength,
			UnitsRegroup.arrow.Length.Size.Y,
			UnitsRegroup.arrow.Length.Size.Z,
		);

		UnitsRegroup.arrow.Length.Attachment.CFrame = new CFrame(fixedArrowLength / 2, 0, 0);
		UnitsRegroup.arrow.Left.PivotTo(UnitsRegroup.arrow.Length.Attachment.WorldCFrame);
		UnitsRegroup.arrow.Right.PivotTo(UnitsRegroup.arrow.Length.Attachment.WorldCFrame);

		UnitsRegroup.rotation = new CFrame(UnitsRegroup.regroupPosition, groundedMousePosition).ToOrientation()[1];
		UnitsRegroup.spread = fixedArrowLength;

		// visualise positions
		const positions = UnitsGroup.GetPositionsInFormation(
			Selection.selectedUnits.size(),
			UnitsRegroup.circle.GetPivot().Position,
			Formation.Normal,
			UnitsRegroup.rotation,
			UnitsRegroup.spread,
		);

		UnitsRegroup.circle.Positions.ClearAllChildren();
		positions.forEach((position, i) => {
			if (i === 0) return;
			const positionPart = UnitsRegroup.circle.Middle.Clone() as BasePart;
			positionPart.PivotTo(new CFrame(position).mul(CFrame.Angles(0, 0, math.pi / 2)));
			positionPart.Parent = UnitsRegroup.circle.Positions;
		});
	}
}

export type MovementCircle = Model & {
	Positions: Model;
	Beam: Beam;
	Arrow: Model & {
		Length: BasePart & {
			Attachment: Attachment;
		};
		Left: BasePart;
		Right: BasePart;
	};
	Middle: BasePart & {
		Attachment: Attachment;
	};
};
