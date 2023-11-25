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

	public movingTo = false;
	public moveToTries = 0;
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
			// const groundedCurrentWaypoint = new Vector3(
			// 	currentWaypoint.Position.X,
			// 	this.beamAttachment.WorldPosition.Y,
			// 	currentWaypoint.Position.Z,
			// );
			const distanceToTargetPosition = this.data.targetPosition.sub(this.model.GetPivot().Position).Magnitude;
			if (distanceToTargetPosition < 1) {
				if (this.pathfinding.active) this.pathfinding.MoveToFinished(true);
				this.moveToTries = 0;
				this.movingTo = false;
				return;
			} else {
				this.moveToTries += 1;
			}

			if (this.moveToTries > 10) {
				warn(`UNIT MOVE TO: ${this.data.id} couldn't get to targetCFrame due to exceed moveToTries limit`);
				if (this.pathfinding.active) this.pathfinding.MoveToFinished(false);
				this.moveToTries = 0;
				this.movingTo = false;
				return;
			}

			this.MoveTo(this.data.targetPosition);
		});
	}

	public Select(selectionType: SelectionType) {
		this.selectionType = selectionType;

		this.UpdateVisuals();
		// if (selectionType === SelectionType.Selected) {
		// 	RunService.BindToRenderStep(`unit-${this.data.id}-selectionUpdate`, 1, () => this.Update());
		// } else {
		// 	RunService.UnbindFromRenderStep(`unit-${this.data.id}-selectionUpdate`);
		// }
	}

	public StartPathfinding(cframe: CFrame) {
		this.pathfinding.Start(cframe);
	}

	public MoveTo(position: Vector3) {
		this.data.targetPosition = position;
		this.data.movementStartTick = tick();
		// this.data.movementEndTick = ?????

		this.movingTo = true;
		this.model.Humanoid.MoveTo(position);
		this.pathfinding.EnableVisualisation(true);
	}

	public GetPosition(): Vector3 {
		return this.model.GetPivot().Position;
	}

	private UpdateVisuals() {
		const selected = this.selectionType === SelectionType.Selected;

		this.pathfinding.EnableVisualisation(selected);
		this.selectionCircle.Transparency = this.selectionType === SelectionType.None ? 1 : 0.2;
		this.selectionCircle.Color = selected ? Color3.fromRGB(143, 142, 145) : Color3.fromRGB(70, 70, 70);
	}

	private UpdatePhysics() {
		if (this.movingTo) {
			const distanceToCurrentWaypoint = this.data.targetPosition.sub(this.model.GetPivot().Position).Magnitude;

			if (distanceToCurrentWaypoint > 1 && this.model.Humanoid.GetState() !== Enum.HumanoidStateType.Running) {
				// during movement unit stopped and didn't reached target, try to MoveTo again
				this.MoveTo(this.data.targetPosition);
			}
		}
	}

	public Destroy() {}
}
