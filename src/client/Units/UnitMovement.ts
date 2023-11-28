import { HttpService, RunService } from "@rbxts/services";
import Unit from "./Unit";
import MovementVisualisation from "./MovementVisualisation";
import { SelectionType } from "shared/types";
import BitBuffer from "@rbxts/bitbuffer";
import ReplicationQueue from "shared/ReplicationQueue";
import Replicator from "client/DataStore/Replicator";

const replicator = Replicator.Get();

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
		this.pathId = undefined;
		this.visualisation.Enable(false);
		this.loopConnection?.Disconnect();
		this.moveToTries = 0;
		this.movingTo = undefined;
		this.unit.path = [];
		this.moving = false;
	}

	public MoveAlongPath(path: Vector3[], queue?: ReplicationQueue) {
		const pathId = HttpService.GenerateGUID(false);
		this.pathId = pathId;
		this.unit.path = path;
		this.moving = true;

		const queuePassed = !!queue;
		queue ||= new ReplicationQueue();

		queue?.Add("unit-movement", (buffer: BitBuffer) => {
			buffer.writeString(this.unit.id);
			buffer.writeVector3(this.unit.GetPosition());

			this.unit.unitsStore.SerializePath(this.unit.path, buffer);
		});

		if (!queuePassed) {
			replicator.Replicate(queue);
		}

		spawn(async () => {
			while (this.moving && this.pathId === pathId && this.unit.path.size() > 0) {
				const success = await this.MoveTo(this.unit.path[0]);
				if (!success) break;

				this.unit.path.shift();
			}
			this.Stop();
		});
	}

	private async MoveTo(position: Vector3): Promise<boolean> {
		this.moving = true;
		this.movingTo = position;
		this.moveToTries = 0;

		this.visualisation.Enable(this.unit.selectionType === SelectionType.Selected);

		const promise = new Promise<boolean>(async (resolve, reject) => {
			// orientation to position
			const orientation = new CFrame(this.unit.model.GetPivot().Position, position).ToOrientation();

			this.unit.alignOrientation.CFrame = CFrame.Angles(0, orientation[1], 0);

			const success = await this.TryMoveTo(position);
			resolve(success);
		});

		return promise;
	}

	private async TryMoveTo(position: Vector3): Promise<boolean> {
		this.moveToTries += 1;

		const promise = new Promise<boolean>((resolve, reject) => {
			if (this.moveToTries > 10) {
				warn(`UNIT MOVE TO: ${this.unit.id} couldn't get to targetPosition due to exceed moveToTries limit`);
				resolve(true);
				return;
			}

			// this.Replicate();

			this.loopConnection?.Disconnect();
			const conn = RunService.Heartbeat.Connect(async () => {
				const unitPosition = this.unit.GetPosition();
				const groundedPosition = new Vector3(position.X, unitPosition.Y, position.Z);
				const distance = groundedPosition.sub(unitPosition).Magnitude;

				this.unit.model.Humanoid.MoveTo(position);

				if (distance <= 2) {
					conn.Disconnect();
					resolve(true);
				}
			});
			this.loopConnection = conn;

			this.unit.maid.GiveTask(conn);
		});

		return promise;
	}
}
