import { RunService, Workspace } from "@rbxts/services";
import Utils from "../../shared/Utils";
import Formation from "./Formations/Formation";
import LineFormation from "./Formations/LineFormation";
import Unit from "./Unit";
import ReplicationQueue from "shared/ReplicationQueue";
import Input from "client/Input";
import Selection from "./Selection";
import ClientReplicator from "client/DataStore/Replicator";

const input = Input.Get();
const selection = Selection.Get();
const replicator = ClientReplicator.Get();

export default class UnitsAction {
	public enabled = false;

	private units = new Set<Unit>();
	private formationSelected = new LineFormation();
	private spreadLimits: [number, number] = [0, 0];
	private cframe = new CFrame();
	private startPosition = new Vector3();
	private spread = 0;

	private static instance: UnitsAction;
	constructor() {
		UnitsAction.instance = this;

		let endCallback: Callback | undefined;
		input.Bind(Enum.UserInputType.MouseButton2, Enum.UserInputState.Begin, () => {
			const units = selection.selectedUnits;

			if (units.size() === 0) return;

			endCallback = this.GetActionCFrame(units, (cframe: CFrame, spread: number) => {
				this.MoveUnits(units, cframe, spread);
				this.formationSelected.Hide();
			});
		});

		input.Bind(Enum.UserInputType.MouseButton2, Enum.UserInputState.End, () => {
			endCallback?.();
		});
	}

	public SetFormation(formation: Formation) {
		const oldFormation = this.formationSelected;
		this.formationSelected = formation;

		oldFormation.Destroy();
	}

	public GetActionCFrame(units: Set<Unit>, resultCallback: (cframe: CFrame, spread: number) => void): Callback {
		this.units = units;
		this.spreadLimits = this.formationSelected.GetSpreadLimits(units.size());
		this.Enable(true);

		const endCallback = () => {
			resultCallback(this.cframe, this.spread);
			this.Enable(false);
		};

		return endCallback;
	}

	private Enable(state: boolean) {
		if (this.units.size() === 0) return;
		if (this.enabled === state) return;

		if (state) {
			const mouseHitResult = Utils.GetMouseHit(
				[Workspace.TerrainParts, Workspace.Terrain],
				Enum.RaycastFilterType.Include,
			);
			if (!mouseHitResult) return;
			this.startPosition = mouseHitResult.Position;
			RunService.BindToRenderStep("UnitsAction", Enum.RenderPriority.Last.Value, () => this.Update());
		} else {
			RunService.UnbindFromRenderStep("UnitsAction");
		}

		this.enabled = state;
	}

	private Update() {
		const mouseHitResult = Utils.GetMouseHit(
			[Workspace.TerrainParts, Workspace.Terrain],
			Enum.RaycastFilterType.Include,
		);
		if (!mouseHitResult) return;

		const groundedMousePosition = new Vector3(
			mouseHitResult.Position.X,
			this.startPosition.Y,
			mouseHitResult.Position.Z,
		);

		const arrowLength = groundedMousePosition.sub(this.startPosition).Magnitude;
		const spread = math.clamp(arrowLength, this.spreadLimits[0], this.spreadLimits[1]);

		this.spread = spread;
		if (this.startPosition === mouseHitResult.Position) {
			let medianPosition = new Vector3();
			this.units.forEach((unit) => {
				medianPosition = medianPosition.add(unit.GetPosition());
			});
			medianPosition = medianPosition.div(this.units.size());

			const groundedMedianPosition = new Vector3(medianPosition.X, this.startPosition.Y, medianPosition.Z);
			this.cframe = new CFrame(this.startPosition, groundedMedianPosition).mul(CFrame.Angles(0, math.pi, 0));
		} else {
			this.cframe = new CFrame(this.startPosition, groundedMousePosition);
		}

		this.formationSelected.VisualisePositions(this.units, this.cframe, spread);
	}

	public async MoveUnits(units: Set<Unit>, cframe: CFrame, spread: number) {
		const cframes = this.formationSelected.GetCFramesInFormation(units, cframe, spread);
		const unitsAndCFrames = this.formationSelected.MatchUnitsToCFrames(units, cframes, cframe);

		const queue = new ReplicationQueue();

		let promises: Promise<[Unit, Vector3[]]>[] = [];
		unitsAndCFrames.forEach((targetCFrame, unit) => {
			const promise = unit.pathfinding.ComputePath(targetCFrame.Position);
			promises.push(promise);
		});

		const computedPaths = await Promise.all<Promise<[Unit, Vector3[]]>[]>(promises); // wait till all paths calculate

		for (const [unit, path] of computedPaths) {
			unit.movement.MoveAlongPath(path, queue);
		}

		replicator.Replicate(queue);
	}

	public static Get() {
		return UnitsAction.instance || new UnitsAction();
	}
}
