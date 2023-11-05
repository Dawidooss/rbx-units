import { PathfindingService, ReplicatedFirst, RunService, Workspace } from "@rbxts/services";
import Pathfinding from "client/Pathfinding";

export default class Unit {
	public id: string;
	public unitName: string;
	public model: UnitModel;
	public selectionType = UnitSelectionType.None;
	public pathfinding: Pathfinding;
	public alignOrientation: AlignOrientation;
	public groundAttachment: Attachment;

	public selectionRadius = 1.5;

	private selectionCircle: SelectionCirle;

	constructor(id: string, unitName: string, position: Vector3) {
		this.id = id;
		this.unitName = unitName;

		this.model = ReplicatedFirst.Units[unitName].Clone();
		this.model.Name = this.id;
		this.model.PivotTo(new CFrame(position));
				
		// disabling not used humanoid states to save memory
		this.model.Humanoid.SetStateEnabled(Enum.HumanoidStateType.FallingDown, false);
		this.model.Humanoid.SetStateEnabled(Enum.HumanoidStateType.Radgoll, false);
		this.model.Humanoid.SetStateEnabled(Enum.HumanoidStateType.GettingUp, false);
		this.model.Humanoid.SetStateEnabled(Enum.HumanoidStateType.Jumping, false);
		this.model.Humanoid.SetStateEnabled(Enum.HumanoidStateType.Swimming, false);
		this.model.Humanoid.SetStateEnabled(Enum.HumanoidStateType.Freefall, false);
		this.model.Humanoid.SetStateEnabled(Enum.HumanoidStateType.Flying, false);
		this.model.Humanoid.SetStateEnabled(Enum.HumanoidStateType.Landed, false);
		this.model.Humanoid.SetStateEnabled(Enum.HumanoidStateType.Running, false);
		this.model.Humanoid.SetStateEnabled(Enum.HumanoidStateType.Climbing, false);
		this.model.Humanoid.SetStateEnabled(Enum.HumanoidStateType.Seated, false);
		this.model.Humanoid.SetStateEnabled(Enum.HumanoidStateType.PlatformStanding, false);
		this.model.Humanoid.SetStateEnabled(Enum.HumanoidStateType.Dead, false); // Enable this in case you want to use .Died event
			
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

		this.Select(UnitSelectionType.None);
	}

	public Select(selectionType: UnitSelectionType) {
		this.selectionType = selectionType;

		this.pathfinding.EnableVisualisation(selectionType === UnitSelectionType.Selected);
		this.Update();
		if (selectionType === UnitSelectionType.Selected) {
			RunService.BindToRenderStep(`unit-${this.id}-selectionUpdate`, 1, () => this.Update());
		} else {
			RunService.UnbindFromRenderStep(`unit-${this.id}-selectionUpdate`);
		}
	}

	public Move(cframe: CFrame) {
		this.pathfinding.Start(cframe);
		this.Update();
	}

	public Update() {
		const selected = this.selectionType === UnitSelectionType.Selected;

		this.selectionCircle.Transparency = this.selectionType === UnitSelectionType.None ? 1 : 0.2;
		this.selectionCircle.Color = selected ? Color3.fromRGB(143, 142, 145) : Color3.fromRGB(70,70,70); //prettier-ignore
	}

	public Destroy() {}
}

export class UnitData {
	constructor() {}
}

export enum UnitSelectionType {
	Selected,
	Hovering,
	None,
}

type SelectionCirle = BasePart & {
	Highlight: Highlight;
	Attachment: Attachment;
};
