import Unit from "./Unit";

export enum Formation {
	Normal,
	Line,
	Group,
}

export default abstract class UnitsGroup {
	public static Move(
		units: Array<Unit>,
		position: Vector3,
		formation: Formation,
		direction?: number,
		spread?: number,
	) {
		const groupSize = units.size();

		const cframe = new CFrame(position).mul(CFrame.Angles(0, direction || 0, 0));

		units.forEach((unit, index) => {
			const offset = new CFrame((-1 ^ index) * math.ceil(index / 2) * (spread || 5), 0, 0);
			const targetPosition = cframe.mul(offset);

			unit.Move(targetPosition);
		});
	}
}
