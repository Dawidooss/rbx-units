wait(2); // loading map

import { HttpService, Players } from "@rbxts/services";
import GameStore from "./DataStore/GameStore";
import PlayersStore from "./DataStore/PlayersStore";
import TeamsStore from "./DataStore/TeamsStore";
import UnitsStore from "./DataStore/UnitsStore";
import { UnitData } from "shared/DataStore/Stores/UnitsStoreBase";

const gameStore = GameStore.Get();
gameStore.AddStore(new TeamsStore(gameStore));
gameStore.AddStore(new PlayersStore(gameStore));
gameStore.AddStore(new UnitsStore(gameStore));

const teamsStore = gameStore.GetStore("TeamsStore") as TeamsStore;
const playersStore = gameStore.GetStore("PlayersStore") as PlayersStore;
const unitsStore = gameStore.GetStore("UnitsStore") as UnitsStore;

const redTeam = teamsStore.Add({
	name: "Red",
	id: 0,
	color: new Color3(1, 0, 0),
});

const unitId = unitsStore.freeIds.shift();
if (unitId) {
	unitsStore.Add(new UnitData(unitId, "Dummy", new Vector3(-31, 0.5, -57), 15, []));
}

Players.PlayerAdded.Connect((player) => {
	playersStore.Add({
		id: player.UserId,
		player: player,
		teamId: 0,
	});

	player.CharacterAdded.Connect((character) => {
		const humanoidRootPart = character.WaitForChild("HumanoidRootPart") as BasePart;
		const humanoid = character.WaitForChild("Humanoid") as Humanoid;

		humanoidRootPart.Anchored = true;
		humanoid.WalkSpeed = 0;
	});
});
