import GameStoreBase from "shared/DataStore/Stores/GameStoreBase";
import ServerReplicator, { ServerResponseBuilder } from "./Replicator";
import BitBuffer from "@rbxts/bitbuffer";

const replicator = ServerReplicator.Get();

export default class GameStore extends GameStoreBase {
	private static instance: GameStore;
	constructor() {
		super();
		if (GameStore.instance) return;
		GameStore.instance = this;

		replicator.Connect("fetch-all", (player: Player, buffer: BitBuffer) => {
			const responseBuffer = BitBuffer();

			for (const [storeName, store] of this.stores) {
				responseBuffer.writeString(storeName);
				store.SerializeCache(responseBuffer);
			}

			return new ServerResponseBuilder().SetData(responseBuffer.dumpString()).Build();
		});
	}

	public static Get() {
		return GameStore.instance || new GameStore();
	}
}
