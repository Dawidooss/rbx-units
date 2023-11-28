import TeamsStore, { TeamData } from "shared/DataStore/Stores/TeamStore";
import ServerGameStore from "./ServerGameStore";
import BitBuffer from "@rbxts/bitbuffer";
import ServerReplicator from "./ServerReplicator";
import ReplicationQueue from "shared/ReplicationQueue";

const replicator = ServerReplicator.Get();

export default class ServerTeamsStore extends TeamsStore {
	constructor(gameStore: ServerGameStore) {
		super(gameStore);
	}

	public Add(teamData: TeamData, queue?: ReplicationQueue): TeamData {
		super.Add(teamData);

		const queuePassed = !!queue;
		queue ||= new ReplicationQueue();
		queue.Add("team-created", (buffer: BitBuffer) => {
			this.Serialize(teamData, buffer);
		});

		if (!queuePassed) {
			replicator.ReplicateAll(queue);
		}

		return teamData;
	}

	public Remove(teamId: string, queue?: ReplicationQueue): void {
		super.Remove(teamId);

		const queuePassed = !!queue;
		queue ||= new ReplicationQueue();
		queue.Add("team-created", (buffer: BitBuffer) => {
			buffer.writeString(teamId);
		});

		if (!queuePassed) {
			replicator.ReplicateAll(queue);
		}
	}
}
