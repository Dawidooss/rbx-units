import GameStore from "./Stores/GameStoreBase";
import BitBuffer from "@rbxts/bitbuffer";

interface idI {
	id: number;
}

export default abstract class Store<T extends idI> {
	public name: string = "Store";
	public gameStore: GameStore;
	public cache = new Map<number, T>();
	public freeIds: number[] = [];
	public max = 0;

	constructor(gameStore: GameStore, max: number) {
		this.gameStore = gameStore;
		this.max = max;

		for (let i = 0; i < max; i++) {
			this.freeIds.push(i);
		}
	}

	public OverrideData(buffer: BitBuffer) {
		this.Clear();

		while (buffer.readBits(1)[0] === 1) {
			const data = this.Deserialize(buffer);
			this.Add(data);
		}
	}

	public SerializeCache(buffer?: BitBuffer): BitBuffer {
		buffer ||= BitBuffer();

		for (const [_, data] of this.cache) {
			buffer.writeBits(1);
			this.Serialize(data, buffer);
		}
		buffer.writeBits(0);

		return buffer;
	}

	public Remove(key: number) {
		this.cache.delete(key);
		this.freeIds.push(key);
	}

	public Clear() {
		this.cache.clear();
	}

	public Add(value: T): T {
		this.cache.set(value.id, value);
		const i = this.freeIds.find((v) => {
			return v === value.id;
		});
		if (i) this.freeIds.remove(i);
		return value;
	}
	abstract Serialize(data: T, buffer?: BitBuffer): BitBuffer;
	abstract Deserialize(buffer: BitBuffer): T;
}
