import Signal from "@rbxts/signal";
import GameStore from "./GameStore";
import Replicator from "./Replicator";

export default abstract class Store {
	public name: string = "Store";
	public gameStore: GameStore;
	public replicator: Replicator;
	public dataChanged: Signal;

	protected replicable = true;

	constructor(gameStore: GameStore) {
		this.gameStore = gameStore;
		this.replicator = gameStore.replicator;
		this.dataChanged = new Signal();
	}

	protected SetReplicable(replicable: boolean) {
		this.replicable = replicable;
	}

	protected DataMissmatch() {
		this.replicator.FetchAll();
	}

	abstract OverrideData(data: any): void;
}
