import { ContextActionService, Players, TweenService, UserInputService, Workspace } from "@rbxts/services";

const player = Players.LocalPlayer;
const camera = Workspace.CurrentCamera!;

export default class Movement {
	public static shift = false;
	public static moveSpeed = 25;
	public static zoom = 2;
	public static position = new Vector2();
	public static moveDirection = new Vector2();
	public static dragging = false;

	private static zoomValue = new Instance("NumberValue");

	public static Init() {
		Movement.zoomValue.Value = 1;

		ContextActionService.BindActionAtPriority(
			"movement",
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
			Enum.UserInputType.MouseButton2,
		);
	}

	private static HandleInput = (action: string, state: Enum.UserInputState, input: InputObject) => {
		const begin = state === Enum.UserInputState.Begin;
		if (action === "movement") {
			if (input.UserInputType === Enum.UserInputType.MouseWheel) {
				Movement.zoom = math.clamp(Movement.zoom - input.Position.Z, 1, 5);
				TweenService.Create(Movement.zoomValue, new TweenInfo(0.2, Enum.EasingStyle.Sine), {
					Value: Movement.zoom,
				}).Play();
			} else if (input.UserInputType === Enum.UserInputType.MouseButton2) {
				Movement.dragging = begin;
				UserInputService.MouseBehavior = begin
					? Enum.MouseBehavior.LockCurrentPosition
					: Enum.MouseBehavior.Default;
			} else if (input.UserInputType === Enum.UserInputType.Keyboard) {
				if (input.KeyCode === Enum.KeyCode.D) {
					Movement.moveDirection = new Vector2(begin ? 1 : 0, Movement.moveDirection.Y);
				} else if (input.KeyCode === Enum.KeyCode.A) {
					Movement.moveDirection = new Vector2(begin ? -1 : 0, Movement.moveDirection.Y);
				} else if (input.KeyCode === Enum.KeyCode.S) {
					Movement.moveDirection = new Vector2(Movement.moveDirection.X, begin ? 1 : 0);
				} else if (input.KeyCode === Enum.KeyCode.W) {
					Movement.moveDirection = new Vector2(Movement.moveDirection.X, begin ? -1 : 0);
				} else if (input.KeyCode === Enum.KeyCode.LeftShift) {
					Movement.shift = begin;
				}
			}
		}
	};

	public static Update(deltaTime: number) {
		const mouseDelta = UserInputService.GetMouseDelta();

		if (Movement.dragging) {
			Movement.position = Movement.position.add(
				mouseDelta.mul((deltaTime * Movement.moveSpeed * Movement.zoom) / 4),
			);
		} else {
			Movement.position = Movement.position.add(
				Movement.moveDirection.mul(
					deltaTime * Movement.moveSpeed * (Movement.shift ? 2.5 : 1) * (Movement.zoom / 2 + 0.5),
				),
			);
		}
		camera.CameraType = Enum.CameraType.Scriptable;
		camera.CFrame = new CFrame(Movement.position.X, Movement.zoomValue.Value * 25, Movement.position.Y).mul(
			CFrame.Angles(-math.pi / 2, 0, 0),
		);
	}
}
