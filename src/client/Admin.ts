import { Workspace } from "@rbxts/services";
import UnitsManager from "./Units/UnitsManager";
import Input from "./Input";
import Utils from "./Utils";

const camera = Workspace.CurrentCamera!;

export default abstract class Admin {
	public static Init() {
		Input.Bind(Enum.KeyCode.F, Enum.UserInputState.End, () => this.SpawnUnit());
	}

	private static SpawnUnit() {
		const mouseHitResult = Utils.GetMouseHit([UnitsManager.cache]);

		if (mouseHitResult?.Position) {
			UnitsManager.CreateUnit(UnitsManager.GenerateUnitId(), "Dummy", mouseHitResult.Position);
		}
	}
}
