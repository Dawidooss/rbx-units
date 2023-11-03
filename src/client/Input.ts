import { ContextActionService, Players, PolicyService, UserInputService, Workspace } from "@rbxts/services";
import UnitsManager from "./UnitsManager";
import guiInset from "./GuiInset";
import Unit from "./Unit";
import SelectionBox from "./Selection";

const camera = Workspace.CurrentCamera!;
const player = Players.LocalPlayer;

export default abstract class Input {
	private static holdingButtons = new Map<Enum.KeyCode, boolean>();
	private static binds = new Map<KeyBinding, Callback>();

	public static Init() {
		UserInputService.InputBegan.Connect((input, processed) => {
			Input.HandleInput(input);
		});

		UserInputService.InputEnded.Connect((input, processed) => {
			Input.HandleInput(input);
		});
	}

	private static HandleInput = (input: InputObject) => {
		const holding = input.UserInputState === Enum.UserInputState.Begin;
		Input.holdingButtons.set(input.KeyCode, holding);

		Input.binds.forEach((callback, keyBinding) => {
			if (
				(input.KeyCode === keyBinding.button || input.UserInputType === keyBinding.button) &&
				input.UserInputState === keyBinding.state
			) {
				callback();
			}
		});
	};

	public static IsButtonHolding(button: Enum.KeyCode): boolean {
		return Input.holdingButtons.get(button) || false;
	}

	public static Bind(button: Enum.KeyCode | Enum.UserInputType, state: Enum.UserInputState, callback: Callback) {
		Input.binds.set(new KeyBinding(button, state), callback);
	}
}

export class KeyBinding {
	public button: Enum.KeyCode | Enum.UserInputType;
	public state: Enum.UserInputState;
	constructor(button: Enum.KeyCode | Enum.UserInputType, state: Enum.UserInputState) {
		this.button = button;
		this.state = state;
	}
}
