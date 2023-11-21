export type TeamData = {
	name: string;
	id: string;
	color: Color3;
};

export type SerializedTeamData = {
	name: string;
	id: string;
	color: string;
};

export type ServerResponse = {
	status: string;
	data?: any;
} & (
	| {
			error: false;
	  }
	| {
			error: true;
			errorMessage: string;
	  }
);