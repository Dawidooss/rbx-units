import TeamsStore, { TeamData } from "shared/DataStore/Stores/TeamStore";
import ServerGameStore from "./ServerGameStore";
import BitBuffer from "@rbxts/bitbuffer";
import ServerReplicator from "./ServerReplicator";

const replicator = ServerReplicator.Get();

export default class ServerTeamsStore extends TeamsStore {
	constructor(gameStore: ServerGameStore) {
		super(gameStore);
	}

	public Add(teamData: TeamData): TeamData {
		super.Add(teamData);
		replicator.ReplicateAll("team-created", this.Serialize(teamData));

		return teamData;
	}

	public Remove(teamId: string): void {
		super.Remove(teamId);

		const buffer = BitBuffer();
		buffer.writeString(teamId);

		replicator.ReplicateAll("team-removed", buffer);
	}
}
