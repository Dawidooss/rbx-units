import Receiver from "./Receiver";
import Store from "./Store";
import TeamsStore from "./TeamsStore";

export default class GameStore {
	private stores = new Map<string, Store>();
	public receiver = new Receiver(this);

	private static instance: GameStore;
	constructor() {
		if (GameStore.instance) return;

		GameStore.instance = this;

		this.AddStore(new TeamsStore(this));

		this.receiver.FetchAll();
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
