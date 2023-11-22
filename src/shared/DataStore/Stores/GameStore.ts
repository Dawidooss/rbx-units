import ReplicatorBase from "../ReplicatorBase";
import Store from "../Store";

export default abstract class GameStore {
	protected stores = new Map<string, Store<any, any>>();
	public abstract replicator: ReplicatorBase;

	protected AddStore(store: Store<any, any>) {
		this.stores.set(store.name, store);
	}

	public GetStore(store: string) {
		return this.stores.get(store);
	}
}
