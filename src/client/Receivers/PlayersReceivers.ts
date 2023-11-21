import Network from "shared/Network";
import ReceiverBase from "./ReceiverBase";
import TeamStore, { SerializedTeamParameters, TeamParameters } from "shared/Game/TeamStore";
import GameStore, { Unasigned } from "shared/Game/GameStore";
import Receivers from "./Receivers";

const gameStore = GameStore.Get();
const receivers = Receivers.Get();

export default class PlayersReceiver implements ReceiverBase {
	public type = "Players";

	constructor() {
		Network.BindEvents({
			playerJoined: (player: Player) => {
				if (gameStore.players.has(player)) return;
				gameStore.players.set(player, Unasigned);
			},
			playerRemoving: (player: Player) => {
				const team = gameStore.players.get(player);
				if (team instanceof TeamStore) {
					team.RemovePlayer(player);
				}
				gameStore.players.delete(player);
			},
		});
	}

	public FetchAll() {
		gameStore.players.clear();
		let playersWithTeam = Network.InvokeServer(this.type);

		let fetchedTeams = false;
		for (let [player, teamId] of playersWithTeam) {
			player = player as Player;
			teamId = teamId as string;

			if (teamId !== "") {
				const team = gameStore.teams.get(teamId);
				if (!team && !fetchedTeams) {
					receivers.GetReceiver("Teams")?.FetchAll();
					fetchedTeams = true;
				}
			}

			if (gameStore.players.has(player)) continue;
		}
	}

	public Serialize() {}

	public Destroy(): void {}
}
