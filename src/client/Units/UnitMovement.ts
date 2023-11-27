import { HttpService, PathfindingService, Players, ReplicatedFirst, RunService, Workspace } from "@rbxts/services";
import Unit from "./Unit";
import Utils from "../../shared/Utils";
import ClientGameStore from "client/DataStore/ClientGameStore";
import BitBuffer from "@rbxts/bitbuffer";
import ClientReplicator from "client/DataStore/ClientReplicator";
import MovementVisualisation from "./MovementVisualisation";

const agentParams = {
	AgentCanJump: false,
	WaypointSpacing: math.huge,
	AgentRadius: 4,
};

export default class UnitMovement {
	public unit: Unit;
	public visualisation: MovementVisualisation;
	public moving = false;
	public movingTo: Vector3 | undefined;
	public path: Vector3[] = [];

	private moveToTries = 0;
	private pathId: string | undefined;

	constructor(unit: Unit) {
		this.unit = unit;
		this.visualisation = new MovementVisualisation(this);
	}

	public async Move(path: Vector3[]) {
		const pathId = HttpService.GenerateGUID(false);
		this.pathId = pathId;
		this.path = path;
		this.moving = true;
		// this.visualisation.Update();

		while (this.moving && this.pathId === pathId && this.path.size() > 0) {
			const success = await this.MoveTo(this.path[0]);
			if (!success) return;

			this.path.shift();
		}
	}

	private async MoveTo(position: Vector3): Promise<boolean> {
		this.moving = true;
		this.movingTo = position;
		print(3);

		const promise = new Promise<boolean>((resolve, reject) => {
			// orientation to position
			const orientation = new CFrame(this.unit.model.GetPivot().Position, position).ToOrientation();

			this.unit.alignOrientation.CFrame = CFrame.Angles(0, orientation[1], 0);
			this.unit.data.targetPosition = position;
			this.unit.data.movementStartTick = tick();

			this.TryMoveTo(position, (success: boolean) => resolve(success));

			// this.unit.MoveTo(waypoint.Position, (success: boolean) => {
			// 	if (success) {
			// 		this.currentWaypointIndex += 1;
			// 		this.MoveToCurrentWaypoint();
			// 	} else {
			// 		this.Stop(false);
			// 	}
			// });

			// replicate to server if player is owner of this unit
			// if (this.unit.data.playerId === Players.LocalPlayer.UserId) {
			// 	const buffer = BitBuffer();
			// 	buffer.writeString(this.unit.data.id);
			// 	buffer.writeVector3(waypoint.Position);
			// 	buffer.writeFloat32(tick());
			// 	const response = replicator.Replicate("move-unit", buffer.dumpString())[0] as ServerResponse;

			// 	if (response.error) {
			// 		this.unit.model.PivotTo(currentPosition);
			// 		this.Stop(false);
			// 	}
			// }
		});

		return promise;
	}

	private TryMoveTo(position: Vector3, endCallback?: Callback) {
		this.moveToTries += 1;

		if (this.moveToTries > 10) {
			warn(`UNIT MOVE TO: ${this.unit.data.id} couldn't get to targetPosition due to exceed moveToTries limit`);
			endCallback?.(false);
			return;
		}

		this.unit.model.Humanoid.MoveTo(position);

		wait(1);

		const conn = RunService.Heartbeat.Connect(() => {
			const distance = position.sub(this.unit.GetPosition()).Magnitude;
			if (distance <= 2) {
				conn.Disconnect();
				endCallback?.(true);
			} else if (this.unit.model.Humanoid.GetState() !== Enum.HumanoidStateType.Running) {
				conn.Disconnect();
				this.TryMoveTo(position, endCallback);
			}
		});
		this.unit.maid.GiveTask(conn);
	}
}
