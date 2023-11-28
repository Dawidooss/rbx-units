import GameStore from "shared/DataStore/Stores/GameStore";
import ServerReplicator, { ServerResponseBuilder } from "./ServerReplicator";
import Store from "shared/DataStore/Store";
import ServerTeamsStore from "./ServerTeamsStore";
import ServerPlayersStore from "./ServerPlayersStore";
import ServerUnitsStore from "./ServerUnitsStore";
import BitBuffer from "@rbxts/bitbuffer";

const replicator = ServerReplicator.Get();

export default class ServerGameStore extends GameStore {
	private static instance: ServerGameStore;
	constructor() {
		super();
		if (ServerGameStore.instance) return;
		ServerGameStore.instance = this;

		this.AddStore(new ServerTeamsStore(this));
		this.AddStore(new ServerPlayersStore(this));
		this.AddStore(new ServerUnitsStore(this));

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
		return ServerGameStore.instance || new ServerGameStore();
	}
}
