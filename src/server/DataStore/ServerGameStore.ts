import GameStore from "shared/DataStore/Stores/GameStore";
import ServerReplicator, { ServerResponseBuilder } from "./ServerReplicator";
import Store from "shared/DataStore/Store";
import ServerTeamsStore from "./ServerTeamsStore";
import ServerPlayersStore from "./ServerPlayersStore";
import ServerUnitsStore from "./ServerUnitsStore";

export default class ServerGameStore extends GameStore {
	public replicator = new ServerReplicator(this);

	private static instance: ServerGameStore;
	constructor() {
		super();
		if (ServerGameStore.instance) return;
		ServerGameStore.instance = this;

		this.AddStore(new ServerTeamsStore(this));
		this.AddStore(new ServerPlayersStore(this));
		this.AddStore(new ServerUnitsStore(this));

		this.replicator.Connect("fetch-all", (player: Player) => {
			const serializedStores = new Map<string, unknown>();

			for (const [storeName, store] of this.stores) {
				serializedStores.set(storeName, store.SerializeCache());
			}

			const response = new ServerResponseBuilder().SetData(serializedStores).Build();

			return [response];
		});
	}

	public static Get() {
		return ServerGameStore.instance || new ServerGameStore();
	}
}
