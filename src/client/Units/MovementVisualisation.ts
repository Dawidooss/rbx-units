import { ReplicatedFirst, Workspace } from "@rbxts/services";
import Unit from "./Unit";
import Movement from "client/Movement";
import UnitMovement from "./UnitMovement";
import Utils from "shared/Utils";

export default class MovementVisualisation {
	public unit: Unit;
	public movement: UnitMovement;
	public enabled = false;

	private visualisation: ActionCircle;
	private visualisationPart: ActionCircle["Middle"];
	private beamAttachment: Attachment;

	constructor(unitMovement: UnitMovement) {
		this.movement = unitMovement;
		this.unit = unitMovement.unit;

		this.visualisation = ReplicatedFirst.FindFirstChild("NormalAction")!.Clone() as ActionCircle;
		this.visualisationPart = this.visualisation.Middle;

		this.visualisation.Name = "PathVisualisation";
		this.visualisation.Parent = this.unit.model;
		this.visualisation.Arrow.Destroy();
		this.visualisationPart.Parent = undefined;

		this.beamAttachment = new Instance("Attachment");
		this.beamAttachment.Parent = this.unit.model.HumanoidRootPart;
		this.beamAttachment.WorldCFrame = this.unit.model.GetPivot().mul(CFrame.Angles(0, math.pi, math.pi / 2));
	}

	public Enable(state: boolean) {
		this.enabled = state;

		this.Update();
	}

	private Clear() {
		this.visualisation.Positions.ClearAllChildren();
	}

	private Update() {
		this.Clear();
		if (!this.enabled) return;

		let previousVisualisationAtt = this.beamAttachment;

		for (let pathIndex = 0; pathIndex < this.movement.path.size(); pathIndex++) {
			const position = this.movement.path[pathIndex];
			const length = previousVisualisationAtt.WorldPosition.sub(position).Magnitude;

			const visualisationPart = this.visualisationPart.Clone();

			const groundPositionResult = Utils.RaycastBottom(
				position.add(new Vector3(0, 100, 0)),
				[Workspace.TerrainParts],
				Enum.RaycastFilterType.Include,
			);
			if (!groundPositionResult) continue;
			const cframe = new CFrame(
				groundPositionResult.Position,
				groundPositionResult.Position.add(groundPositionResult.Normal),
			).mul(CFrame.Angles(math.pi / 2, 0, 0));

			visualisationPart.PivotTo(cframe);

			visualisationPart.Beam.Attachment1 = previousVisualisationAtt;
			visualisationPart.Beam.TextureLength = length;
			visualisationPart.Transparency = pathIndex === this.movement.path.size() - 1 ? 0 : 1;
			visualisationPart.Parent = this.visualisation.Positions;

			previousVisualisationAtt = visualisationPart.Attachment;
		}
	}
}
