import Store from "../Store";
import { Sedes } from "shared/Sedes";

export default class TeamsStoreBase extends Store<TeamData> {
	public name = "TeamsStore";

	constructor() {
		const serializer = new Sedes.Serializer<TeamData>([
			["id", Sedes.ToUnsigned(4)],
			["name", Sedes.ToString()],
			["color", Sedes.ToColor3()],
		]);
		super(serializer, 128);
	}
}

export type TeamData = {
	id: number;
	name: string;
	color: Color3;
};
