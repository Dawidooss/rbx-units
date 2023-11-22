import Store from "../Store";
import { Players } from "@rbxts/services";
import TeamsStore, { TeamData } from "./TeamStore";

export default class PlayersStore extends Store<PlayerData, SerializedPlayerData> {
	public name = "PlayersStore";
	public cache = new Map<string, PlayerData>();

	public AddPlayer(playerData: PlayerData): PlayerData {
		this.cache.set(tostring(playerData.player.UserId), playerData);
		return playerData;
	}

	public RemovePlayer(playerId: string) {
		this.cache.delete(playerId);
	}

	public OverrideData(serializedPlayerDatas: SerializedPlayerData[]) {
		this.cache.clear();

		for (const serializedPlayerData of serializedPlayerDatas) {
			const playerData = this.Deserialize(serializedPlayerData);
			this.AddPlayer(playerData);
		}
	}

	public Serialize(playerData: PlayerData): SerializedPlayerData {
		return {
			playerId: playerData.player.UserId,
			teamId: playerData.team.id,
		};
		// return {
		// 	playerId: Squash.int.ser(playerData.player.UserId),
		// 	teamId: Squash.string.ser(playerData.team.id),
		// };
	}

	public Deserialize(serializedPlayerData: SerializedPlayerData): PlayerData {
		const playerId = serializedPlayerData.playerId;
		const player = Players.GetPlayerByUserId(playerId)!;

		const teamId = serializedPlayerData.teamId;
		const team = (this.gameStore.GetStore("TeamsStore") as TeamsStore).cache.get(teamId)!;

		return {
			player: player,
			team: team,
		};
	}
}

export type PlayerData = {
	player: Player;
	team: TeamData;
};

export type SerializedPlayerData = {
	playerId: number;
	teamId: string;
};

export type Unasigned = undefined;
