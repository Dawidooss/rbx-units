import BitBuffer from "@rbxts/bitbuffer";

export default class ReplicationQueue {
	public queue: BitBuffer[] = [];
	constructor() {}

	public Add(key: string, writeCallback?: (buffer: BitBuffer) => BitBuffer) {
		const buffer = BitBuffer();
		buffer.writeString(key);

		if (writeCallback) {
			writeCallback(buffer);
		}

		this.queue.push(buffer);
	}

	public Dump() {
		const dump = [];
		for (const buffer of this.queue) {
			dump.push(buffer.dumpString());
		}
		return dump;
	}
}
