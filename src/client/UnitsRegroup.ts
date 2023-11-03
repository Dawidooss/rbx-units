import { ContextActionService, ReplicatedFirst, RunService, Workspace } from "@rbxts/services";
import Selection from "./Selection";
import Utils from "./Utils";
import UnitsGroup, { Formation } from "./UnitsGroup";

const camera = Workspace.CurrentCamera!;

export default abstract class UnitsRegroup {
	private static arrow: MovementArrow;
	private static regroupPosition = new Vector3();
	private static enabled = false;

	public static Init() {
		UnitsRegroup.arrow = ReplicatedFirst.WaitForChild("MovementArrow")!.Clone() as MovementArrow;

		// handle if LMB pressed and relesed
		ContextActionService.BindAction(
			"unitsActions",
			(actionName, state, input) => UnitsRegroup.Enable(state === Enum.UserInputState.Begin),
			false,
			Enum.UserInputType.MouseButton2,
		);
	}

	private static Regroup() {
		print(UnitsRegroup.arrow.GetPivot().Position);
		UnitsGroup.Move(Selection.selectedUnits, UnitsRegroup.arrow.GetPivot().Position, Formation.Normal);
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
			UnitsRegroup.arrow.Parent = undefined;
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

		UnitsRegroup.arrow.PivotTo(new CFrame(UnitsRegroup.regroupPosition).mul(CFrame.Angles(0, 0, -math.pi / 2)));
		UnitsRegroup.arrow.Parent = camera;

		const arrowLength = math.clamp(groundedMousePosition.sub(UnitsRegroup.regroupPosition).Magnitude, 0.5, 8);
		const arrowMiddle = new CFrame(UnitsRegroup.regroupPosition, groundedMousePosition).mul(
			new CFrame(0, 0, -arrowLength / 2),
		).Position;

		UnitsRegroup.arrow.Arrow.PivotTo(new CFrame(arrowMiddle, UnitsRegroup.regroupPosition));
		UnitsRegroup.arrow.Arrow.Length.Size = new Vector3(
			arrowLength,
			UnitsRegroup.arrow.Arrow.Length.Size.Y,
			UnitsRegroup.arrow.Arrow.Length.Size.Z,
		);

		UnitsRegroup.arrow.Arrow.Length.Attachment.CFrame = new CFrame(arrowLength / 2, 0, 0);
		UnitsRegroup.arrow.Arrow.Left.PivotTo(UnitsRegroup.arrow.Arrow.Length.Attachment.WorldCFrame);
		UnitsRegroup.arrow.Arrow.Right.PivotTo(UnitsRegroup.arrow.Arrow.Length.Attachment.WorldCFrame);
	}
}

type MovementArrow = Model & {
	Arrow: Model & {
		Length: BasePart & {
			Attachment: Attachment;
		};
		Left: BasePart;
		Right: BasePart;
	};
	Middle: BasePart;
};
