import { HttpService, PathfindingService, Players, ReplicatedFirst, RunService, Workspace } from "@rbxts/services";
import Unit from "./Unit";
import Utils from "../../shared/Utils";
import ClientGameStore from "client/DataStore/ClientGameStore";
import BitBuffer from "@rbxts/bitbuffer";
import ClientReplicator from "client/DataStore/ClientReplicator";

const agentParams = {
	AgentCanJump: false,
	WaypointSpacing: math.huge,
	AgentRadius: 4,
};

const replicator = ClientReplicator.Get();

export default class Pathfinding {
	public active = false;
	public targetPosition = new Vector3();

	private unit: Unit;
	private path: Path;
	private waypoints = new Array<PathWaypoint>();
	private currentWaypointIndex = 0;
	private pathId = "";

	constructor(unit: Unit) {
		this.unit = unit;

		this.path = PathfindingService.CreatePath(agentParams);

		// this.path.Blocked.Connect((blockedWaypointIndex) => {
		// 	wait();
		// 	this.ComputePath();
		// 	this.MoveToCurrentWaypoint();
		// });
	}

	public async StartWithWaypoints(waypoints: PathWaypoint[]) {
		this.targetPosition = waypoints[waypoints.size() - 1].Position;
		this.active = true;

		this.SetWaypoints(waypoints);
		this.CreateVisualisation();
		this.MoveToCurrentWaypoint();
	}

	public async Start(targetPosition: Vector3) {
		this.targetPosition = targetPosition;
		this.active = true;

		await this.ComputePath();
		this.CreateVisualisation();
		this.MoveToCurrentWaypoint();
	}
	public Stop(success: boolean) {
		this.active = false;
		this.waypoints = [];
		this.currentWaypointIndex = 0;

		this.ClearVisualisation();
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

	private SetWaypoints(waypoints: PathWaypoint[]) {
		this.waypoints = waypoints;
		this.currentWaypointIndex = 1;
		this.pathId = HttpService.GenerateGUID(false);
	}

	private async ComputePath() {
		this.path.ComputeAsync(this.unit.model.GetPivot().Position, this.targetPosition);

		if (this.path.Status !== Enum.PathStatus.Success && this.path.Status !== Enum.PathStatus.ClosestNoPath) {
			return;
		}

		this.SetWaypoints(this.path.GetWaypoints());
	}

	private MoveToCurrentWaypoint() {
		const waypoint = this.waypoints[this.currentWaypointIndex];

		if (!waypoint) {
			this.Stop(true);
			return;
		}

		this.UpdateVisualisation();

		const orientation = new CFrame(this.unit.model.GetPivot().Position, waypoint.Position).ToOrientation();
		const currentPosition = this.unit.model.GetPivot();

		this.unit.alignOrientation.CFrame = CFrame.Angles(0, orientation[1], 0);

		this.unit.MoveTo(waypoint.Position, (success: boolean) => {
			if (success) {
				this.currentWaypointIndex += 1;
				this.MoveToCurrentWaypoint();
			} else {
				this.Stop(false);
			}
		});

		// replicate to server if player is owner of this unit
		if (this.unit.data.playerId === Players.LocalPlayer.UserId) {
			const buffer = BitBuffer();
			buffer.writeString(this.unit.data.id);
			buffer.writeVector3(waypoint.Position);
			buffer.writeFloat32(tick());
			const response = replicator.Replicate("move-unit", buffer.dumpString())[0] as ServerResponse;

			if (response.error) {
				this.unit.model.PivotTo(currentPosition);
				this.Stop(false);
			}
		}
	}
}
