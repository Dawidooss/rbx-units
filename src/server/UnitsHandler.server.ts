import Squash from "@rbxts/squash";
import Network from "shared/Network";

Network.BindEvents({
	createUnit: (player: Player, unitName: any, position: any) => {
		// checks TODO
		unitName = Squash.string.des(unitName);
		position = Squash.Vector3.des(position);
		Network.FireAllClients("createUnit", unitName, position);
	},
});
