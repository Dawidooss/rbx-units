import GameStore from "shared/DataStore/GameStore";
import Replicator from "./Replicator";
import Store from "shared/DataStore/Store";

export default class ServerGameStore extends GameStore {
	public replicator = new Replicator(this);

	private static instance: ServerGameStore;
	constructor() {
		super()
		if (ServerGameStore.instance) return;
		ServerGameStore.instance = this;
		print('server replicator initialization')

		this.replicator.Connect("fetch-all", (player: Player) => {
			const serializedStores = new Map<string, Store>();

			print('OnServerInvoke fetch-data')

			for (const [storeName, store] of this.stores) {
				serializedStores.set(storeName, store.Serialize())
			}

			return serializedStores
		})
	}

	public static Get() {
		return ServerGameStore.instance || new ServerGameStore();
	}
}
