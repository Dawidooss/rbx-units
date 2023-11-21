import { number } from "@rbxts/squash";
import ReceiverBase from "./ReceiverBase";
import UnitsReceiver from "./UnitsReceiver";
import TeamsReceiver from "./TeamsReceiver";

export default class Receivers {
	private static instance: Receivers;
	public receivers = new Array<ReceiverBase>();

	constructor() {
		Receivers.instance = this;

		this.AddReceiver(new TeamsReceiver());
		this.AddReceiver(new UnitsReceiver());

		this.FetchAll();
	}

	public AddReceiver(receiver: ReceiverBase) {
		this.receivers.push(receiver);
	}

	public FetchAll() {
		for (const receiver of this.receivers) {
			receiver.FetchAll();
		}
	}

	public GetReceiver(type: string) {
		for (const receiver of this.receivers) {
			if (receiver.type === type) {
				return receiver;
			}
		}
	}

	public static Get() {
		return Receivers.instance || new Receivers();
	}
}
