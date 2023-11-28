import ClientReplicator from "./Replicator";
import BitBuffer from "@rbxts/bitbuffer";
import GameStoreBase from "shared/DataStore/Stores/GameStoreBase";
import TeamsStore from "./TeamsStore";
import PlayersStore from "./PlayersStore";
import UnitsStore from "./UnitsStore";

const replicator = ClientReplicator.Get();

export default class GameStore extends GameStoreBase {
	private static instance: GameStore;
	constructor() {
		super();
		if (GameStore.instance) return;

		GameStore.instance = this;

		this.AddStore(new TeamsStore(this));
		this.AddStore(new PlayersStore(this));
		this.AddStore(new UnitsStore(this));

		this.Init();
	}

	public async Init() {
		const defaultData = await replicator.FetchAll().catch(() => {
			warn("couldn't not fetch data");
			// TODO: exit game?
		});
		if (!defaultData) {
			return;
		}
		this.OverrideAll(defaultData);
	}

	public OverrideAll(buffer: BitBuffer) {
		while (buffer.getPointerByte() < buffer.getByteLength()) {
			const storeName = buffer.readString();
			this.GetStore(storeName)?.OverrideData(buffer);
		}
		replicator.replicationEnabled = true;
	}

	public static Get() {
		return GameStore.instance || new GameStore();
	}
}
