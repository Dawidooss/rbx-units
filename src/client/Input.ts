import { UserInputService } from "@rbxts/services";

export default class Input {
	private holdingButtons = new Map<Enum.KeyCode, boolean>();
	private binds = new Map<KeyBinding, Callback>();

	private static instance: Input;
	constructor() {
		Input.instance = this;

		UserInputService.InputBegan.Connect((input, processed) => {
			this.HandleInput(input);
		});

		UserInputService.InputEnded.Connect((input, processed) => {
			this.HandleInput(input);
		});
	}

	private HandleInput = (input: InputObject) => {
		const holding = input.UserInputState === Enum.UserInputState.Begin;
		this.holdingButtons.set(input.KeyCode, holding);

		this.binds.forEach((callback, keyBinding) => {
			if (
				(input.KeyCode === keyBinding.button || input.UserInputType === keyBinding.button) &&
				input.UserInputState === keyBinding.state
			) {
				callback();
			}
		});
	};

	public IsButtonHolding(button: Enum.KeyCode): boolean {
		return this.holdingButtons.get(button) || false;
	}

	public Bind(button: Enum.KeyCode | Enum.UserInputType, state: Enum.UserInputState, callback: Callback) {
		this.binds.set(new KeyBinding(button, state), callback);
	}

	public static Get() {
		return Input.instance || new Input();
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
