import Network from "shared/Network";
import ReceiverBase from "./ReceiverBase";
import { RunService, Teams } from "@rbxts/services";
import { UnitData } from "shared/Game/UnitData";
import TeamStore, { SerializedTeamParameters, TeamParameters } from "shared/Game/TeamStore";
import GameStore from "shared/Game/GameStore";
import Receivers from "./Receivers";

const gameStore = GameStore.Get();

export default class TeamsReceiver implements ReceiverBase {
	public type = "Teams";

	constructor() {
		Network.BindEvents({
			createTeam: (serializedTeamParameters: SerializedTeamParameters) => {
				const team = TeamStore.FromSerialized(serializedTeamParameters);

				if (gameStore.teams.has(team.id)) {
					this.FetchAll();
					Receivers.Get().GetReceiver("Players")?.FetchAll();
					return;
				}

				gameStore.teams.set(team.id, team);
			},
		});
	}

	public FetchAll() {
		gameStore.teams.clear();
		let serializedTeamsParameters = Network.InvokeServer(this.type) as [SerializedTeamParameters];
		for (const teamParameters of serializedTeamsParameters) {
			const team = TeamStore.FromSerialized(teamParameters);
			gameStore.teams.set(team.id, team);
		}
	}

	public Serialize() {}

	public Destroy(): void {}
}
