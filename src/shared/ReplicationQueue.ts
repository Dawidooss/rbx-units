import BitBuffer from "@rbxts/bitbuffer";

export default class ReplicationQueue {
	private buffer = BitBuffer();
	constructor() {}

	public Add(key: string, writeCallback?: (buffer: BitBuffer) => void) {
		this.buffer.writeString(key);
		writeCallback?.(this.buffer);
	}

	public DumpString() {
		return this.buffer.dumpString();
	}

	public static Divide(serializedBuffer: string, chunkCallback: (key: string, buffer: BitBuffer) => void) {
		const buffer = BitBuffer(serializedBuffer);

		print(buffer.getByteLength());
		// last char is "-" so end of
		while (buffer.getPointerByte() < buffer.getByteLength()) {
			print(buffer.getPointerByte());
			const key = buffer.readString();
			chunkCallback(key, buffer);
		}
	}
}
