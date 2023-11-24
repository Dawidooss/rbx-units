import GameStore from "shared/DataStore/Stores/GameStore";
import ClientReplicator from "./ClientReplicator";
import ClientTeamsStore from "./ClientTeamsStore";
import ClientPlayersStore from "./ClientPlayersStore";
import ClientUnitsStore from "./ClientUnitsStore";
import BitBuffer from "@rbxts/bitbuffer";

const replicator = ClientReplicator.Get();

export default class ClientGameStore extends GameStore {
	private static instance: ClientGameStore;
	constructor() {
		super();
		if (ClientGameStore.instance) return;

		ClientGameStore.instance = this;

		this.AddStore(new ClientTeamsStore(this));
		this.AddStore(new ClientPlayersStore(this));
		this.AddStore(new ClientUnitsStore(this));

		const defaultData = replicator.FetchAll();
		if (!defaultData) {
			// TODO warn
			return;
		}
		this.OverrideAll(defaultData);
	}

	public OverrideAll(buffer: BitBuffer) {
		while (buffer.getPointerByte() !== buffer.getByteLength()) {
			const storeName = buffer.readString();
			this.GetStore(storeName)?.OverrideData(buffer);
		}
	}

	public static Get() {
		return ClientGameStore.instance || new ClientGameStore();
	}
}
