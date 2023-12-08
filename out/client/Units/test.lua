-- Compiled with roblox-ts v2.1.1
local TS = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local Replicator = TS.import(script, script.Parent.Parent, "DataStore", "Replicator").default
local ReplicationQueue = TS.import(script, game:GetService("ReplicatedStorage"), "Shared", "ReplicationQueue").default
local Sedes = TS.import(script, game:GetService("ReplicatedStorage"), "Shared", "Sedes").Sedes
local replicator = Replicator:Get()
local serializer = Sedes.Serializer.new({ { "message", Sedes.ToString() }, { "id", Sedes.ToUnsigned(10) }, { "data", Sedes.ToDict(Sedes.ToUnsigned(8), Sedes.ToColor3()) } })
replicator:Connect("test", serializer, function(data) end)
local queue = ReplicationQueue.new()
queue:Add("test", function(buffer)
	return serializer.Ser({
		message = "siema",
		id = 15,
		data = {},
	}, buffer)
end)
local result = replicator:Replicate(queue)
return nil
