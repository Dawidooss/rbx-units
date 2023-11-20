import { Workspace } from "@rbxts/services";
import UnitsManager from "./Units/UnitsManager";
import Input from "./Input";
import Utils from "./Utils";
import Network from "shared/Network";
import Squash from "@rbxts/squash";

const camera = Workspace.CurrentCamera!;

export default abstract class Admin {
	public static Init() {
		Input.Bind(Enum.KeyCode.F, Enum.UserInputState.End, () => this.SpawnUnit());
	}

	private static SpawnUnit() {
		const mouseHitResult = Utils.GetMouseHit([UnitsManager.cache]);

		if (mouseHitResult?.Position) {
			const unitType = Squash.string.ser("Dummy");
			const position = Squash.Vector3.ser(mouseHitResult.Position);
			Network.FireServer("createUnit", unitType, position);
		}
	}
}
