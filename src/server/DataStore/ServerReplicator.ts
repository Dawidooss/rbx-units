import Network from "shared/Network";
import GameStore from "./ServerGameStore";
import ReplicatorBase from "shared/DataStore/ReplicatorBase";
import { ServerResponse } from "types";

export default class ServerReplicator implements ReplicatorBase {
	public gameStore: GameStore;

	constructor(gameStore: GameStore) {
		this.gameStore = gameStore;
	}

	public Replicate(player: Player, key: string, serializedData: unknown) {
		const response = new ServerResponseBuilder().SetData(serializedData).Build();
		Network.FireClient(player, key, response);
	}

	public ReplicateAll(key: string, serializedData: unknown) {
		const response = new ServerResponseBuilder().SetData(serializedData).Build();
		Network.FireAllClients(key, response);
	}

	public ReplicateExcept(player: Player, key: string, serializedData: unknown) {
		const response = new ServerResponseBuilder().SetData(serializedData).Build();
		Network.FireOtherClients(player, key, response);
	}

	public Connect(key: string, callback: Callback) {
		Network.BindFunctions({
			[key]: callback,
		});
	}
}

export class ServerResponseBuilder {
	private status: string = "";
	private error: boolean = false;
	private errorMessage?: string;
	private data?: unknown;

	constructor() {}

	public SetError(errorMessage: string) {
		this.error = true;
		this.errorMessage = errorMessage;
		return this;
	}

	public SetStatus(status: string) {
		this.status = status;
		return this;
	}

	public SetData(data: unknown) {
		this.data = data;
		return this;
	}

	public Build(): ServerResponse {
		return {
			status: this.status,
			error: this.error,
			errorMessage: this.errorMessage,
			data: this.data,
		};
	}
}
