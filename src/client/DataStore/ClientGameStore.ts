import GameStore from "shared/DataStore/Stores/GameStore";
import ClientReplicator from "./ClientReplicator";
import ClientTeamsStore from "./ClientTeamsStore";
import ClientPlayersStore from "./ClientPlayersStore";
import ClientUnitsStore from "./ClientUnitsStore";

export default class ClientGameStore extends GameStore {
	public replicator = new ClientReplicator(this);

	private static instance: ClientGameStore;
	constructor() {
		super();
		if (ClientGameStore.instance) return;

		ClientGameStore.instance = this;

		this.AddStore(new ClientTeamsStore(this));
		this.AddStore(new ClientPlayersStore(this));
		this.AddStore(new ClientUnitsStore(this));

		this.replicator.FetchAll();
	}

	public static Get() {
		return ClientGameStore.instance || new ClientGameStore();
	}
}
