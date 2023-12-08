import Replicator from "client/DataStore/Replicator";
import ReplicationQueue from "shared/ReplicationQueue";
import { Sedes } from "shared/Sedes";

const replicator = Replicator.Get();

const serializer = new Sedes.Serializer<{
	message: string;
	id: number;
	data: Map<number, Color3>;
}>([
	["message", Sedes.ToString()],
	["id", Sedes.ToUnsigned(10)],
	["data", Sedes.ToDict(Sedes.ToUnsigned(8), Sedes.ToColor3())],
]);

replicator.Connect("test", serializer, (data) => {});

const queue = new ReplicationQueue();
queue.Add("test", (buffer) => {
	return serializer.Ser(
		{
			message: "siema",
			id: 15,
			data: new Map<number, Color3>(),
		},
		buffer,
	);
});

const result = replicator.Replicate(queue);
