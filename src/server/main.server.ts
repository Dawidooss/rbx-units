wait(2); // loading map

import { Players } from "@rbxts/services";
import PlayersStore from "./DataStore/PlayersStore";
import TeamsStore from "./DataStore/TeamsStore";
import UnitsStore from "./DataStore/UnitsStore";
import Network from "shared/Network";

Network.BindFunctions({});

const teamsStore = TeamsStore.Get();
const playersStore = PlayersStore.Get();
const unitsStore = UnitsStore.Get();

teamsStore.Add({
	name: "Red",
	id: 0,
	color: new Color3(1, 0, 0),
});

Players.PlayerAdded.Connect((player) => {
	playersStore.Add({
		id: player.UserId,
		teamId: 0,
	});

	player.CharacterAdded.Connect((character) => {
		const humanoidRootPart = character.WaitForChild("HumanoidRootPart") as BasePart;
		const humanoid = character.WaitForChild("Humanoid") as Humanoid;

		humanoidRootPart.Anchored = true;
		humanoid.WalkSpeed = 0;
	});
});
