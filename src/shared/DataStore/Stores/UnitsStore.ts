import Store from "../Store";
import { Players } from "@rbxts/services";
import TeamsStore, { TeamData } from "./TeamStore";
import PlayersStore, { PlayerData } from "./PlayersStore";
import { uint } from "@rbxts/squash";
import Utils from "shared/Utils";

export default class UnitsStore extends Store<UnitData, SerializedUnitData> {
	public name = "UnitsStore";
	public cache = new Map<string, UnitData>();

	public AddUnit(unitData: UnitData): UnitData {
		this.cache.set(unitData.id, unitData);
		return unitData;
	}

	public RemoveUnit(unitId: string) {
		this.cache.delete(unitId);
	}

	public OverrideData(serializedUnitDatas: SerializedUnitData[]) {
		this.cache.clear();

		for (const serializedUnitData of serializedUnitDatas) {
			const unitData = this.Deserialize(serializedUnitData);
			this.AddUnit(unitData);
		}
	}

	public Serialize(unitData: UnitData): SerializedUnitData {
		return {
			id: unitData.id,
			type: unitData.type,
			position: unitData.position,
			playerId: unitData.playerData.player.UserId,

			targetPosition: unitData.targetPosition,
			movementStartTick: unitData.movementStartTick,
			movementEndTick: unitData.movementEndTick,
		};
	}

	public Deserialize(serializedUnitData: SerializedUnitData): UnitData {
		const playerId = serializedUnitData.playerId;
		const player = Players.GetPlayerByUserId(playerId)!;
		const playerData = (this.gameStore.GetStore("PlayersStore") as PlayersStore).cache.get(
			tostring(player.UserId),
		)!;

		return {
			id: serializedUnitData.id,
			type: serializedUnitData.type,
			position: serializedUnitData.position,
			playerData: playerData,

			targetPosition: serializedUnitData.targetPosition,
			movementStartTick: serializedUnitData.movementStartTick,
			movementEndTick: serializedUnitData.movementEndTick,
		};
	}
}

export type UnitData = {
	id: string;
	type: string;
	position: Vector3;
	playerData: PlayerData;

	targetPosition: Vector3;
	movementStartTick: number;
	movementEndTick: number;
};

export type SerializedUnitData = {
	id: string;
	type: string;
	position: Vector3;
	playerId: number;

	targetPosition: Vector3;
	movementStartTick: number;
	movementEndTick: number;
};
