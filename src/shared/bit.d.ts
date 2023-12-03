type bitType = 0 | 1;

interface bit {
	FromBits(bitArray: bitType[]): number;
	ToBits(num: number, bits: number): bitType[];
}

declare const bit: bit;

export = bit;
