import UnitsAction from "./UnitsAction";
import LineFormation from "./Formations/LineFormation";
import SquareFormation from "./Formations/SquareFormation";
import CircleFormation from "./Formations/CircleFormation";
import HUD from "./HUD";

export default abstract class HUDHandler {
	public static Init() {
		HUD.gui.Formations.Line.MouseButton1Click.Connect(() => UnitsAction.SetFormation(new LineFormation()));
		HUD.gui.Formations.Square.MouseButton1Click.Connect(() => UnitsAction.SetFormation(new SquareFormation()));
		HUD.gui.Formations.Circle.MouseButton1Click.Connect(() => UnitsAction.SetFormation(new CircleFormation()));
	}
}
