import Network from "shared/Network";
import GameStore from "./GameStore";
import ReplicatorBase from "shared/DataStore/ReplicatorBase";

export default class Replicator implements ReplicatorBase {
	public gameStore: GameStore;
	

	constructor(gameStore: GameStore) {
		this.gameStore = gameStore;
	}

	public Replicate(player: Player, key: string, serializedData: any) {
		Network.FireClient(player, key, serializedData);
	}

	public ReplicateAll(key: string, serializedData: any) {
		Network.FireAllClients(key, serializedData);
	}

	public Connect(key: string, callback: Callback) {
		Network.BindFunctions({
			[key]: callback,
		});
	}
}

