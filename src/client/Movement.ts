import { ContextActionService, Players, TweenService, UserInputService, Workspace } from "@rbxts/services";
import { camera } from "./Instances";

export default class Movement {
	public shift = false;
	public moveSpeed = 25;
	public zoom = 2;
	public position = new Vector2();
	public moveDirection = new Vector2();
	public dragging = false;

	private zoomCFrame = new Instance("CFrameValue");

	private static instance: Movement;
	constructor() {
		Movement.instance = this;

		ContextActionService.BindActionAtPriority(
			"Movement",
			this.HandleInput,
			false,
			100,
			Enum.KeyCode.A,
			Enum.KeyCode.D,
			Enum.KeyCode.W,
			Enum.KeyCode.S,
			Enum.KeyCode.F,
			Enum.KeyCode.LeftShift,
			Enum.UserInputType.MouseWheel,
		);
	}

	private HandleInput = (action: string, state: Enum.UserInputState, input: InputObject) => {
		const begin = state === Enum.UserInputState.Begin;
		if (action === "Movement") {
			if (input.UserInputType === Enum.UserInputType.MouseWheel) {
				this.zoom = math.clamp(this.zoom - input.Position.Z, 1, 5);
				TweenService.Create(this.zoomCFrame, new TweenInfo(0.2, Enum.EasingStyle.Sine), {
					Value: new CFrame(0, this.zoom * 25, 0).mul(CFrame.Angles(math.rad((5 - this.zoom) * 5), 0, 0)),
				}).Play();
			} else if (input.UserInputType === Enum.UserInputType.Keyboard) {
				if (input.KeyCode === Enum.KeyCode.D) {
					this.moveDirection = new Vector2(begin ? 1 : 0, this.moveDirection.Y);
				} else if (input.KeyCode === Enum.KeyCode.A) {
					this.moveDirection = new Vector2(begin ? -1 : 0, this.moveDirection.Y);
				} else if (input.KeyCode === Enum.KeyCode.S) {
					this.moveDirection = new Vector2(this.moveDirection.X, begin ? 1 : 0);
				} else if (input.KeyCode === Enum.KeyCode.W) {
					this.moveDirection = new Vector2(this.moveDirection.X, begin ? -1 : 0);
				} else if (input.KeyCode === Enum.KeyCode.LeftShift) {
					this.shift = begin;
				}
			}
		}
	};

	public Update(deltaTime: number) {
		const mouseDelta = UserInputService.GetMouseDelta();

		if (this.dragging) {
			this.position = this.position.add(mouseDelta.mul((deltaTime * this.moveSpeed * this.zoom) / 4));
		} else {
			this.position = this.position.add(
				this.moveDirection.mul(deltaTime * this.moveSpeed * (this.shift ? 2.5 : 1) * (this.zoom / 2 + 0.5)),
			);
		}
		camera.CameraType = Enum.CameraType.Scriptable;
		camera.CFrame = new CFrame(this.position.X, 0, this.position.Y)
			.mul(this.zoomCFrame.Value)
			.mul(CFrame.Angles(-math.pi / 2, 0, 0));
	}

	public static Get() {
		return Movement.instance || new Movement();
	}
}
