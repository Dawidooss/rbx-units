import Network from "shared/Network";
import Replicator from "./Replicators/Replicator";

export default class GameStore {
	private static instance: GameStore;

	public static stores = new Map<string, Store>();
	public replicators: Replicator[] = [];

	constructor() {
		if (GameStore.instance) return;

		GameStore.instance = this;
	}

	public Get() {
		return GameStore.instance || new GameStore();
	}
}
