import BitBuffer from "@rbxts/bitbuffer";
import { Sedes } from "shared/Sedes";

export default abstract class Store<T extends { id: number }> {
	public name: string = "Store";
	public cache = new Map<number, T>();
	public freeIds: number[] = [];
	public max = 0;
	public serializer: Sedes.Serializer<T>;

	constructor(serializer: Sedes.Serializer<T>, max: number) {
		this.max = max;
		this.serializer = serializer;

		this.CalculateFreeIds();
	}

	public CalculateFreeIds() {
		this.freeIds.clear();
		for (let i = 0; i < this.max; i++) {
			if (!this.cache.get(i)) {
				this.freeIds.push(i);
			}
		}
	}

	public OverrideCache(newCache: Map<number, T>) {
		this.Clear();
		this.cache = newCache;
	}

	public Remove(key: number) {
		this.cache.delete(key);
		this.freeIds.push(key);
	}

	public Add(value: T): T {
		this.cache.set(value.id, value);
		const i = this.freeIds.find((v) => {
			return v === value.id;
		});
		if (i) this.freeIds.remove(i);
		return value;
	}

	public Clear() {
		this.cache.clear();
	}

	public SerializeCache(buffer?: BitBuffer): BitBuffer {
		buffer ||= BitBuffer();

		for (const [_, data] of this.cache) {
			buffer.writeBits(1);
			this.serializer.Ser(data, buffer);
		}
		buffer.writeBits(0);

		return buffer;
	}
}
