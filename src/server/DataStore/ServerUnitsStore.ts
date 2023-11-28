import Replicator, { ServerResponseBuilder } from "./ServerReplicator";
import { TeamData } from "shared/DataStore/Stores/TeamStore";
import ServerGameStore from "./ServerGameStore";
import PlayersStore, { PlayerData } from "shared/DataStore/Stores/PlayersStore";
import UnitsStore, { UnitData } from "shared/DataStore/Stores/UnitsStore";
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
			print("create-unit 1");
			const unitData = this.Deserialize(buffer);
			print("create-unit 2");
			this.Add(unitData);

			print(this.cache);

			return new ServerResponseBuilder().Build();
		});

		replicator.Connect("unit-movement", (player: Player, buffer: BitBuffer) => {
			const unitId = buffer.readString();
			const unit = this.cache.get(unitId);

			if (!unit) {
				new ServerResponseBuilder().SetError("data-missmatch").Build();
			}

			// TODO

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
