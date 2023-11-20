import { HttpService } from "@rbxts/services";
import GameStore from "./GameStore";
import TeamStore, { TeamDetails } from "./TeamStore";
import UnitsCache from "./UnitsCache";

export default class TeamsCache {
	public cache = new Map<string, TeamStore>();

	private playerToTeam = new Map<Player, TeamStore>();

	constructor() {}

	public AddTeam(teamDetails?: TeamDetails) {
		const id = HttpService.GenerateGUID(false);
		const teamStore = new TeamStore(id, teamDetails);
		this.cache.set(id, teamStore);

		return teamStore;
	}

	public RemoveTeam(teamStore: string | TeamStore) {
		if (teamStore instanceof TeamStore) {
			for (let [id, v] of this.cache) {
				if (v === teamStore) {
					this.cache.delete(id);
					break;
				}
			}
		} else {
			this.cache.delete(teamStore);
		}
	}

	public GetPlayerTeam(player: Player) {
		return this.playerToTeam.get(player);
	}

	public GetTeam(teamId: string) {
		return this.cache.get(teamId);
	}
}
