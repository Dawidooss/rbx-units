import { ReplicatedFirst } from "@rbxts/services";
import Unit from "./Unit";
import Movement from "client/Movement";
import UnitMovement from "./UnitMovement";

export default class MovementVisualisation {
	public unit: Unit;
	public unitMovement: UnitMovement;
	public enabled = false;

	private visualisation: ActionCircle;
	private visualisationPart: ActionCircle["Middle"];
	private beamAttachment: Attachment;

	constructor(unitMovement: UnitMovement) {
		this.unitMovement = unitMovement;
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
	}

	public SetPath() {}

	private Clear() {
		this.visualisation.Positions.ClearAllChildren();
	}

	// private Create() {
	// 	print("create visualisation");
	// 	this.Clear();
	// 	if (!this.active) return;

	// 	let previousVisualisationAtt = this.beamAttachment;

	// 	for (let waypointIndex = this.currentWaypointIndex; waypointIndex < this.waypoints.size(); waypointIndex++) {
	// 		const waypoint = this.waypoints[waypointIndex];
	// 		const toTargetCFrameDistance = previousVisualisationAtt.WorldPosition.sub(waypoint.Position).Magnitude;

	// 		const visualisationPart = this.visualisationPart.Clone();

	// 		const groundPositionResult = Utils.RaycastBottom(
	// 			waypoint.Position.add(new Vector3(0, 100, 0)),
	// 			[Workspace.TerrainParts],
	// 			Enum.RaycastFilterType.Include,
	// 		);
	// 		if (!groundPositionResult) continue;
	// 		const cframe = new CFrame(
	// 			groundPositionResult.Position,
	// 			groundPositionResult.Position.add(groundPositionResult.Normal),
	// 		).mul(CFrame.Angles(math.pi / 2, 0, 0));

	// 		visualisationPart.PivotTo(cframe);

	// 		visualisationPart.Beam.Attachment1 = previousVisualisationAtt;
	// 		visualisationPart.Beam.TextureLength = toTargetCFrameDistance;
	// 		visualisationPart.Name = `${this.pathId}#${waypointIndex}`;
	// 		visualisationPart.Transparency = waypointIndex === this.waypoints.size() - 1 ? 0 : 1;
	// 		visualisationPart.Parent = this.visualisation.Positions;

	// 		previousVisualisationAtt = visualisationPart.Attachment;
	// 	}
	// }

	// private Update() {
	// 	for (let child of this.visualisation.Positions.GetChildren()) {
	// 		if (child.Name.split("#")[0] !== this.pathId) {
	// 			this.Create();
	// 			return;
	// 		}

	// 		const waypointIndex = tonumber(child.Name.split("#")[1] as string)!;
	// 		if (waypointIndex < this.currentWaypointIndex) {
	// 			child.Destroy();
	// 			continue;
	// 		}

	// 		const visualisationPart = child as ActionCircle["Middle"];
	// 		const toTargetCFrameDistance = visualisationPart.Beam.Attachment0!.WorldPosition.sub(
	// 			visualisationPart.Beam.Attachment1!.WorldPosition,
	// 		).Magnitude;

	// 		if (waypointIndex === this.currentWaypointIndex) {
	// 			visualisationPart.Beam.Attachment1 = this.beamAttachment;
	// 		}

	// 		visualisationPart.Beam.TextureLength = toTargetCFrameDistance;
	// 	}
	// }
}
