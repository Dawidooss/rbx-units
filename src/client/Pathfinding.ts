import { AvatarEditorService, HttpService, PathfindingService, ReplicatedFirst, RunService } from "@rbxts/services";
import Unit from "./Units/Unit";

const agentParams = {
	AgentCanJump: false,
	WaypointSpacing: math.huge,
};

export default class Pathfinding {
	public active = false;
	public visualisationEnabled = false;
	public targetCFrame = new CFrame();

	private unit: Unit;
	private agent: UnitModel;
	private path: Path;
	private stopCallback: ((success: boolean) => void) | undefined;
	private waypoints = new Array<PathWaypoint>();
	private currentWaypointIndex = 0;
	private pathId = "";
	private moveToCurrentWaypointTries = 0;

	private visualisation: MovementCircle;
	private visualisationPart: MovementCircle["Middle"];
	private beamAttachment: Attachment;
	private loopConnection: RBXScriptConnection | undefined;

	constructor(unit: Unit) {
		this.unit = unit;
		this.agent = unit.model;

		this.path = PathfindingService.CreatePath(agentParams);

		this.visualisation = ReplicatedFirst.FindFirstChild("MovementCircle")!.Clone() as MovementCircle;
		this.visualisationPart = this.visualisation.Middle;

		this.visualisation.Name = "PathVisualisation";
		this.visualisation.Parent = this.unit.model;
		this.visualisation.Arrow.Destroy();
		this.visualisationPart.Parent = undefined;

		this.beamAttachment = new Instance("Attachment");
		this.beamAttachment.Parent = this.agent.HumanoidRootPart;
		this.beamAttachment.WorldCFrame = this.agent.GetPivot().mul(CFrame.Angles(0, math.pi, math.pi / 2));

		this.path.Blocked.Connect((blockedWaypointIndex) => {
			wait();
			this.ComputePath();
		});

		this.agent.Humanoid.MoveToFinished.Connect((reached) => {
			if (!this.active) return;

			const currentWaypoint = this.waypoints[this.currentWaypointIndex];
			if (!currentWaypoint) return;
			const distanceToCurrentWaypoint = currentWaypoint.Position.sub(this.beamAttachment.WorldPosition).Magnitude;

			if (distanceToCurrentWaypoint < 1) {
				if (this.currentWaypointIndex === this.waypoints.size() - 1) {
					this.Stop(true);
					return;
				}

				this.currentWaypointIndex += 1;
				this.moveToCurrentWaypointTries = 0;
			} else {
				this.moveToCurrentWaypointTries += 1;
			}
			this.MoveToCurrentWaypoint();
		});
	}

	public async Start(targetCFrame: CFrame, stopCallback?: (success: boolean) => void) {
		this.targetCFrame = targetCFrame;
		this.active = true;
		this.stopCallback = stopCallback;

		await this.ComputePath();

		this.CreateVisualisation();

		this.loopConnection?.Disconnect();
		this.loopConnection = RunService.RenderStepped.Connect(() => {
			this.Update();
		});
	}
	public Stop(success: boolean) {
		this.stopCallback?.(success);

		// this.agent.MoveTo(this.agent.GetPivot().Position);
		if (success) {
			this.unit.alignOrientation.CFrame = this.targetCFrame;
		}

		this.active = false;
		this.waypoints = [];
		this.currentWaypointIndex = 0;

		this.loopConnection?.Disconnect();
		this.ClearVisualisation();
	}

	public EnableVisualisation(state: boolean) {
		this.visualisationEnabled = state;
		this.CreateVisualisation();
	}

	private async ComputePath() {
		const pathId = HttpService.GenerateGUID(false);
		this.pathId = pathId;

		this.path.ComputeAsync(this.agent.GetPivot().Position, this.targetCFrame.Position);

		if (this.path.Status !== Enum.PathStatus.Success && this.path.Status !== Enum.PathStatus.ClosestNoPath) {
			return;
		}

		this.moveToCurrentWaypointTries = 0;
		this.waypoints = this.path.GetWaypoints();
		this.currentWaypointIndex = 1;
		this.pathId = HttpService.GenerateGUID(false);

		this.MoveToCurrentWaypoint();
	}

	private MoveToCurrentWaypoint() {
		if (this.moveToCurrentWaypointTries > 10) {
			warn(
				`PATHFINDING: ${this.agent.Name} couldn't get to targetCFrame due to exceed moveToCurrentWaypointTries limit`,
			);
			this.Stop(false);
			return;
		}

		const waypoint = this.waypoints[this.currentWaypointIndex];

		if (!waypoint) {
			this.Stop(true);
			return;
		}

		this.unit.alignOrientation.CFrame = new CFrame(this.agent.GetPivot().Position, waypoint.Position);
		this.agent.Humanoid.MoveTo(waypoint.Position);
	}

	private Update() {
		if (this.active && this.visualisationEnabled) {
			this.UpdateVisualisation();
		}

		const currentWaypoint = this.waypoints[this.currentWaypointIndex];
		if (!currentWaypoint) return;
		const distanceToCurrentWaypoint = currentWaypoint.Position.sub(this.beamAttachment.WorldPosition).Magnitude;

		if (distanceToCurrentWaypoint > 1 && this.agent.Humanoid.GetState() !== Enum.HumanoidStateType.Running) {
			this.moveToCurrentWaypointTries += 1;
			this.MoveToCurrentWaypoint();
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
			visualisationPart.PivotTo(new CFrame(waypoint.Position, previousVisualisationAtt.WorldPosition));

			visualisationPart.Beam.Attachment1 = previousVisualisationAtt;
			visualisationPart.Beam.TextureLength = toTargetCFrameDistance;
			visualisationPart.Name = `${this.pathId}#${waypointIndex}`;
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

			const visualisationPart = child as MovementCircle["Middle"];
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
