import Squash from "@rbxts/squash";
import GameStore from "./GameStore";
import { UnitData } from "./UnitData";

const gameStore = GameStore.Get();

export default class TeamStore {
	public id: string;
	public name: string;
	public players = new Set<Player>();

	public constructor(teamParameters: TeamParameters) {
		this.id = teamParameters.id;
		this.name = teamParameters.name;

		if (teamParameters.players) {
			for (const player of teamParameters.players) {
				this.AssignPlayer(player);
			}
		}
	}

	public AssignPlayer(player: Player) {
		gameStore.players.set(player, this);
		this.players.add(player);
	}

	public RemovePlayer(player: Player) {
		gameStore.players.delete(player);
		this.players.delete(player);
	}

	public Serialize(): SerializedTeamParameters {
		const playersArray = [];
		for (const player of this.players) {
			playersArray.push(player);
		}

		return {
			id: Squash.string.ser(this.id),
			name: Squash.string.ser(this.name),
			players: playersArray,
		};
	}

	public static FromSerialized(data: SerializedTeamParameters) {
		const teamParameters = {
			id: Squash.string.des(data.id),
			name: Squash.string.des(data.name),
			players: new Set<Player>(data.players),
		} as TeamParameters;

		return new TeamStore(teamParameters);
	}
}

export type TeamParameters = {
	id: string;
	name: string;
	players?: Set<Player>;
};
export type SerializedTeamParameters = {
	id: string;
	name: string;
	players: Player[];
};
