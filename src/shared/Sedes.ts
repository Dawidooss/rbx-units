import BitBuffer from "@rbxts/bitbuffer";

// Sedes = Serdes = Serializer-Deserializer
export namespace Sedes {
	export class Serializer<T extends { [key: string]: any }> implements Sedes.Method<T> {
		private methods: [keyof T, Sedes.Method<any>][];

		constructor(methods: Serializer<T>["methods"]) {
			this.methods = methods;
		}

		public Des = (buffer: BitBuffer): T => {
			let data: { [k: string]: any } = {};
			for (const [key, method] of this.methods) {
				data[key as string] = method.Des(buffer);
			}
			return data as T;
		};

		public Ser = (data: T, buffer?: BitBuffer): BitBuffer => {
			buffer ||= BitBuffer();

			for (const [key, method] of this.methods) {
				method.Ser(data[key], buffer);
			}

			return buffer;
		};

		public SerSelected(data: T, selected: (keyof T)[], buffer?: BitBuffer) {
			buffer ||= BitBuffer();

			for (const [key, method] of this.methods) {
				if (key in selected) {
					method.Ser(data[key], buffer);
				}
			}

			return buffer;
		}
	}

	export type Method<T> = {
		Des: (buffer: BitBuffer) => T;
		Ser: (data: T, buffer: BitBuffer) => BitBuffer;
	};

	export const ToString = (): Method<string> => {
		return {
			Des: (buffer) => {
				return buffer.readString();
			},
			Ser: (data, buffer) => {
				buffer.writeString(data);
				return buffer;
			},
		};
	};

	export const ToUnsigned = (bits: number): Method<number> => {
		return {
			Des: (buffer) => {
				return buffer.readUnsigned(bits);
			},
			Ser: (data, buffer) => {
				buffer.writeUnsigned(bits, data);
				return buffer;
			},
		};
	};
	export const ToSigned = (bits: number): Method<number> => {
		return {
			Des: (buffer) => {
				return buffer.readSigned(bits);
			},
			Ser: (data, buffer) => {
				buffer.writeSigned(bits, data);
				return buffer;
			},
		};
	};

	export const ToColor3 = (): Method<Color3> => {
		return {
			Des: (buffer) => {
				return buffer.readColor3();
			},
			Ser: (data, buffer) => {
				buffer.writeColor3(data);
				return buffer;
			},
		};
	};

	export const ToUnsignedVector2 = (xBits: number, yBits: number): Method<Vector2> => {
		return {
			Des: (buffer) => {
				return new Vector2(buffer.readUnsigned(xBits), buffer.readUnsigned(yBits));
			},
			Ser: (data, buffer) => {
				buffer.writeUnsigned(10, data.X);
				buffer.writeUnsigned(10, data.Y);
				return buffer;
			},
		};
	};

	export const ToVector2 = (): Method<Vector2> => {
		return {
			Des: (buffer) => {
				return buffer.readVector2();
			},
			Ser: (data, buffer) => {
				buffer.writeVector2(data);
				return buffer;
			},
		};
	};

	export const ToArray = <T>(method: Method<T>): Method<T[]> => {
		return {
			Des: (buffer) => {
				let arr = [];
				while (buffer.readBits(1)[0] === 1) {
					const value = method.Des(buffer);
					arr.push(value);
				}
				return arr;
			},
			Ser: (data, buffer) => {
				for (const value of data) {
					method.Ser(value, buffer);
				}
				return buffer;
			},
		};
	};

	export const ToDict = <K, V>(keyMethod: Method<K>, valueMethod: Method<V>): Method<Map<K, V>> => {
		return {
			Des: (buffer) => {
				const dict = new Map<K, V>();
				while (buffer.readBits(1)[0] === 1) {
					const key = keyMethod.Des(buffer);
					const value = valueMethod.Des(buffer);
					dict.set(key, value);
				}
				return dict;
			},
			Ser: (data, buffer) => {
				for (const [key, value] of data) {
					keyMethod.Ser(key, buffer);
					valueMethod.Ser(value, buffer);
				}
				return buffer;
			},
		};
	};

	export const ToEmpty = (): Method<BitBuffer> => {
		return {
			Des: (buffer) => {
				return buffer;
			},
			Ser: (data, buffer) => {
				return buffer;
			},
		};
	};
}
