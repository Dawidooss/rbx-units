import { ReplicatedFirst, Workspace } from "@rbxts/services";

export class UnitData {
	constructor() {}
}

export default class Unit {
	public id: string;
	public unitName: string;
	public model: UnitModel;
	public selected = false;

	public selectionRadius = 1.5;
	public position: Vector3;

	constructor(id: string, unitName: string, position: Vector3) {
		this.id = id;
		this.position = position;
		this.unitName = unitName;

		this.model = ReplicatedFirst.Units[unitName].Clone();
		this.model.Name = this.id;

		this.UpdatePosition();
	}

	public Select(state: boolean) {
		if (this.selected === state) return;
		if (state) {
			const selectionCircle = ReplicatedFirst.FindFirstChild("SelectionCircle")!.Clone() as BasePart;
			selectionCircle.Size = new Vector3(
				selectionCircle.Size.X,
				this.selectionRadius * 2,
				this.selectionRadius * 2,
			);
			selectionCircle.PivotTo(this.model.GetPivot().mul(CFrame.Angles(0, 0, math.pi / 2)));

			const weld = new Instance("WeldConstraint", selectionCircle);
			weld.Part0 = selectionCircle;
			weld.Part1 = this.model.HumanoidRootPart;

			selectionCircle.Parent = this.model;
		} else {
			this.model.FindFirstChild("SelectionCircle")?.Destroy();
		}
		this.selected = state;
	}

	public UpdatePosition() {
		this.model.PivotTo(new CFrame(this.position));
	}

	public Destroy() {}
}
