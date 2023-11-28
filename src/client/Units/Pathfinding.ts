import { PathfindingService } from "@rbxts/services";
import Unit from "./Unit";
import ClientReplicator from "client/DataStore/ClientReplicator";

const agentParams = {
	AgentCanJump: false,
	WaypointSpacing: math.huge,
	AgentRadius: 4,
};

const replicator = ClientReplicator.Get();

export default class Pathfinding {
	public active = false;

	private unit: Unit;
	private path: Path;

	constructor(unit: Unit) {
		this.unit = unit;

		this.path = PathfindingService.CreatePath(agentParams);
	}

	public ComputePath(position: Vector3): Vector3[] {
		this.path.ComputeAsync(this.unit.GetPosition(), position);

		if (this.path.Status !== Enum.PathStatus.Success && this.path.Status !== Enum.PathStatus.ClosestNoPath) {
			return [];
		}

		let path: Vector3[] = [];
		let waypoints = this.path.GetWaypoints();
		waypoints.shift();

		for (const waypoint of waypoints) {
			path.push(waypoint.Position);
		}

		return path;
	}
}
