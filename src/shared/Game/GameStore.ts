import TeamsCache from "./TeamsCache";

export default class GameStore {
	private static instance: GameStore;

	public teams = new TeamsCache();

	constructor() {}

	public static Get() {
		return GameStore.instance || new GameStore();
	}
}
