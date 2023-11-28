wait(2); // loading map

import { HttpService, Players } from "@rbxts/services";
import ServerGameStore from "./DataStore/ServerGameStore";
import ServerPlayersStore from "./DataStore/ServerPlayersStore";
import ServerTeamsStore from "./DataStore/ServerTeamsStore";
import ServerUnitsStore from "./DataStore/ServerUnitsStore";
import { UnitData } from "shared/DataStore/Stores/UnitsStoreBase";

const gameStore = ServerGameStore.Get();
gameStore.AddStore(new ServerTeamsStore(gameStore));
gameStore.AddStore(new ServerPlayersStore(gameStore));
gameStore.AddStore(new ServerUnitsStore(gameStore));

const teamsStore = gameStore.GetStore("TeamsStore") as ServerTeamsStore;
const playersStore = gameStore.GetStore("PlayersStore") as ServerPlayersStore;
const unitsStore = gameStore.GetStore("UnitsStore") as ServerUnitsStore;

const redTeamId = HttpService.GenerateGUID(false);
const redTeam = teamsStore.Add({
	name: "Red",
	id: redTeamId,
	color: new Color3(1, 0, 0),
});

unitsStore.Add(new UnitData(HttpService.GenerateGUID(false), "Dummy", new Vector3(-31, 0.5, -57), 15, []));

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
