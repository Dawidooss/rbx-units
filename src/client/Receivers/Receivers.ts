import GameStore from "../../shared/Game/GameStore";
import ReceiverBase from "./ReceiverBase";
import UnitsReceiver from "./UnitsReceiver";

export default class Receivers {
	private static instance: Receivers;
	public replicators = new Map<string, ReceiverBase>();

	constructor() {
		Receivers.instance = this;

		this.AddReplicator(new UnitsReceiver());
	}

	public AddReplicator(replicator: ReceiverBase) {
		this.replicators.set(replicator.type, replicator);
	}

	public FetchAll() {
		for (const [_, replicator] of this.replicators) {
			replicator.FetchAll();
		}
	}

	public GetReplicator(type: string) {
		return this.replicators.get(type);
	}

	public static Get() {
		return Receivers.instance || new Receivers();
	}
}
