import { ReplicatedFirst, RunService, Workspace } from "@rbxts/services";
import Movement from "./Movement";
import { MovementCircle } from "./UnitsRegroup";

export default class Unit {
	public id: string;
	public unitName: string;
	public model: UnitModel;
	public targetPosition: Vector3;
	public selectionType = UnitSelectionType.None;

	public selectionRadius = 1.5;

	private selectionCircle: SelectionCirle;
	private movementCircle: MovementCircle;

	constructor(id: string, unitName: string, position: Vector3) {
		this.id = id;
		this.unitName = unitName;
		this.targetPosition = position;

		this.model = ReplicatedFirst.Units[unitName].Clone();
		this.model.Name = this.id;
		this.model.PivotTo(new CFrame(position));

		// selection circle
		this.selectionCircle = ReplicatedFirst.FindFirstChild("SelectionCircle")!.Clone() as SelectionCirle;
		this.selectionCircle.Size = new Vector3(
			this.selectionCircle.Size.X,
			this.selectionRadius * 2,
			this.selectionRadius * 2,
		);
		this.selectionCircle.PivotTo(this.model.GetPivot().mul(CFrame.Angles(0, 0, math.pi / 2)));
		this.selectionCircle.Parent = this.model;

		// movement circle
		this.movementCircle = ReplicatedFirst.FindFirstChild("MovementCircle")!.Clone() as MovementCircle;
		this.movementCircle.Beam.Attachment1 = this.selectionCircle.Attachment;
		this.movementCircle.Arrow.Destroy();

		const weld = new Instance("WeldConstraint", this.selectionCircle);
		weld.Part0 = this.selectionCircle;
		weld.Part1 = this.model.HumanoidRootPart;

		this.Select(UnitSelectionType.None);
	}

	public Select(selectionType: UnitSelectionType) {
		this.selectionType = selectionType;

		this.Update();
		if (selectionType === UnitSelectionType.Selected) {
			RunService.BindToRenderStep(`unit-${this.id}-selectionUpdate`, 1, () => this.Update());
		} else {
			RunService.UnbindFromRenderStep(`unit-${this.id}-selectionUpdate`);
		}
	}

	public Move(position: Vector3) {
		this.targetPosition = position;
		this.model.Humanoid.MoveTo(position);
		this.Update();
		// TODO REWORK IT
	}

	public Update() {
		const selected = this.selectionType === UnitSelectionType.Selected;

		this.selectionCircle.Transparency = this.selectionType === UnitSelectionType.None ? 1 : 0.2;
		this.selectionCircle.Color = selected ? Color3.fromRGB(143, 142, 145) : Color3.fromRGB(70,70,70); //prettier-ignore

		const toTargetPositionDistance = this.selectionCircle.Position.sub(this.targetPosition).Magnitude;
		const movementCircleVisible = toTargetPositionDistance > 3 && selected;

		this.movementCircle.PivotTo(
			new CFrame(this.targetPosition, this.selectionCircle.Position).mul(
				CFrame.Angles(math.pi, -math.pi / 2, math.pi / 2),
			),
		);
		this.movementCircle.Beam.TextureLength = toTargetPositionDistance / 2.5;
		this.movementCircle.Parent = movementCircleVisible ? this.model : undefined;
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
