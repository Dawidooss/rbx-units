import UnitsAction from "./UnitsAction";
import LineFormation from "./Formations/LineFormation";
import SquareFormation from "./Formations/SquareFormation";
import CircleFormation from "./Formations/CircleFormation";
import Selection from "./Selection";
import HUD from "./HUD";

export default abstract class HUDHandler {
	public static hud: HUD;

	public static Init() {
		HUDHandler.hud = HUD.Get();

		HUDHandler.hud.gui.Formations.Line.MouseButton1Click.Connect(() =>
			UnitsAction.SetFormation(new LineFormation()),
		);
		HUDHandler.hud.gui.Formations.Square.MouseButton1Click.Connect(() =>
			UnitsAction.SetFormation(new SquareFormation()),
		);
		HUDHandler.hud.gui.Formations.Circle.MouseButton1Click.Connect(() =>
			UnitsAction.SetFormation(new CircleFormation()),
		);
	}
}
