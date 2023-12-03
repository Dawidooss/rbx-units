import BitBuffer from "@rbxts/bitbuffer";

export default class ReplicationQueue {
	private buffer;
	constructor(initialBufferData?: string) {
		this.buffer = BitBuffer(initialBufferData);
	}

	public Add(key: string, writeCallback: (buffer: BitBuffer) => BitBuffer) {
		this.buffer.writeString(key);
		this.buffer = writeCallback(this.buffer);
	}

	public DumpString() {
		return this.buffer.dumpString();
	}

	public static Divide(serializedBuffer: string, chunkCallback: (key: string, buffer: BitBuffer) => void) {
		const buffer = BitBuffer(serializedBuffer);

		// last char is "-" so end of
		while (buffer.getPointerByte() < buffer.getByteLength()) {
			const key = buffer.readString();
			chunkCallback(key, buffer);
		}
	}
}
