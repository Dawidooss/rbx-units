import UnitsStoreBase, { UnitData } from "shared/DataStore/Stores/UnitsStoreBase";
import BitBuffer from "@rbxts/bitbuffer";
import ServerReplicator from "./Replicator";
import ReplicationQueue from "shared/ReplicationQueue";

const replicator = ServerReplicator.Get();

export default class UnitsStore extends UnitsStoreBase {
	private static instance: UnitsStore;
	constructor() {
		super();

		replicator.Connect("create-unit", this.serializer, (player, data, response, replication) => {
			this.Add(data, replication);
		});

		replicator.Connect(
			"unit-movement",
			this.serializer.ToSelected<{ id: number; position: Vector3; path: Vector3[] }>(["id", "position", "path"]),
			(player, data, response, replication) => {
				const unit = this.cache.get(data.id);
				if (!unit) {
					response.Add();
					return;
				}

				unit.path = data.path;
				unit.position = data.position;

				// replicationQueue.Add("unit-movement", (writeBuffer) => {
				// 	buffer.setPointer(startPointer);

				// 	return writeBuffer;
				// });
			},
		);

		UnitsStore.instance = this;

		// replicator.Connect(
		// 	"unit-movement",
		// 	new QueueDeserializer<{
		// 		unitId: number;
		// 		position: Vector3;
		// 		path: Vector3[];
		// 	}>([
		// 		["unitId", Des.Signed(12)],
		// 		["position", Des.Custom<Vector3>(this.DeserializePosition)],
		// 		["path", Des.Array<Vector3>(this.DeserializePosition)],
		// 	]),
		// 	(player, data) => {
		// 		const unit = this.cache.get(data.unitId);
		// 		if (!unit) return;

		// 		unit.path = data.path;
		// 		unit.position = data.position;

		// 		// replicationQueue.Add("unit-movement", (writeBuffer) => {
		// 		// 	buffer.setPointer(startPointer);

		// 		// 	return writeBuffer;
		// 		// });
		// 	},
		// );

		// replicator.Connect("unit-movement",  (player: Player, buffer: BitBuffer, replicationQueue: ReplicationQueue) => {
		// 	const startPointer = buffer.getPointer();
		// 	const unitId = bit.FromBits(buffer.readBits(12));
		// 	const position = new Vector3(bit.FromBits(buffer.readBits(10)), 10, bit.FromBits(buffer.readBits(10)));
		// 	const unit = this.cache.get(unitId);
		// 	const path = this.DeserializePath(buffer);
		// 	const endPointer = buffer.getPointer();

		// 	if (!unit) return;

		// 	unit.path = path;
		// 	unit.position = position;

		// 	replicationQueue.Add("unit-movement", (writeBuffer) => {
		// 		buffer.setPointer(startPointer);

		// 		return writeBuffer;
		// 	});
		// });

		// replicator.Connect(
		// 	"update-unit-heal",
		// 	(player: Player, buffer: BitBuffer, replicationQueue: ReplicationQueue) => {
		// 		const unitId = bit.FromBits(buffer.readBits(12));
		// 		const health = bit.FromBits(buffer.readBits(7));
		// 		const unit = this.cache.get(unitId);

		// 		if (!unit) return;

		// 		unit.health = health;

		// 		if (unit.health <= 0) {
		// 			// kill
		// 			replicationQueue.Add("unit-removed", (writeBuffer) => {
		// 				writeBuffer.writeBits(...bit.ToBits(unitId, 12));
		// 				return writeBuffer;
		// 			});
		// 		} else {
		// 			replicationQueue.Add("update-unit-heal", (writeBuffer) => {
		// 				writeBuffer.writeBits(...bit.ToBits(unitId, 12));
		// 				writeBuffer.writeBits(...bit.ToBits(health, 7));
		// 				return writeBuffer;
		// 			});
		// 		}
		// 	},
		// );
	}

	public Add(unitData: UnitData, queue?: ReplicationQueue): UnitData {
		super.Add(unitData);

		const queuePassed = !!queue;
		queue ||= new ReplicationQueue();
		queue.Add("unit-created", this.serializer.Ser(unitData));

		if (!queuePassed) {
			replicator.ReplicateAll(queue);
		}

		return unitData;
	}

	public Remove(unitId: number, queue?: ReplicationQueue) {
		const unit = super.Remove(unitId);

		if (unit) {
			const queuePassed = !!queue;
			queue ||= new ReplicationQueue();
			queue.Add(
				"unit-removed",
				this.serializer
					.ToSelected<{
						id: number;
					}>(["id"])
					.Ser(unit),
			);

			if (!queuePassed) {
				replicator.ReplicateAll(queue);
			}
		}

		return unit;
	}

	public static Get() {
		return UnitsStore.instance || new UnitsStore();
	}
}
