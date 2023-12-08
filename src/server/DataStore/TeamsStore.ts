import TeamsStoreBase, { TeamData } from "shared/DataStore/Stores/TeamStoreBase";
import BitBuffer from "@rbxts/bitbuffer";
import ServerReplicator from "./Replicator";
import ReplicationQueue from "shared/ReplicationQueue";

const replicator = ServerReplicator.Get();

export default class TeamsStore extends TeamsStoreBase {
	public static instance: TeamsStore;

	constructor() {
		super();
		TeamsStore.instance = this;
	}

	public Add(teamData: TeamData, queue?: ReplicationQueue): TeamData {
		super.Add(teamData);

		const queuePassed = !!queue;
		queue ||= new ReplicationQueue();
		queue.Add("team-created", (buffer: BitBuffer) => {
			return this.serializer.Ser(teamData, buffer);
		});

		if (!queuePassed) {
			replicator.ReplicateAll(queue);
		}

		return teamData;
	}

	public Remove(teamId: number, queue?: ReplicationQueue): void {
		super.Remove(teamId);

		// const queuePassed = !!queue;
		// queue ||= new ReplicationQueue();
		// queue.Add("team-removed", (buffer: BitBuffer) => {
		// 	buffer.writeBits(...bit.ToBits(teamId, 4));
		// 	return buffer;
		// });

		// if (!queuePassed) {
		// 	replicator.ReplicateAll(queue);
		// }
	}

	public static Get() {
		return TeamsStore.instance || new TeamsStore();
	}
}
