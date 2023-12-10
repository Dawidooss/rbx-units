import Store from "../Store";
import { Sedes } from "shared/Sedes";

export default class PlayersStoreBase extends Store<PlayerData> {
	public name = "PlayersStore";

	constructor() {
		const serializer = new Sedes.Serializer<PlayerData>([
			["id", Sedes.ToUnsigned(40)],
			["teamId", Sedes.ToUnsigned(4)],
		]);
		super(serializer, 128);
	}
}

export type PlayerData = {
	id: number;
	teamId: number;
};
