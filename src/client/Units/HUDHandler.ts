import UnitsAction from "./UnitsAction";
import LineFormation from "./Formations/LineFormation";
import SquareFormation from "./Formations/SquareFormation";
import CircleFormation from "./Formations/CircleFormation";
import HUD from "./HUD";
import UnitsGroup from "./UnitsGroup";
import Selection from "./Selection";

export default abstract class HUDHandler {
	public static Init() {
		HUD.gui.Formations.Line.MouseButton1Click.Connect(() => UnitsAction.SetFormation(new LineFormation()));
		HUD.gui.Formations.Square.MouseButton1Click.Connect(() => UnitsAction.SetFormation(new SquareFormation()));
		HUD.gui.Formations.Circle.MouseButton1Click.Connect(() => UnitsAction.SetFormation(new CircleFormation()));

		HUD.gui.FormGroup.MouseButton1Click.Connect(() => {
			const group = UnitsGroup.FormGroup(Selection.selectedUnits);
			Selection.ClearSelectedUnits();

			if (!group) return;

			const groupSet = new Set<UnitsGroup>();
			groupSet.add(group);

			Selection.SelectUnits(groupSet);
		});
	}
}
