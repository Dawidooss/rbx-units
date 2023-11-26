import { PathfindingService, ReplicatedFirst, RunService, Workspace } from "@rbxts/services";
import Pathfinding from "client/Units/Pathfinding";
import { UnitData } from "shared/DataStore/Stores/UnitsStore";
import { SelectionType } from "shared/types";

export default class Unit {
	public data: UnitData;
	public model: UnitModel;
	public pathfinding: Pathfinding;
	public alignOrientation: AlignOrientation;
	public groundAttachment: Attachment;

	public moving = false;
	private moveToTries = 0;
	private moveToFinishedCallback: Callback | undefined;

	public selectionType = SelectionType.None;
	public selectionRadius = 1.5;
	private selectionCircle: SelectionCirle;

	constructor(unitData: UnitData) {
		this.data = unitData;

		this.model = ReplicatedFirst.Units[this.data.type].Clone();
		this.model.Name = this.data.type;
		this.model.PivotTo(new CFrame(unitData.position));
		this.model.Parent = Workspace.WaitForChild("UnitsCache");

		// disabling not used humanoid states to save memory
		// this.model.Humanoid.SetStateEnabled(Enum.HumanoidStateType.FallingDown, false);
		// this.model.Humanoid.SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false);
		// this.model.Humanoid.SetStateEnabled(Enum.HumanoidStateType.GettingUp, false);
		// this.model.Humanoid.SetStateEnabled(Enum.HumanoidStateType.Jumping, false);
		// this.model.Humanoid.SetStateEnabled(Enum.HumanoidStateType.Swimming, false);
		// this.model.Humanoid.SetStateEnabled(Enum.HumanoidStateType.Freefall, false);
		// this.model.Humanoid.SetStateEnabled(Enum.HumanoidStateType.Flying, false);
		// this.model.Humanoid.SetStateEnabled(Enum.HumanoidStateType.Landed, false);
		// this.model.Humanoid.SetStateEnabled(Enum.HumanoidStateType.Running, false);
		// this.model.Humanoid.SetStateEnabled(Enum.HumanoidStateType.Climbing, false);
		// this.model.Humanoid.SetStateEnabled(Enum.HumanoidStateType.Seated, false);
		// this.model.Humanoid.SetStateEnabled(Enum.HumanoidStateType.PlatformStanding, false);
		// this.model.Humanoid.SetStateEnabled(Enum.HumanoidStateType.Dead, false); // Enable this in case you want to use .Died event

		this.groundAttachment = new Instance("Attachment");
		this.groundAttachment.Parent = this.model.HumanoidRootPart;
		this.groundAttachment.WorldCFrame = this.model.GetPivot();

		this.alignOrientation = new Instance("AlignOrientation", this.model.HumanoidRootPart);
		this.alignOrientation.Mode = Enum.OrientationAlignmentMode.OneAttachment;
		this.alignOrientation.Attachment0 = this.groundAttachment;
		this.alignOrientation.MaxTorque = 1000000;

		this.pathfinding = new Pathfinding(this);

		// selection circle
		this.selectionCircle = ReplicatedFirst.FindFirstChild("SelectionCircle")!.Clone() as SelectionCirle;
		this.selectionCircle.Size = new Vector3(
			this.selectionCircle.Size.X,
			this.selectionRadius * 2,
			this.selectionRadius * 2,
		);
		this.selectionCircle.PivotTo(this.model.GetPivot().mul(CFrame.Angles(0, 0, math.pi / 2)));
		this.selectionCircle.Parent = this.model;

		const weld = new Instance("WeldConstraint", this.selectionCircle);
		weld.Part0 = this.selectionCircle;
		weld.Part1 = this.model.HumanoidRootPart;

		this.Select(SelectionType.None);

		this.model.Humanoid.MoveToFinished.Connect((reached) => {
			const modelPosition = this.model.GetPivot().Position;
			const groundedTargetPosition = new Vector3(
				this.data.targetPosition.X,
				modelPosition.Y,
				this.data.targetPosition.Z,
			);
			const distanceToTargetPosition = groundedTargetPosition.sub(modelPosition).Magnitude;

			if (distanceToTargetPosition < 2) {
				// unit reached target
				this.MoveToEnded(true);
				return;
			} else {
				this.moveToTries += 1;
			}

			this.MoveTo(this.data.targetPosition, this.moveToFinishedCallback);
		});
	}

	public Select(selectionType: SelectionType) {
		this.selectionType = selectionType;

		this.UpdateVisuals();
	}

	public StartPathfinding(position: Vector3 | PathWaypoint[]) {
		if (typeOf(position) === "Vector3") {
			this.pathfinding.Start(position as Vector3);
		} else {
			this.pathfinding.StartWithWaypoints(position as PathWaypoint[]);
		}
	}

	public MoveTo(position: Vector3, endCallback?: Callback) {
		this.moveToTries += this.data.targetPosition === position ? 1 : 0;

		if (this.moveToTries > 10) {
			warn(`UNIT MOVE TO: ${this.data.id} couldn't get to targetCFrame due to exceed moveToTries limit`);
			this.MoveToEnded(false);
			return;
		}
		this.moveToFinishedCallback = endCallback;
		this.moving = true;

		this.data.targetPosition = position;
		this.data.movementStartTick = tick();

		this.model.Humanoid.MoveTo(position);

		RunService.UnbindFromRenderStep(`${this.data.id}-physics`);
		RunService.BindToRenderStep(`${this.data.id}-physics`, Enum.RenderPriority.First.Value, () =>
			this.UpdatePhysics(),
		);
	}

	private MoveToEnded(success: boolean) {
		this.moveToFinishedCallback?.(success);
		this.moveToFinishedCallback = undefined;
		this.moveToTries = 0;
		this.moving = false;
		RunService.UnbindFromRenderStep(`${this.data.id}-physics`);
	}

	public GetPosition(): Vector3 {
		return this.model.GetPivot().Position;
	}

	private UpdateVisuals() {
		const selected = this.selectionType === SelectionType.Selected;

		this.selectionCircle.Transparency = this.selectionType === SelectionType.None ? 1 : 0.2;
		this.selectionCircle.Color = selected ? Color3.fromRGB(143, 142, 145) : Color3.fromRGB(70, 70, 70);
	}

	private UpdatePhysics() {
		if (this.moving) {
			const distanceToCurrentWaypoint = this.data.targetPosition.sub(this.model.GetPivot().Position).Magnitude;

			if (distanceToCurrentWaypoint > 1 && this.model.Humanoid.GetState() !== Enum.HumanoidStateType.Running) {
				// during movement, unit stopped and didn't reached target, try to MoveTo again
				this.MoveTo(this.data.targetPosition, this.moveToFinishedCallback);
			}
		}
	}

	public Destroy() {}
}
