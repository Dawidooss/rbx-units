import Store from "../Store";

export default abstract class GameStore {
	protected stores = new Map<string, Store<any>>();

	protected AddStore(store: Store<any>) {
		this.stores.set(store.name, store);
	}

	public GetStore(store: string) {
		return this.stores.get(store);
	}
}
