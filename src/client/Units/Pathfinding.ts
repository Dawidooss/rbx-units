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

	private unit: Unit;
	private path: Path;

	constructor(unit: Unit) {
		this.unit = unit;

		this.path = PathfindingService.CreatePath(agentParams);
	}

	public ComputePath(position: Vector3): Vector3[] {
		this.path.ComputeAsync(this.unit.model.GetPivot().Position, position);

		if (this.path.Status !== Enum.PathStatus.Success && this.path.Status !== Enum.PathStatus.ClosestNoPath) {
			return [];
		}

		let path: Vector3[] = [];
		for (const waypoint of this.path.GetWaypoints()) {
			path.push(waypoint.Position);
		}

		return path;
	}
}
