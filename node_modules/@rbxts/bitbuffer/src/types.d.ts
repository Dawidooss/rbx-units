interface BitBuffer {
	/* Abstract functions */

	/** Writes an arbitrary number of bits to the BitBuffer. The arguments **MUST** all be 0 or 1. */
	writeBits: (...args: (0 | 1)[]) => void;

	/** Writes a byte to the BitBuffer. */
	writeByte: (n: number) => void;

	/** Writes an arbitrary width unsigned integer to the BitBuffer.The width **MUST** be in the range [1, 64] */
	writeUnsigned: (width: number, n: number) => void;

	/** Writes an arbitrary width signed integer to the BitBuffer. The width **MUST** be in the range [2, 63] */
	writeSigned: (width: number, n: number) => void;

	/**
	 * Writes a floating point number with an arbitrarily long exponent and an arbitrarily long mantissa to the BitBuffer. Both `expWidth` and `mantWidth` **MUST** be in the range [1, 64].
	 * @param expWidth the length of the exponent
	 * @param mantWidth the length of the mantissa
	 */
	writeFloat: (expWidth: number, mantWidth: number, n: number) => void;

	/* Read functions */

	/** Reads `n` bits from the BitBuffer and returns them in an array of 1s and 0s. */
	readBits: (n: number) => (0 | 1)[];

	/** Reads a byte from the BitBuffer and returns it. */
	readByte: () => number;

	/** Reads an arbitrary width unsigned integer from the BitBuffer and returns it. The width **MUST** be in the range [1, 64]. */
	readUnsigned: (width: number) => number;

	/** Reads an arbitrary width signed integer from the BitBuffer and returns it. The width **MUST** be in the range [2, 63] */
	readSigned: (width: number) => number;

	/**
	 * Reads a floating point number with an arbitrarily long exponent and an arbitrarily long mantissa from the BitBuffer and returns it. Both `expWidth` and `mantWidth` **MUST** be in the range [1, 64].
	 * @param expWidth the length of the exponent
	 * @param mantWidth the length of the mantissa
	 */
	readFloat: (expWidth: number, mantWidth: number) => number;

	/* Main functions */

	/** Returns where the pointer is in the stream. The pointer is the bit from which the various [Read functions](https://dekkonot.github.io/bitbuffer/api-main/#read-functions) operate. */
	getPointer: () => number;

	/** Sets where the pointer is in the stream in bits. */
	setPointer: (n: number) => void;

	/** Sets the pointer in bits from the end of the stream. Equivalent to `setPointer(getBitLength()-n)`. */
	setPointerFromEnd: (n: number) => void;

	/** Returns the byte the pointer is at in the stream. */
	getPointerByte: () => number;

	/** Sets where the pointer is in the stream in bytes. */
	setPointerByte: (n: number) => void;

	/** Sets the pointer in bytes from the end of the stream. Equivalent to `setPointerByte(getLength()-n)`. */
	setPointerByteFromEnd: (n: number) => void;

	/** Returns the length of the internal buffer in bits. */
	getLength: () => number;

	/** Returns the length of the internal buffer in bytes. */
	getByteLength: () => number;

	/** Returns whether or not the buffer has data left in it to read. */
	isFinished: () => boolean;

	/* Export functions */

	/** Returns a string of binary digits that represents the content of the BitBuffer. This is primarily intended for debugging or testing purposes. */
	dumpBinary: () => string;

	/** Returns the raw binary content of the BitBuffer. This is one of the main methods for getting things out of the buffer, and outputs the raw binary data. */
	dumpString: () => string;

	/**
	 * Returns the base64 encoded content of the BitBuffer. This doesn't add linebreaks to the data.
	 *
	 * To write base64 data to the BitBuffer, use `writeBase64`.
	 */
	dumpBase64: () => string;

	/** Returns a string of hex characters representing the contents of the BitBuffer. */
	dumpHex: () => string;

	/**
	 * Returns an iterator that can be used to get individual chunks and their position in the Buffer.
	 *
	 * ```ts
	 * const buffer = BitBuffer("foo|bar|baz");
	 * for (const [position, chunk] of buffer.exportChunk(4)) {
	 * 	print(position, chunk);
	 * }
	 * ```
	 *
	 * Would output:
	 * ```
	 * 1	foo|
	 * 5	bar|
	 * 9	baz
	 * ```
	 */
	exportChunk: (
		chunkLength: number
	) => IterableFunction<LuaTuple<[number, string]>>;

	/**
	 * Returns an iterator function that can be used to get individual chunks of the Buffer, encoded to Base64. The `chunkLength` argument is the size of the Base64 output, not the size of the chunk pre-encoding.
	 *
	 * ```ts
	 * const buffer = BitBuffer("foo|bar|baz");
	 * for (const chunk of buffer.exportBase64Chunk(4)) {
	 * 	print(chunk);
	 * }
	 * ```
	 *
	 * Would output:
	 * ```
	 * Zm9v
	 * fGJh
	 * cnxi
	 * YXo=
	 * ```
	 */
	exportBase64Chunk: (chunkLength: number) => IterableFunction<string>;

	/**
	 * Returns an iterator function that can be used to get individual chunks of the Buffer with their bytes in hex. The `chunkLength` argument is the size of the hex output, not the size of the chunk pre-encoding.
	 *
	 * ```ts
	 * const buffer = BitBuffer("foo|bar|baz");
	 * for (const chunk of buffer.exportHexChunk(8)) {
	 * 	print(chunk);
	 * }
	 * ```
	 *
	 * Would output:
	 * ```
	 * 666f6f7c
	 * 6261727c
	 * 62617a
	 * ```
	 */
	exportHexChunk: (chunkLength: number) => IterableFunction<string>;

	/** Returns the CRC-32 checksum of the BitBuffer's contents. */
	crc32: () => number;

	/* Write functions */

	/** Writes the unsigned 8-bit integer `n` to the BitBuffer. Directly calls `BitBuffer.writeByte`, but included for the sake of completion. */
	writeUInt8: (n: number) => void;

	/** Writes the unsigned 16-bit integer `n` to the BitBuffer. */
	writeUInt16: (n: number) => void;

	/** Writes the unsigned 32-bit integer `n` to the BitBuffer. */
	writeUInt32: (n: number) => void;

	/** Writes the signed 8-bit integer `n` to the BitBuffer. */
	writeInt8: (n: number) => void;

	/** Writes the signed 16-bit integer `n` to the BitBuffer. */
	writeInt16: (n: number) => void;

	/** Writes the signed 32-bit integer `n` to the BitBuffer. */
	writeInt32: (n: number) => void;

	/** Writes a [half-precision](https://en.wikipedia.org/wiki/Half-precision_floating-point_format) (16-bit) floating point number to the BitBuffer. */
	writeFloat16: (n: number) => void;

	/** Writes a [single-precision](https://en.wikipedia.org/wiki/Single-precision_floating-point_format) (32-bit) floating point number to the BitBuffer. */
	writeFloat32: (n: number) => void;

	/** Writes a [double-precision](https://en.wikipedia.org/wiki/Double-precision_floating-point_format) (64-bit) floating point number to the BitBuffer. In most installs of Lua (including Roblox), all Lua numbers are doubles, so this should be used if the precision of a number is important. */
	writeFloat64: (n: number) => void;

	/**
	 * Writes a sequence of base64 bytes to the BitBuffer, decoding them in the process. Padding is optional, and non-base64 characters will cause an error.
	 *
	 * To retrieve base64 output, use `dumpBase64`. */
	writeBase64: (input: string) => void;

	/** Writes a length-prefixed string to the BitBuffer. The length is written as a 24-bit unsigned integer before the bytes of the string. */
	writeString: (str: string) => void;

	/** Writes a null-terminated string to the BitBuffer. For efficiency's sake, this function doesn't check to see if `str` contains an embedded `\0` character, so plan accordingly. */
	writeTerminatedString: (str: string) => void;

	/** Writes a set-length string to the BitBuffer. No information is stored about the length of the string -- readSetLengthString requires the length of the written string to read. */
	writeSetLengthString: (str: string) => void;

	/**
	 * > **Warning: Potential Performance Issue**
	 *
	 * > Although this function allows for writing fields that aren't a multiple of 8 bits long, it can cause performance problems for subsequent writes because of the math involved. You should try to keep writeField calls to the end of the file or make sure they're multiples of 8.
	 *
	 * Writes a bitfield with a bit for every argument passed. If the argument is truthy, the bit is `1`. Otherwise, it's `false`. The max number of arguments able to be passed to this function is 53 (see [the section on limitations](https://dekkonot.github.io/bitbuffer/#limitations)).
	 */
	writeField(...args: unknown[]): void;

	/* Read functions */

	/** Reads an 8-bit unsigned integer from the BitBuffer and returns it. */
	readUInt8: () => number;

	/** Reads a 16-bit unsigned integer from the BitBuffer and returns it. */
	readUInt16: () => number;

	/** Reads a 32-bit unsigned integer from the BitBuffer and returns it. */
	readUInt32: () => number;

	/** Reads an 8-bit signed integer from the BitBuffer and returns it. */
	readInt8: () => number;

	/** Reads a 16-bit signed integer from the BitBuffer and returns it. */
	readInt16: () => number;

	/** Reads an 32-bit signed integer from the BitBuffer and returns it. */
	readInt32: () => number;

	/** Reads a [half-precision](https://en.wikipedia.org/wiki/Half-precision_floating-point_format) (16-bit) floating point number from the BitBuffer and returns it. */
	readFloat16: () => number;

	/** Reads a [single-precision](https://en.wikipedia.org/wiki/Single-precision_floating-point_format) (32-bit) floating point number from the BitBuffer and returns it. */
	readFloat32: () => number;

	/** Reads a [double-precision](https://en.wikipedia.org/wiki/Double-precision_floating-point_format) (64-bit) floating point number from the BitBuffer and returns it. */
	readFloat64: () => number;

	/** Reads a length-prefixed string from the BitBuffer and returns it. */
	readString: () => string;

	/** Reads a null-terminated string from the BitBuffer and returns it. */
	readTerminatedString: () => string;

	/** Reads a `length` byte string from the BitBuffer and returns it. */
	readSetLengthString: (length: number) => string;

	/**
	 * > **Warning: Potential Performance Issue**
	 *
	 * > Although this function allows for reading fields that aren't a multiple of 8 bits long, it can cause performance problems for subsequent reads because of the math involved. You should try to keep readField calls to the end of the file or make sure they're multiples of 8.
	 *
	 * Reads an `n` width bitfield from the BitBuffer and returns an array of bools that represent its bits.
	 */
	readField: (n: number) => boolean[];

	/* Roblox functions */

	/** Writes a BrickColor to the BitBuffer as a 16-bit unsigned integer. */
	writeBrickColor: (n: BrickColor) => void;

	/** Writes a Color3 to the BitBuffer as a 24-bit integer. Colors with RGB components outside of `[0, 255]` are not saved properly and may throw. */
	writeColor3: (n: Color3) => void;

	/** Writes a CFrame to the BitBuffer. If the CFrame is axis aligned (all of its faces are aligned with an axis), it takes up 13 bytes. Otherwise, it takes up 49. */
	writeCFrame: (n: CFrame) => void;

	/** Writes a Vector3 to the BitBuffer as three 32-bit floats. The written size is 12 bytes. */
	writeVector3: (n: Vector3) => void;

	/** Writes a Vector2 to the BitBuffer as two 32-bit floats. The written size is 8 bytes. */
	writeVector2: (n: Vector2) => void;

	/** Writes a UDim2 to the BitBuffer as two 32-bit floats and two signed 32-bit integers. The written size is 16 bytes. */
	writeUDim2: (u2: UDim2) => void;

	/** Writes a UDim to the BitBuffer as a 32-bit float and a 32-bit signed integer. The written size is 8 bytes. */
	writeUDim: (u: UDim) => void;

	/** Writes a Ray to the BitBuffer as two Vector3s representing the `Origin` and `Direction`. The written size is 24 bytes. */
	writeRay: (ray: Ray) => void;

	/** Writes a Rect to the BitBuffer as two Vector2s representing the `Min` and `Max`. The written size is 16 bytes. */
	writeRect: (rect: Rect) => void;

	/**
	 * Writes a Region3 to the BitBuffer as two Vector3s representing the `Min` and `Max`. The written size is 24 bytes.
	 *
	 * Region3s do not have properties indicating their minimums and maximums, so they are determined using arithmetic. As a result, the value stores is subject to floating point errors.
	 */
	writeRegion3: (region: Region3) => void;

	/** Writes any EnumItem to the BitBuffer as a null-terminated string and a 16-bit unsigned integer. Due to the nature of this datatype, the written size varies. The size in bytes can be determined with `#tostring(enum.EnumType) + 3`. */
	writeEnum: (e: Enum) => void;

	/** Writes a NumberRange to the BitBuffer as two 32-bit floats. The written size is 8 bytes. */
	writeNumberRange: (range: NumberRange) => void;

	/** Writes a NumberSequence to the BitBuffer as an array of NumberSequenceKeypoints. Due to the nature of the datatype, the written size varies. The size in bytes can be determined with `(#sequence.Keypoints*12)+4`. */
	writeNumberSequence: (sequence: NumberSequence) => void;

	/** Writes a ColorSequence to the BitBuffer as an array of ColorSequenceKeypoints. Due to the nature of the datatype, the written size varies. The size in bytes can be determined with `(#sequence.Keypoints*7)+4`. */
	writeColorSequence: (sequence: ColorSequence) => void;

	/* Read functions */

	/** Reads a BrickColor from the BitBuffer and returns it. */
	readBrickColor: () => BrickColor;

	/** Reads a Color3 from the BitBuffer and returns it. */
	readColor3: () => Color3;

	/** Reads a CFrame from the BitBuffer and returns it. */
	readCFrame: () => CFrame;

	/** Reads a Vector3 from the BitBuffer and returns it. */
	readVector3: () => Vector3;

	/** Reads a Vector2 from the BitBuffer and returns it. */
	readVector2: () => Vector2;

	/** Reads a UDim2 from the BitBuffer and returns it. */
	readUDim2: () => UDim2;

	/** Reads a UDim from the BitBuffer and returns it. */
	readUDim: () => UDim;

	/** Reads a Ray from the BitBuffer and returns it. */
	readRay: () => Ray;

	/** Reads a Rect from the BitBuffer and returns it. */
	readRect: () => Rect;

	/** Reads a Region3 from the BitBuffer and returns it. Note that because of limitations with the Roblox API, the Region3 will have lost precision over what was originally written. */
	readRegion3: () => Region3;

	/** Reads an EnumItem from the BitBuffer and returns it. */
	readEnum: <E extends Enum>() => E;

	/** Reads a NumberRange from the BitBuffer and returns it. */
	readNumberRange: () => NumberRange;

	/** Reads a NumberSequence from the BitBuffer and returns it. */
	readNumberSequence: () => NumberSequence;

	/** Reads a ColorSequence from the BitBuffer and returns it. */
	readColorSequence: () => ColorSequence;
}

/** Creates a new BitBuffer object and fills it with `stream` if it's provided. Otherwise, returns an empty BitBuffer. */
declare function BitBuffer(stream?: string): BitBuffer;

export = BitBuffer;
