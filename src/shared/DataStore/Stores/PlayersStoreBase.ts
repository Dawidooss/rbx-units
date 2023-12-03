import Store from "../Store";
import { Players } from "@rbxts/services";
import BitBuffer from "@rbxts/bitbuffer";
import bit from "shared/bit";
import GameStoreBase from "./GameStoreBase";

export default class PlayersStoreBase extends Store<PlayerData> {
	public name = "PlayersStore";

	constructor(gameStore: GameStoreBase) {
		super(gameStore, 128);
	}

	public Serialize(playerData: PlayerData, buffer?: BitBuffer): BitBuffer {
		buffer ||= BitBuffer();
		buffer.writeString(tostring(playerData.player.UserId));
		buffer.writeBits(...bit.ToBits(playerData.teamId, 4));

		return buffer;
	}

	public Deserialize(buffer: BitBuffer): PlayerData {
		const playerId = tonumber(buffer.readString())!;
		const player = Players.GetPlayerByUserId(playerId)!;

		return {
			id: playerId,
			player: player,
			teamId: bit.FromBits(buffer.readBits(4)),
		};
	}
}

export type PlayerData = {
	id: number;
	player: Player;
	teamId: number;
};
