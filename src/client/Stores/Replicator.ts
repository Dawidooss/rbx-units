import Network from "shared/Network";
import GameStore from "./GameStore";
import ReplicatorBase from "shared/DataStore/ReplicatorBase";
import { ServerResponse } from "types";

export default class Replicator implements ReplicatorBase {
	public gameStore: GameStore;

	constructor(gameStore: GameStore) {
		this.gameStore = gameStore;
	}

	public Replicate(key: string, serializedData: any) {
		const response = Network.InvokeServer(key, serializedData)[0] as ServerResponse;

		if (response.error) {
			if (response.errorMessage === "fetch-all") {
				this.FetchAll();
			}
		}
	}

	public Connect(key: string, callback: Callback) {
		Network.BindEvents({
			[key]: callback,
		});
	}

	public FetchAll() {
		const response = Network.InvokeServer("fetch-all")[0];

		if (!response.error && response.data) {
			for (const [storeName, serializedData] of response.data) {
				this.gameStore.GetStore(storeName)?.OverrideData(serializedData);
			}
		}
	}
}
