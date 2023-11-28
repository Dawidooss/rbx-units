import GameStore from "./Stores/GameStore";
import BitBuffer from "@rbxts/bitbuffer";

export default abstract class Store<T> {
	public name: string = "Store";
	public gameStore: GameStore;
	public cache = new Map<string, T>();

	constructor(gameStore: GameStore) {
		this.gameStore = gameStore;
	}

	public OverrideData(buffer: BitBuffer) {
		this.cache.clear();

		while (buffer.readString() === "+") {
			const unitData = this.Deserialize(buffer);
			this.Add(unitData);
		}
	}

	public SerializeCache(buffer?: BitBuffer): BitBuffer {
		buffer ||= BitBuffer();

		for (const [_, data] of this.cache) {
			buffer.writeString("+");
			this.Serialize(data, buffer);
		}
		buffer.writeString("-");

		return buffer;
	}

	public Remove(key: string) {
		this.cache.delete(key);
	}

	abstract Add(value: T): void;
	abstract Serialize(data: T, buffer?: BitBuffer): BitBuffer;
	abstract Deserialize(buffer: BitBuffer): T;
}
