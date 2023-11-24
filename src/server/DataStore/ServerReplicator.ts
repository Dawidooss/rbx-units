import Network from "shared/Network";
import GameStore from "./ServerGameStore";
import BitBuffer from "@rbxts/bitbuffer";

export default class ServerReplicator {
	private static instance: ServerReplicator;
	constructor() {
		ServerReplicator.instance = this;
	}

	public Replicate(player: Player, key: string, buffer: BitBuffer) {
		const response = new ServerResponseBuilder().SetData(buffer.dumpString()).Build();
		Network.FireClient(player, key, response);
	}

	public ReplicateAll(key: string, buffer: BitBuffer) {
		const response = new ServerResponseBuilder().SetData(buffer.dumpString()).Build();
		Network.FireAllClients(key, response);
	}

	public ReplicateExcept(player: Player, key: string, buffer: BitBuffer) {
		const response = new ServerResponseBuilder().SetData(buffer.dumpString()).Build();
		Network.FireOtherClients(player, key, response);
	}

	public Connect(key: string, callback: Callback) {
		Network.BindFunctions({
			[key]: callback,
		});
	}

	public static Get() {
		return ServerReplicator.instance || new ServerReplicator();
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
