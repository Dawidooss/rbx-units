import UnitsAction from "./UnitsAction";
import LineFormation from "./Formations/LineFormation";
import SquareFormation from "./Formations/SquareFormation";
import CircleFormation from "./Formations/CircleFormation";
import GUI from "./GUI";

const gui = GUI.Get();
const unitsAction = UnitsAction.Get();

export default class HUDHandler {
	private static instance: HUDHandler;
	constructor() {
		HUDHandler.instance = this;
		gui.hud.Formations.Line.MouseButton1Click.Connect(() => unitsAction.SetFormation(new LineFormation()));
		gui.hud.Formations.Square.MouseButton1Click.Connect(() => unitsAction.SetFormation(new SquareFormation()));
		gui.hud.Formations.Circle.MouseButton1Click.Connect(() => unitsAction.SetFormation(new CircleFormation()));
	}

	public static Get() {
		return HUDHandler.instance || new HUDHandler();
	}
}
