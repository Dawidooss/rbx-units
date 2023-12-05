type UnitModel = Model & {
	Humanoid: Humanoid;
	HumanoidRootPart: BasePart;
	Head: BasePart;
};

type SelectionCirle = BasePart & {
	Highlight: Highlight;
	Attachment: Attachment;
};

type UnitOverheadBillboard = BillboardGui & {
	HealthBar: Frame & {
		Bar: Frame;
	};
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
	UnitOverheadBillboard: UnitOverheadBillboard;
}

interface Workspace extends Instance {
	TerrainParts: Folder & {
		[name: string]: BasePart;
	};
}
