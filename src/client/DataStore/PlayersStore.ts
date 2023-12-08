import { Sedes } from "shared/Sedes";
import ClientReplicator from "./Replicator";
import PlayersStoreBase, { PlayerData } from "shared/DataStore/Stores/PlayersStoreBase";
import Unit from "client/Units/Unit";
import BitBuffer from "@rbxts/bitbuffer";

const replicator = ClientReplicator.Get();

export default class PlayersStore extends PlayersStoreBase {
	private static instance: PlayersStore;
	constructor() {
		super();
		// replicator.Connect(
		// 	"player-added",
		// 	new QueueDeserializer<{
		// 		player: PlayerData;
		// 	}>([["player", Des.Array<PlayerData>(this.Deserialize)]], (data) => {
		// 		for (const playerData of data.players) {
		// 			this.Add(playerData);
		// 		}
		// 	}),
		// );

		// replicator.Connect(
		// 	"players-added",
		// 	new QueueDeserializer<{
		// 		players: PlayerData[];
		// 		test: PlayerData[];
		// 	}>([["player", Des.Array<PlayerData>(this.Deserialize)]], (data) => {
		// 		for (const playerData of data.players) {
		// 			this.Add(playerData);
		// 		}
		// 	}),
		// );

		// replicator.Connect("player-removed", (buffer: BitBuffer) => {
		// 	const playerId = tonumber(buffer.readString())!;
		// 	this.Remove(playerId);
		// });

		// replicator.Connect(this.name, new Sedes.Serializer<{
		// 	data: PlayerData[]
		// }([
		// 	["data", Sedes.ToArray<PlayerData>(this)]
		// ])>, (data) => {
		// 	this.OverrideData(data.buffer);
		// });

		// replicator.Connect(
		// 	this.name,
		// 	new Sedes.Serializer<{
		// 		data: Map<number, PlayerData>;
		// 	}>([["data", Sedes.ToDict<number, PlayerData>(Sedes.ToUnsigned(20), this.serializer)]]),
		// 	(data) => {
		// 		this.OverrideCache(data.data);
		// 	},
		// );

		const serializer = new Sedes.Serializer<{
			data: Map<number, PlayerData>;
		}>([["data", Sedes.ToDict<number, PlayerData>(Sedes.ToUnsigned(10), this.serializer)]]);

		replicator.Connect(this.name, serializer, (data) => {
			this.OverrideCache(data.data);
		});

		PlayersStore.instance = this;
	}

	public static Get() {
		return PlayersStore.instance || new PlayersStore();
	}
}
