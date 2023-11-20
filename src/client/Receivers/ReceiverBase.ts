export default interface ReceiverBase {
	type: string;

	Destroy(): void;
	FetchAll(): void;
}
