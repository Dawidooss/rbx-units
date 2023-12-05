import BitBuffer from "@rbxts/bitbuffer";
import { Des } from "@rbxts/squash";

export namespace Deserialisation {
	export type Method<T> = (buffer: BitBuffer) => T;

	export const toString: Method<string> = (buffer: BitBuffer) => {
		return buffer.readString();
	};
}

export default class QueueDeserializer {
	private methods: { [key: string]: Deserialisation.Method<any> }[];
	private callback: (data: Map<string, any>) => void;
	constructor(methods: QueueDeserializer["methods"], callback: QueueDeserializer["callback"]) {
		this.methods = methods;
		this.callback = callback;
	}

	public Deserialize(buffer: BitBuffer) {}
}

new QueueDeserializer([{ key: Deserialisation.toString }], (buffer) => {});
