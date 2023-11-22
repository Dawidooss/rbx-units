import Network from "shared/Network";
import ReplicatorBase from "shared/DataStore/ReplicatorBase";
import { ServerResponse } from "types";
import ClientGameStore from "./ClientGameStore";

export default class ClientReplicator implements ReplicatorBase {
	public gameStore: ClientGameStore;

	constructor(gameStore: ClientGameStore) {
		this.gameStore = gameStore;
	}

	public Replicate(key: string, serializedData: any) {
		const response = Network.InvokeServer(key, serializedData);

		// if (response.error) {
		// 	if (response.errorMessage === "fetch-all") {
		// 		this.FetchAll();
		// 	}
		// }

		return response;
	}

	public Connect(key: string, callback: Callback) {
		Network.BindEvents({
			[key]: callback,
		});
	}

	public FetchAll() {
		let response = Network.InvokeServer("fetch-all")[0] as ServerResponse;
		if (!response) return;

		const data = response.data as Map<string, unknown>;

		if (response.error || !data) {
			// TODO notify error
			return;
		}

		for (const [storeName, serializedData] of data) {
			this.gameStore.GetStore(storeName)?.OverrideData(serializedData);
		}
	}
}
