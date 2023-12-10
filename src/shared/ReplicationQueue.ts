import BitBuffer from "@rbxts/bitbuffer";

export interface ReplicatorI {}

export default class ReplicationQueue {
	public queue: { buffer: BitBuffer; rollback?: (buffer: BitBuffer) => void }[] = [];
	constructor() {}

	// public Add(key: string, buffer: BitBuffer, rollback?: (buffer: BitBuffer) => void) {
	// 	const keyBuffer = BitBuffer();
	// 	keyBuffer.writeString(key);

	// 	const finalBuffer = BitBuffer(keyBuffer.dumpString() + buffer.dumpString());

	// 	this.queue.push({
	// 		buffer: finalBuffer,
	// 		rollback: rollback,
	// 	});
	// }

	public Append(key: string, buffer: BitBuffer, rollback?: (buffer: BitBuffer) => void) {
		const keyBuffer = BitBuffer();
		keyBuffer.writeString(key);

		const finalBuffer = BitBuffer(keyBuffer.dumpString() + buffer.dumpString());

		this.queue.push({
			buffer: finalBuffer,
			rollback: rollback,
		});
	}

	public Dump() {
		const dump = [];
		for (const data of this.queue) {
			dump.push(data.buffer.dumpString());
		}
		return dump;
	}
}
