import Maid from "@rbxts/maid";
import { ReplicatedFirst, Workspace } from "@rbxts/services";
import UnitMovement from "client/Units/UnitMovement";
import Pathfinding from "client/Units/Pathfinding";
import { SelectionType } from "shared/types";
import { UnitData } from "shared/DataStore/Stores/UnitsStoreBase";
import { player } from "client/Instances";
import GameStore from "client/DataStore/GameStore";
import UnitsStore from "client/DataStore/UnitsStore";

export default class Unit extends UnitData {
	public gameStore: GameStore;
	public unitsStore: UnitsStore;

	public model: UnitModel;
	public alignOrientation: AlignOrientation;
	public groundAttachment: Attachment;
	public maid = new Maid();

	public pathfinding: Pathfinding;
	public movement: UnitMovement;

	public selectionType = SelectionType.None;
	public selectionRadius = 1.5;
	private selectionCircle: SelectionCirle;

	constructor(
		gameStore: GameStore,
		id: string,
		name: string,
		position: Vector3,
		playerId?: number,
		path?: Vector3[],
	) {
		super(id, name, position, playerId || player.UserId, path);

		this.gameStore = gameStore;
		this.unitsStore = gameStore.GetStore("UnitsStore") as UnitsStore;

		this.model = ReplicatedFirst.Units[this.name].Clone();
		this.model.Name = this.name;
		this.model.PivotTo(new CFrame(this.position));
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

		this.movement = new UnitMovement(this);
		this.pathfinding = new Pathfinding(this);

		this.Select(SelectionType.None);
	}

	public Select(selectionType: SelectionType) {
		this.selectionType = selectionType;

		this.UpdateVisuals();
	}

	public UpdatePosition(position: Vector3) {
		this.model.PivotTo(new CFrame(position));
		this.position = position;
	}

	public GetPosition(): Vector3 {
		return this.model.GetPivot().Position;
	}

	private UpdateVisuals() {
		const selected = this.selectionType === SelectionType.Selected;
		this.movement.visualisation.Enable(selected);

		this.selectionCircle.Transparency = this.selectionType === SelectionType.None ? 1 : 0.2;
		this.selectionCircle.Color = selected ? Color3.fromRGB(143, 142, 145) : Color3.fromRGB(70, 70, 70);
	}

	public Destroy() {
		this.maid.DoCleaning();
	}
}
