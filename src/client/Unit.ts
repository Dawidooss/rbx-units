import { ReplicatedFirst, RunService, Workspace } from "@rbxts/services";

export default class Unit {
	public id: string;
	public unitName: string;
	public model: UnitModel;
	public selectionType = UnitSelectionType.None;

	public selectionRadius = 1.5;
	public position: Vector3;

	private selectionCircle: SelectionCirle;

	constructor(id: string, unitName: string, position: Vector3) {
		this.id = id;
		this.position = position;
		this.unitName = unitName;

		this.model = ReplicatedFirst.Units[unitName].Clone();
		this.model.Name = this.id;

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
		this.UpdatePosition();
	}

	public Select(selectionType: UnitSelectionType) {
		this.selectionCircle.Transparency = selectionType === UnitSelectionType.None ? 1 : 0.2;
		// this.selectionCircle.Highlight.Enabled = selectionType === UnitSelectionType.Selected;
		this.selectionCircle.Color = selectionType === UnitSelectionType.Selected ? Color3.fromRGB(143, 142, 145) : Color3.fromRGB(70,70,70); //prettier-ignore

		this.selectionType = selectionType;
	}

	public UpdatePosition() {
		this.model.PivotTo(new CFrame(this.position));
	}

	public Move(targetCFrame: CFrame) {
		this.model.Humanoid.MoveTo(targetCFrame.Position);
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
};
