type UnitModel = Model & {
	Humanoid: Humanoid;
	HumanoidRootPart: BasePart;
};

interface ReplicatedFirst extends Instance {
	Units: Folder & {
		[unitName: string]: UnitModel;
	};
}
