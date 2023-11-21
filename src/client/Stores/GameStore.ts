import Replicator from "./Replicator";
import Store from "./Store";
import TeamsStore from "./TeamsStore";

export default class GameStore {
	private stores = new Map<string, Store>();
	public replicator = new Replicator(this);

	private static instance: GameStore;
	constructor() {
		if (GameStore.instance) return;

		GameStore.instance = this;

		this.AddStore(new TeamsStore(this));
	}

	private AddStore(store: Store) {
		this.stores.set(store.name, store);
	}

	public GetStore(store: string) {
		return this.stores.get(store);
	}

	public static Get() {
		return GameStore.instance || new GameStore();
	}
}
