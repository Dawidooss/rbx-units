import { HttpService, PathfindingService, Players, ReplicatedFirst, RunService, Workspace } from "@rbxts/services";
import Unit from "./Unit";
import Utils from "../../shared/Utils";
import ClientGameStore from "client/DataStore/ClientGameStore";
import BitBuffer from "@rbxts/bitbuffer";
import ClientReplicator from "client/DataStore/ClientReplicator";

const agentParams = {
	AgentCanJump: false,
	WaypointSpacing: math.huge,
	AgentRadius: 2,
};

const replicator = ClientReplicator.Get();

export default class Pathfinding {
	public active = false;
	public visualisationEnabled = false;
	public targetCFrame = new CFrame();

	private unit: Unit;
	private path: Path;
	private waypoints = new Array<PathWaypoint>();
	private currentWaypointIndex = 0;
	private pathId = "";

	private visualisation: ActionCircle;
	private visualisationPart: ActionCircle["Middle"];
	private beamAttachment: Attachment;

	constructor(unit: Unit) {
		this.unit = unit;

		this.path = PathfindingService.CreatePath(agentParams);

		this.visualisation = ReplicatedFirst.FindFirstChild("NormalAction")!.Clone() as ActionCircle;
		this.visualisationPart = this.visualisation.Middle;

		this.visualisation.Name = "PathVisualisation";
		this.visualisation.Parent = this.unit.model;
		this.visualisation.Arrow.Destroy();
		this.visualisationPart.Parent = undefined;

		this.beamAttachment = new Instance("Attachment");
		this.beamAttachment.Parent = this.unit.model.HumanoidRootPart;
		this.beamAttachment.WorldCFrame = this.unit.model.GetPivot().mul(CFrame.Angles(0, math.pi, math.pi / 2));

		this.path.Blocked.Connect((blockedWaypointIndex) => {
			wait();
			this.ComputePath();
		});
	}

	public async Start(targetCFrame: CFrame) {
		this.targetCFrame = targetCFrame;
		this.active = true;

		await this.ComputePath();

		this.CreateVisualisation();
	}
	public Stop(success: boolean) {
		if (success) {
			const orientation = this.targetCFrame.ToOrientation();
			this.unit.alignOrientation.CFrame = CFrame.Angles(0, orientation[1], 0);
		}

		this.active = false;
		this.waypoints = [];
		this.currentWaypointIndex = 0;

		this.ClearVisualisation();
	}

	public EnableVisualisation(state: boolean) {
		this.visualisationEnabled = state;
		this.CreateVisualisation();
	}

	public MoveToFinished(success: boolean) {
		if (success) {
			if (this.currentWaypointIndex === this.waypoints.size() - 1) {
				this.Stop(true);
				return;
			}

			this.currentWaypointIndex += 1;
		}
	}

	private async ComputePath() {
		const pathId = HttpService.GenerateGUID(false);
		this.pathId = pathId;

		this.path.ComputeAsync(this.unit.model.GetPivot().Position, this.targetCFrame.Position);

		if (this.path.Status !== Enum.PathStatus.Success && this.path.Status !== Enum.PathStatus.ClosestNoPath) {
			return;
		}

		this.waypoints = this.path.GetWaypoints();
		this.currentWaypointIndex = 1;
		this.pathId = HttpService.GenerateGUID(false);

		this.MoveToCurrentWaypoint();
	}

	private MoveToCurrentWaypoint() {
		const waypoint = this.waypoints[this.currentWaypointIndex];

		if (!waypoint) {
			this.Stop(true);
			return;
		}

		const orientation = new CFrame(this.unit.model.GetPivot().Position, waypoint.Position).ToOrientation();
		this.unit.alignOrientation.CFrame = CFrame.Angles(0, orientation[1], 0);

		if (this.visualisationEnabled) {
			this.UpdateVisualisation();
		}

		const buffer = BitBuffer();
		buffer.writeString(this.unit.data.id);
		buffer.writeVector3(waypoint.Position);
		buffer.writeFloat32(tick());

		const currentPosition = this.unit.model.GetPivot();

		this.unit.model.Humanoid.MoveTo(waypoint.Position);

		// replicate to server if player is owner of this unit
		if (this.unit.data.playerId === Players.LocalPlayer.UserId) {
			const response = replicator.Replicate("move-unit", buffer.dumpString())[0] as ServerResponse;

			if (response.error) {
				this.unit.model.PivotTo(currentPosition);
				this.Stop(false);
			}
		}
	}

	private ClearVisualisation() {
		this.visualisation.Positions.ClearAllChildren();
	}

	private CreateVisualisation() {
		this.ClearVisualisation();
		if (!this.visualisationEnabled || !this.active) return;

		let previousVisualisationAtt = this.beamAttachment;

		for (let waypointIndex = this.currentWaypointIndex; waypointIndex < this.waypoints.size(); waypointIndex++) {
			const waypoint = this.waypoints[waypointIndex];
			const toTargetCFrameDistance = previousVisualisationAtt.WorldPosition.sub(waypoint.Position).Magnitude;

			const visualisationPart = this.visualisationPart.Clone();

			const groundPositionResult = Utils.RaycastBottom(
				waypoint.Position.add(new Vector3(0, 100, 0)),
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
			visualisationPart.Beam.TextureLength = toTargetCFrameDistance;
			visualisationPart.Name = `${this.pathId}#${waypointIndex}`;
			visualisationPart.Transparency = waypointIndex === this.waypoints.size() - 1 ? 0 : 1;
			visualisationPart.Parent = this.visualisation.Positions;

			previousVisualisationAtt = visualisationPart.Attachment;
		}
	}

	private UpdateVisualisation() {
		for (let child of this.visualisation.Positions.GetChildren()) {
			if (child.Name.split("#")[0] !== this.pathId) {
				this.CreateVisualisation();
				return;
			}

			const waypointIndex = tonumber(child.Name.split("#")[1] as string)!;
			if (waypointIndex < this.currentWaypointIndex) {
				child.Destroy();
				continue;
			}

			const visualisationPart = child as ActionCircle["Middle"];
			const toTargetCFrameDistance = visualisationPart.Beam.Attachment0!.WorldPosition.sub(
				visualisationPart.Beam.Attachment1!.WorldPosition,
			).Magnitude;

			if (waypointIndex === this.currentWaypointIndex) {
				visualisationPart.Beam.Attachment1 = this.beamAttachment;
			}

			visualisationPart.Beam.TextureLength = toTargetCFrameDistance;
		}
	}
}
