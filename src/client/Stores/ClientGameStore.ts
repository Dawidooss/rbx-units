import GameStore from "shared/DataStore/GameStore";
import Replicator from "./Replicator";
import ClientTeamsStore from "./ClientTeamsStore";

export default class ClientGameStore extends GameStore {
	public replicator = new Replicator(this);

	private static instance: ClientGameStore;
	constructor() {
		super()
		if (ClientGameStore.instance) return;

		ClientGameStore.instance = this;

		this.AddStore(new ClientTeamsStore(this));

		this.replicator.FetchAll();
	}

	public static Get() {
		return ClientGameStore.instance || new ClientGameStore();
	}
}
