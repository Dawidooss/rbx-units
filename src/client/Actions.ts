import BitBuffer from "@rbxts/bitbuffer";

//                    key,    method
export type Action = [string, () => [BitBuffer, (() => void)?] | void];

export default class ActionsQueue {
	private queue: Action[] = [];
	public active: Action | undefined = undefined;

	public Append(key: string, method: () => [BitBuffer, (() => void)?] | void) {
		this.queue.push([key, method]);
	}

	public NextAction() {
		this.active = this.queue.shift();
		return this.active;
	}

	public IsEmpty() {
		return this.queue.size() === 0;
	}
}
