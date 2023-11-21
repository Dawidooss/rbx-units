export default abstract class Store {
	public name: string = "Store";

	abstract OverrideData(data: any): void;
}
