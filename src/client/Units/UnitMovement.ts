import { HttpService, Players, RunService, Workspace } from "@rbxts/services";
import Unit from "./Unit";
import MovementVisualisation from "./MovementVisualisation";
import { SelectionType } from "shared/types";
import BitBuffer from "@rbxts/bitbuffer";
import ClientReplicator from "client/DataStore/ClientReplicator";

const replicator = ClientReplicator.Get();

export default class UnitMovement {
	public unit: Unit;
	public visualisation: MovementVisualisation;
	public moving = false;
	public movingTo: Vector3 | undefined;

	private moveToTries = 0;
	private pathId: string | undefined;
	private loopConnection: RBXScriptConnection | undefined;

	constructor(unit: Unit) {
		this.unit = unit;
		this.visualisation = new MovementVisualisation(this);
	}

	public Stop() {
		this.data.pathId = undefined;
		this.visualisation.Enable(false);
		this.loopConnection?.Disconnect();
		this.moveToTries = 0;
		this.movingTo = undefined;
		this.data.path = [];
		this.moving = false;
	}

	public async Move(path: Vector3[], replicate: boolean) {
		const pathId = HttpService.GenerateGUID(false);
		this.data.pathId = pathId;
		this.data.path = path;
		this.moving = true;

		while (this.moving && this.data.pathId === pathId && this.data.path.size() > 0) {
			const success = await this.MoveTo(this.data.path[0]);
			if (!success) break;

			this.data.path.shift();
		}
		this.Stop();
	}

	private async MoveTo(position: Vector3): Promise<boolean> {
		this.moving = true;
		this.movingTo = position;

		this.visualisation.Enable(this.unit.selectionType === SelectionType.Selected);

		const promise = new Promise<boolean>(async (resolve, reject) => {
			// orientation to position
			const orientation = new CFrame(this.unit.model.GetPivot().Position, position).ToOrientation();

			this.unit.alignOrientation.CFrame = CFrame.Angles(0, orientation[1], 0);
			this.unit.data.targetPosition = position;
			this.unit.data.movementStartTick = tick();

			const success = await this.TryMoveTo(position);
			resolve(success);

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

	private async TryMoveTo(position: Vector3): Promise<boolean> {
		this.moveToTries += 1;

		const promise = new Promise<boolean>((resolve, reject) => {
			if (this.moveToTries > 10) {
				warn(
					`UNIT MOVE TO: ${this.unit.data.id} couldn't get to targetPosition due to exceed moveToTries limit`,
				);
				resolve(true);
				return;
			}

			this.Replicate();
			this.unit.model.Humanoid.MoveTo(position);

			this.loopConnection?.Disconnect();
			const conn = RunService.Heartbeat.Connect(async () => {
				const unitPosition = this.unit.GetPosition();
				const groundedPosition = new Vector3(position.X, unitPosition.Y, position.Z);
				const distance = groundedPosition.sub(unitPosition).Magnitude;
				if (distance <= 2) {
					conn.Disconnect();
					resolve(true);
				} else if (this.unit.model.Humanoid.GetState() !== Enum.HumanoidStateType.Running) {
					conn.Disconnect();
					const success = await this.TryMoveTo(position);
					resolve(success);
				}
			});
			this.loopConnection = conn;

			this.unit.maid.GiveTask(conn);
		});

		return promise;
	}

	private Replicate() {
		if (this.unit.data.playerId === Players.LocalPlayer.UserId) {
			const buffer = BitBuffer();
			buffer.writeString(this.unit.data.id);
			buffer.writeVector3(this.unit.GetPosition());
			buffer.writeFloat32(tick());

			for (const position of this.data.path) {
				buffer.writeVector3(position);
			}

			const response = replicator.Replicate("unit-movement", buffer.dumpString())[0] as ServerResponse;

			if (response.error) {
				// this.unit.model.PivotTo(currentPosition);
				// this.Stop(false);
				print("didnt work");
			}
		}
	}
}
