-- Compiled with roblox-ts v2.2.0
local TS = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local _services = TS.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "services")
local HttpService = _services.HttpService
local Players = _services.Players
local RunService = _services.RunService
local MovementVisualisation = TS.import(script, script.Parent, "MovementVisualisation").default
local SelectionType = TS.import(script, game:GetService("ReplicatedStorage"), "Shared", "types").SelectionType
local BitBuffer = TS.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "bitbuffer", "src", "roblox")
local ClientReplicator = TS.import(script, script.Parent.Parent, "DataStore", "ClientReplicator").default
local replicator = ClientReplicator:Get()
local UnitMovement
do
	UnitMovement = setmetatable({}, {
		__tostring = function()
			return "UnitMovement"
		end,
	})
	UnitMovement.__index = UnitMovement
	function UnitMovement.new(...)
		local self = setmetatable({}, UnitMovement)
		return self:constructor(...) or self
	end
	function UnitMovement:constructor(unit)
		self.moving = false
		self.path = {}
		self.moveToTries = 0
		self.unit = unit
		self.visualisation = MovementVisualisation.new(self)
	end
	function UnitMovement:Stop()
		self.pathId = nil
		self.visualisation:Enable(false)
		local _result = self.loopConnection
		if _result ~= nil then
			_result:Disconnect()
		end
		self.moveToTries = 0
		self.movingTo = nil
		self.path = {}
		self.moving = false
	end
	UnitMovement.Move = TS.async(function(self, path, replicate)
		local pathId = HttpService:GenerateGUID(false)
		self.pathId = pathId
		self.path = path
		self.moving = true
		while self.moving and (self.pathId == pathId and #self.path > 0) do
			local success = TS.await(self:MoveTo(self.path[1]))
			if not success then
				break
			end
			table.remove(self.path, 1)
		end
		self:Stop()
	end)
	UnitMovement.MoveTo = TS.async(function(self, position)
		self.moving = true
		self.movingTo = position
		self.visualisation:Enable(self.unit.selectionType == SelectionType.Selected)
		local promise = TS.Promise.new(TS.async(function(resolve, reject)
			-- orientation to position
			local orientation = { CFrame.new(self.unit.model:GetPivot().Position, position):ToOrientation() }
			self.unit.alignOrientation.CFrame = CFrame.Angles(0, orientation[2], 0)
			self.unit.data.targetPosition = position
			self.unit.data.movementStartTick = tick()
			local success = TS.await(self:TryMoveTo(position))
			resolve(success)
			-- replicate to server if player is owner of this unit
			-- if (this.unit.data.playerId === Players.LocalPlayer.UserId) {
			-- 	const buffer = BitBuffer();
			-- 	buffer.writeString(this.unit.data.id);
			-- 	buffer.writeVector3(waypoint.Position);
			-- 	buffer.writeFloat32(tick());
			-- 	const response = replicator.Replicate("move-unit", buffer.dumpString())[0] as ServerResponse;
			-- 	if (response.error) {
			-- 		this.unit.model.PivotTo(currentPosition);
			-- 		this.Stop(false);
			-- 	}
			-- }
		end))
		return promise
	end)
	UnitMovement.TryMoveTo = TS.async(function(self, position)
		self.moveToTries += 1
		local promise = TS.Promise.new(function(resolve, reject)
			if self.moveToTries > 10 then
				warn("UNIT MOVE TO: " .. (self.unit.data.id .. " couldn't get to targetPosition due to exceed moveToTries limit"))
				resolve(true)
				return nil
			end
			self:Replicate()
			self.unit.model.Humanoid:MoveTo(position)
			local _result = self.loopConnection
			if _result ~= nil then
				_result:Disconnect()
			end
			local conn
			conn = RunService.Heartbeat:Connect(TS.async(function()
				local unitPosition = self.unit:GetPosition()
				local groundedPosition = Vector3.new(position.X, unitPosition.Y, position.Z)
				local distance = (groundedPosition - unitPosition).Magnitude
				if distance <= 2 then
					conn:Disconnect()
					resolve(true)
				elseif self.unit.model.Humanoid:GetState() ~= Enum.HumanoidStateType.Running then
					conn:Disconnect()
					local success = TS.await(self:TryMoveTo(position))
					resolve(success)
				end
			end))
			self.loopConnection = conn
			self.unit.maid:GiveTask(conn)
		end)
		return promise
	end)
	function UnitMovement:Replicate()
		if self.unit.data.playerId == Players.LocalPlayer.UserId then
			local buffer = BitBuffer()
			buffer.writeString(self.unit.data.id)
			buffer.writeVector3(self.unit:GetPosition())
			buffer.writeFloat32(tick())
			for _, position in self.path do
				buffer.writeVector3(position)
			end
			local response = replicator:Replicate("unit-movement", buffer.dumpString())[1]
			if response.error then
				-- this.unit.model.PivotTo(currentPosition);
				-- this.Stop(false);
				print("didnt work")
			end
		end
	end
end
return {
	default = UnitMovement,
}
