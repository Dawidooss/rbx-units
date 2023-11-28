import Network from "shared/Network";
import BitBuffer from "@rbxts/bitbuffer";
import ReplicationQueue from "shared/ReplicationQueue";
import { Players } from "@rbxts/services";

export default class ServerReplicator {
	private connections: { [key: string]: (player: Player, buffer: BitBuffer) => ServerResponse } = {};

	private static instance: ServerReplicator;
	constructor() {
		ServerReplicator.instance = this;

		Network.BindFunctions({
			"chunked-data": (player: Player, data: string) => {
				const mainResponse = new ServerResponseBuilder();
				ReplicationQueue.Divide(data, (key: string, buffer: BitBuffer) => {
					assert(this.connections[key], `Connection ${key} missing in ServerReplicator`);
					const response = this.connections[key](player, buffer);

					if (response.data) mainResponse.SetData(response.data);
					if (response.errorMessage) mainResponse.SetError(response.errorMessage);
					if (response.status) mainResponse.SetStatus(response.status);
				});

				return [mainResponse];
			},
		});
	}

	public Replicate(player: Player, queue: ReplicationQueue) {
		const response = new ServerResponseBuilder().SetData(queue.DumpString()).Build();
		Network.FireClient(player, "chunked-data", response);
	}

	public ReplicateExcept(player: Player, queue: ReplicationQueue) {
		const response = new ServerResponseBuilder().SetData(queue.DumpString()).Build();
		Network.FireOtherClients(player, "chunked-data", response);
	}

	public ReplicateAll(queue: ReplicationQueue) {
		const response = new ServerResponseBuilder().SetData(queue.DumpString()).Build();
		Network.FireAllClients("chunked-data", response);
	}

	public Connect(key: string, callback: (player: Player, buffer: BitBuffer) => ServerResponse) {
		this.connections[key] = callback;
	}

	public static Get() {
		return ServerReplicator.instance || new ServerReplicator();
	}
}

export class ServerResponseBuilder {
	private status: string = "";
	private error: boolean = false;
	private errorMessage?: string;
	private data?: string;

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

	public SetData(data: string) {
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
