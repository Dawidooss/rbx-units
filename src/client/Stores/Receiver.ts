import Network from "shared/Network";
import GameStore from "./GameStore";

export default class Receiver {
	public gameStore: GameStore;

	constructor(gameStore: GameStore) {
		this.gameStore = gameStore;
	}

	public Replicate(key: string, serializedData: any) {
		const response = Network.InvokeServer(key, serializedData)[0] as ServerResponse;

		if (response.error) {
			if (response.errorMessage === "FetchAll") {
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
		const response = Network.InvokeServer("FetchAll")[0];

		if (!response.error && response.data) {
			for (const [storeName, data] of response.data) {
				this.gameStore.GetStore(storeName)?.OverrideData(data);
			}
		}
	}
}

type SerializableTypes = "string" | "number" | "Vector3" | "CFrame";

export type ServerResponse = {
	status: string;
	data?: any;
} & (
	| {
			error: false;
	  }
	| {
			error: true;
			errorMessage: string;
	  }
);
