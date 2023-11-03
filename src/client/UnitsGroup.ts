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
		let loopCount = 0;
		const positions = UnitsGroup.GetPositionsInFormation(units.size(), position, formation, direction, spread);
		let distancesArray = new Array<[Unit, number, Vector3]>();

		units.forEach((unit, index) => {
			loopCount += 1;
			positions.forEach((position) => {
				loopCount += 1;
				const distance = unit.model.GetPivot().Position.sub(position).Magnitude;
				distancesArray.push([unit, distance, position]);
			});
		});

		distancesArray.sort((a, b) => {
			return a[1] < b[1];
		});

		while (distancesArray.size() > 0) {
			loopCount += 1;
			const closest = distancesArray[0];
			closest[0].Move(closest[2]);

			const newDistancesArray = new Array<[Unit, number, Vector3]>();
			distancesArray.forEach((v) => {
				loopCount += 1;
				if (v[0] !== closest[0] && v[2] !== closest[2]) {
					newDistancesArray.push(v);
				}
			});
			distancesArray = newDistancesArray;
		}
	}

	public static GetPositionsInFormation(
		size: number,
		position: Vector3,
		formatiion: Formation,
		direction?: number,
		spread?: number,
	): Array<Vector3> {
		const positions = new Array<Vector3>();

		const cframe = new CFrame(position).mul(CFrame.Angles(0, direction || 0, 0));

		for (let i = 0; i < size; i++) {
			const offset = new CFrame(math.pow(-1, i) * math.ceil(i / 2) * (spread || 5), 0, 0);
			const targetPosition = cframe.mul(offset);

			positions.push(targetPosition.Position);
		}
		return positions;
	}
}
