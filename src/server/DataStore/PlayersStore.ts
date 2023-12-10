import PlayersStoreBase, { PlayerData } from "shared/DataStore/Stores/PlayersStoreBase";
import BitBuffer from "@rbxts/bitbuffer";
import ServerReplicator from "./Replicator";
import ReplicationQueue from "shared/ReplicationQueue";

const replicator = ServerReplicator.Get();

export default class PlayersStore extends PlayersStoreBase {
	private static instance: PlayersStore;

	constructor() {
		super();
		PlayersStore.instance = this;
	}

	public Add(playerData: PlayerData, queue?: ReplicationQueue): PlayerData {
		super.Add(playerData);

		const queuePassed = !!queue;
		queue ||= new ReplicationQueue();
		queue.Add("player-added", this.serializer.Ser(playerData));

		if (!queuePassed) {
			replicator.ReplicateAll(queue);
		}

		return playerData;
	}

	public Remove(playerId: number, queue?: ReplicationQueue) {
		const playerData = super.Remove(playerId);

		if (playerData) {
			const queuePassed = !!queue;
			queue ||= new ReplicationQueue();
			queue.Add(
				"player-removed",
				this.serializer
					.ToSelected<{
						id: number;
					}>(["id"])
					.Ser(playerData),
			);

			if (!queuePassed) {
				replicator.ReplicateAll(queue);
			}
		}

		return playerData;
	}

	public static Get() {
		return PlayersStore.instance || new PlayersStore();
	}
}
