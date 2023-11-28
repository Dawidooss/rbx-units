import { PathfindingService } from "@rbxts/services";
import Unit from "./Unit";

const agentParams = {
	AgentCanJump: false,
	WaypointSpacing: math.huge,
	AgentRadius: 4,
};

export default class Pathfinding {
	public active = false;

	private unit: Unit;
	private path: Path;

	constructor(unit: Unit) {
		this.unit = unit;

		this.path = PathfindingService.CreatePath(agentParams);
	}

	public async ComputePath(position: Vector3): Promise<[Unit, Vector3[]]> {
		const promise = new Promise<[Unit, Vector3[]]>((resolve, reject) => {
			this.path.ComputeAsync(this.unit.GetPosition(), position);

			if (this.path.Status !== Enum.PathStatus.Success && this.path.Status !== Enum.PathStatus.ClosestNoPath) {
				return reject();
			}

			let path: Vector3[] = [];
			let waypoints = this.path.GetWaypoints();
			waypoints.shift();

			for (const waypoint of waypoints) {
				path.push(waypoint.Position);
			}

			resolve([this.unit, path]);
		});

		return promise;
	}
}
