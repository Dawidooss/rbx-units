import GameStore from "./Stores/GameStore";
import ReplicatorBase from "./ReplicatorBase";

export default abstract class Store<D, S> {
	public name: string = "Store";
	public gameStore: GameStore;
	public replicator: ReplicatorBase;
	public cache = new Map<string, D>();

	constructor(gameStore: GameStore) {
		this.gameStore = gameStore;
		this.replicator = gameStore.replicator;
	}

	public SerializeCache(): S[] {
		let serializedCache = [];
		for (const [_, data] of this.cache) {
			serializedCache.push(this.Serialize(data));
		}

		return serializedCache;
	}

	abstract OverrideData(data: unknown): void;
	abstract Serialize(data: D): S;
	abstract Deserialize(data: S): D;
}
