import GameStore from "shared/Game/GameStore";
import Replication from "../client/Receivers/Receivers";

export default class GameHandler {
	private static instance: GameHandler;

	public state = GameState.Lobby;
	public gameStore = new GameStore();

	constructor() {
		if (GameHandler.instance) return;

		GameHandler.instance = this;
	}

	public StartGame() {
		if (this.state === GameState.Live) return;

		this.state = GameState.Live;
	}

	public static Get() {
		return GameHandler.instance || new GameHandler();
	}
}

export enum GameState {
	Live,
	Lobby,
}
