type UnitModel = Model & {
	Humanoid: Humanoid;
	HumanoidRootPart: BasePart;
};

type SelectionCirle = BasePart & {
	Highlight: Highlight;
	Attachment: Attachment;
};

type ServerResponse = {
	status: string;
	data?: unknown;
	error: boolean;
	errorMessage?: string;
};

type ActionCircle = Model & {
	Positions: Model;
	Arrow: Model & {
		Length: BasePart & {
			Attachment: Attachment;
		};
		Left: BasePart;
		Right: BasePart;
	};
	Middle: BasePart & {
		Beam: Beam;
		Attachment: Attachment;
	};
};

interface ReplicatedFirst extends Instance {
	Units: Folder & {
		[unitName: string]: UnitModel;
	};
}

interface Workspace extends Instance {
	TerrainParts: Folder & {
		[name: string]: BasePart;
	};
}
