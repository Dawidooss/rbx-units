import Squash from "@rbxts/squash";
import GameStore from "./GameStore";
import UnitsCache from "./UnitsCache";
import { UnitData } from "./UnitData";

export default class TeamStore {
	public details: TeamDetails;
	public id: string;

	public players = new Set<Player>();
	public units = new UnitsCache(this);

	public constructor(id: string, teamDetails?: TeamDetails) {
		this.id = id;
		this.details = teamDetails || new TeamDetails();
	}

	public AddPlayer(player: Player) {
		this.players.add(player);
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
		const team = GameStore.Get().teams.GetTeam(teamId);

		const deserializedData = {
			position: Squash.Vector3.des(data.position),
			targetPosition: Squash.Vector3.des(data.targetPosition),
			id: Squash.string.des(data.targetPosition),
			team: team,
		} as UnitParameters;

		return new UnitData(deserializedData);
	}
}

export type TeamParameters = {
	players: Set<Player>;
	units: UnitsCache();
};

export type SerializedTeamParameters = {};
