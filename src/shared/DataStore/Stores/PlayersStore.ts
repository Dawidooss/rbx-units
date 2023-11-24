import Store from "../Store";
import { Players } from "@rbxts/services";
import BitBuffer from "@rbxts/bitbuffer";

export default class PlayersStore extends Store<PlayerData> {
	public name = "PlayersStore";

	public Add(playerData: PlayerData): PlayerData {
		this.cache.set(tostring(playerData.player.UserId), playerData);
		return playerData;
	}

	public Serialize(playerData: PlayerData, buffer?: BitBuffer): BitBuffer {
		buffer ||= BitBuffer();
		buffer.writeUInt32(playerData.player.UserId);
		buffer.writeString(playerData.teamId);

		return buffer;
	}

	public Deserialize(buffer: BitBuffer): PlayerData {
		const playerId = buffer.readUInt32();
		const player = Players.GetPlayerByUserId(playerId)!;

		return {
			player: player,
			teamId: buffer.readString(),
		};
	}
}

export type PlayerData = {
	player: Player;
	teamId: string;
};
