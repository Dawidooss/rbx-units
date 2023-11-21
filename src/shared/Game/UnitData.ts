import Squash from "@rbxts/squash";
import TeamStore from "./TeamStore";
import GameStore from "./GameStore";

export class UnitData {
	public position: Vector3;
	public targetPosition: Vector3;
	public team: TeamStore;
	public id: string;

	constructor(params: UnitParameters) {
		this.position = params?.position || new Vector3();
		this.targetPosition = params?.position || new Vector3();
		this.team = params.team;
		this.id = params.id;
	}

	public Serialize(): SerializedUnitParameters {
		return {
			position: Squash.Vector3.ser(this.position),
			targetPosition: Squash.Vector3.ser(this.targetPosition),
			teamId: Squash.string.ser(this.team.id),
			id: Squash.string.ser(this.id),
		};
	}

	public static FromSerialized(data: SerializedUnitParameters) {
		const teamId = Squash.string.des(data.teamId);
		const team = GameStore.Get().teams.get(teamId);

		if (!team) {
			// Receivers.Get().GetReplicator("Teams")?.FetchAll();
			const team = GameStore.Get().teams.get(teamId);
			assert(team, `Team with id: ${teamId} doesn't exist and cannot be fetched.`);
		}

		const deserializedData = {
			position: Squash.Vector3.des(data.position),
			targetPosition: Squash.Vector3.des(data.targetPosition),
			id: Squash.string.des(data.targetPosition),
			team: team,
		} as UnitParameters;

		return new UnitData(deserializedData);
	}
}

export type UnitParameters = {
	position?: Vector3;
	targetPosition?: Vector3;
	team: TeamStore;
	id: string;
};

export type SerializedUnitParameters = {
	position: string;
	targetPosition: string;
	teamId: string;
	id: string;
};
