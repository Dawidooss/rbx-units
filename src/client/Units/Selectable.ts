export default abstract class Selectable {
	public selectionType = SelectionType.None;

	abstract Select(selectionType: SelectionType): void;
	abstract Move(cframe: CFrame): void;
	abstract GetPosition(): Vector3;
}

export enum SelectionType {
	Selected,
	Hovering,
	None,
}

export type SelectionCirle = BasePart & {
	Highlight: Highlight;
	Attachment: Attachment;
};
