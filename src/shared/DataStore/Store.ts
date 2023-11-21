import GameStore from "./GameStore";
import ReplicatorBase from "./ReplicatorBase";

export default abstract class Store {
	public name: string = "Store";
	public gameStore: GameStore;
	public replicator: ReplicatorBase;

	constructor(gameStore: GameStore) {
		this.gameStore = gameStore;
		this.replicator = gameStore.replicator;
	}

	abstract OverrideData(data: any): void;
	abstract Serialize(): any;
}
