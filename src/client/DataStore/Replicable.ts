import ActionsQueue from "client/Actions";
import Replicator from "./Replicator";

const replicator = Replicator.Get();

export class Replicable {
	public actionsQueue: ActionsQueue = new ActionsQueue();
	constructor() {
		replicator.AddReplicable(this);
	}
}
