import ReplicatorBase from "./ReplicatorBase";
import Store from "./Store";

export default abstract class GameStore {
	protected stores = new Map<string, Store>();
	public abstract replicator: ReplicatorBase;

	protected AddStore(store: Store) {
		this.stores.set(store.name, store);
	}

	public GetStore(store: string) {
		return this.stores.get(store);
	}
}
