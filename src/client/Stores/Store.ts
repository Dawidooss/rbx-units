import Signal from "@rbxts/signal";
import GameStore from "./GameStore";
import Receiver from "./Receiver";

export default abstract class Store {
	public name: string = "Store";
	public gameStore: GameStore;
	public receiver: Receiver;
	public dataChanged: Signal;

	protected replicable = true;

	constructor(gameStore: GameStore) {
		this.gameStore = gameStore;
		this.receiver = gameStore.receiver;
		this.dataChanged = new Signal();
	}

	protected SetReplicable(replicable: boolean) {
		this.replicable = replicable;
	}

	public DataMissmatch() {
		this.receiver.FetchAll();
	}

	abstract OverrideData(data: any): void;
}
