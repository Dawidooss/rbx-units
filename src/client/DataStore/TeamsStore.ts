import { Sedes } from "shared/Sedes";
import Replicator from "./Replicator";
import TeamsStoreBase, { TeamData } from "shared/DataStore/Stores/TeamStoreBase";

const replicator = Replicator.Get();

export default class TeamsStore extends TeamsStoreBase {
	public static instance: TeamsStore;
	constructor() {
		super();

		// replicator.Connect("team-added", (buffer: BitBuffer) => {
		// 	const teamData = this.Deserialize(buffer);

		// 	if (this.cache.get(teamData.id)) return;

		// 	this.Add(teamData);
		// });

		// replicator.Connect("team-removed", (buffer: BitBuffer) => {
		// 	const teamId = bit.FromBits(buffer.readBits(4));
		// 	this.Remove(teamId);
		// });

		// replicator.Connect(this.name, this.serializer, (data) => {
		// 	this.OverrideCache(data);
		// });

		const fetchSerializer = new Sedes.Serializer<{
			data: Map<number, TeamData>;
		}>([["data", Sedes.ToDict<number, TeamData>(Sedes.ToUnsigned(4), this.serializer)]]);

		replicator.Connect("units-store", fetchSerializer, (data) => {
			this.OverrideCache(data.data);
		});

		TeamsStore.instance = this;
	}

	public static Get() {
		return TeamsStore.instance || new TeamsStore();
	}
}
