import { HttpService, Players } from "@rbxts/services";
import ServerGameStore from "./DataStore/ServerGameStore";
import ServerPlayersStore from "./DataStore/ServerPlayersStore";
import ServerTeamsStore from "./DataStore/ServerTeamsStore";

const gameStore = ServerGameStore.Get();
const teamsStore = gameStore.GetStore("TeamsStore") as ServerTeamsStore;
const playersStore = gameStore.GetStore("PlayersStore") as ServerPlayersStore;

const redTeamId = HttpService.GenerateGUID(false);
const redTeam = teamsStore.Add({
	name: "Red",
	id: redTeamId,
	color: new Color3(1, 0, 0),
});

Players.PlayerAdded.Connect((player) => {
	playersStore.Add({
		player: player,
		teamId: redTeamId,
	});

	player.CharacterAdded.Connect((character) => {
		const humanoidRootPart = character.WaitForChild("HumanoidRootPart") as BasePart;
		const humanoid = character.WaitForChild("Humanoid") as Humanoid;

		humanoidRootPart.Anchored = true;
		humanoid.WalkSpeed = 0;
	});
});
