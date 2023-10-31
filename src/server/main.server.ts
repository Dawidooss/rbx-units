import { Players } from "@rbxts/services";

Players.PlayerAdded.Connect((player) => {
	player.CharacterAdded.Connect((character) => {
		const humanoidRootPart = character.WaitForChild("HumanoidRootPart") as BasePart;
		const humanoid = character.WaitForChild("Humanoid") as Humanoid;

		humanoidRootPart.Anchored = true;
		humanoid.WalkSpeed = 0;
	});
});
