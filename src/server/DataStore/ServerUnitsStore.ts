import Replicator, { ServerResponseBuilder } from "./ServerReplicator";
import { TeamData } from "shared/DataStore/Stores/TeamStoreBase";
import ServerGameStore from "./ServerGameStore";
import PlayersStore, { PlayerData } from "shared/DataStore/Stores/PlayersStoreBase";
import UnitsStore, { UnitData } from "shared/DataStore/Stores/UnitsStoreBase";
import Utils from "shared/Utils";
import BitBuffer from "@rbxts/bitbuffer";
import ServerReplicator from "./ServerReplicator";
import { uint } from "@rbxts/squash";
import ReplicationQueue from "shared/ReplicationQueue";

const replicator = ServerReplicator.Get();

export default class ServerUnitsStore extends UnitsStore {
	constructor(gameStore: ServerGameStore) {
		super(gameStore);

		replicator.Connect("create-unit", (player: Player, buffer: BitBuffer) => {
			const unitData = this.Deserialize(buffer);

			const queue = new ReplicationQueue();
			this.Add(unitData, queue);

			replicator.ReplicateAll(queue);

			return new ServerResponseBuilder().Build();
		});

		replicator.Connect("unit-movement", (player: Player, buffer: BitBuffer) => {
			const unitId = buffer.readString();
			const position = buffer.readVector3();
			const unit = this.cache.get(unitId);

			if (!unit) {
				return new ServerResponseBuilder().SetError("data-missmatch").Build();
			}

			const path = this.DeserializePath(buffer);
			unit.path = path;
			unit.position = position;

			const queue = new ReplicationQueue();
			queue.Add("unit-movement", (queueBuffer: BitBuffer) => {
				queueBuffer.writeString(unitId);
				queueBuffer.writeVector3(position);
				this.SerializePath(path, queueBuffer);
			});

			replicator.ReplicateExcept(player, queue);

			return new ServerResponseBuilder().Build();
		});
	}

	public Add(unitData: UnitData, queue?: ReplicationQueue): UnitData {
		super.Add(unitData);

		const queuePassed = !!queue;
		queue ||= new ReplicationQueue();
		queue.Add("unit-created", (buffer: BitBuffer) => {
			this.Serialize(unitData, buffer);
		});

		if (!queuePassed) {
			replicator.ReplicateAll(queue);
		}

		return unitData;
	}

	public Remove(unitId: string, queue?: ReplicationQueue): void {
		super.Remove(unitId);

		const queuePassed = !!queue;
		queue ||= new ReplicationQueue();
		queue.Add("unit-created", (buffer: BitBuffer) => {
			buffer.writeString(unitId);
		});

		if (!queuePassed) {
			replicator.ReplicateAll(queue);
		}
	}
}
