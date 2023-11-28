-- Compiled with roblox-ts v2.1.1
local TS = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local _services = TS.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "services")
local HttpService = _services.HttpService
local RunService = _services.RunService
local MovementVisualisation = TS.import(script, script.Parent, "MovementVisualisation").default
local SelectionType = TS.import(script, game:GetService("ReplicatedStorage"), "Shared", "types").SelectionType
local ReplicationQueue = TS.import(script, game:GetService("ReplicatedStorage"), "Shared", "ReplicationQueue").default
local Replicator = TS.import(script, script.Parent.Parent, "DataStore", "Replicator").default
local replicator = Replicator:Get()
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
		self.unit.path = {}
		self.moving = false
	end
	function UnitMovement:MoveAlongPath(path, queue)
		local pathId = HttpService:GenerateGUID(false)
		self.pathId = pathId
		self.unit.path = path
		self.moving = true
		local queuePassed = not not queue
		local _condition = queue
		if not queue then
			_condition = ReplicationQueue.new()
		end
		queue = _condition
		local _result = queue
		if _result ~= nil then
			_result:Add("unit-movement", function(buffer)
				buffer.writeString(self.unit.id)
				buffer.writeVector3(self.unit:GetPosition())
				self.unit.unitsStore:SerializePath(self.unit.path, buffer)
			end)
		end
		if not queuePassed then
			replicator:Replicate(queue)
		end
		spawn(TS.async(function()
			while self.moving and (self.pathId == pathId and #self.unit.path > 0) do
				local success = TS.await(self:MoveTo(self.unit.path[1]))
				if not success then
					break
				end
				table.remove(self.unit.path, 1)
			end
			self:Stop()
		end))
	end
	UnitMovement.MoveTo = TS.async(function(self, position)
		self.moving = true
		self.movingTo = position
		self.moveToTries = 0
		self.visualisation:Enable(self.unit.selectionType == SelectionType.Selected)
		local promise = TS.Promise.new(TS.async(function(resolve, reject)
			-- orientation to position
			local orientation = { CFrame.new(self.unit.model:GetPivot().Position, position):ToOrientation() }
			self.unit.alignOrientation.CFrame = CFrame.Angles(0, orientation[2], 0)
			local success = TS.await(self:TryMoveTo(position))
			resolve(success)
		end))
		return promise
	end)
	UnitMovement.TryMoveTo = TS.async(function(self, position)
		self.moveToTries += 1
		local promise = TS.Promise.new(function(resolve, reject)
			if self.moveToTries > 10 then
				warn("UNIT MOVE TO: " .. (self.unit.id .. " couldn't get to targetPosition due to exceed moveToTries limit"))
				resolve(true)
				return nil
			end
			-- this.Replicate();
			local _result = self.loopConnection
			if _result ~= nil then
				_result:Disconnect()
			end
			local conn
			conn = RunService.Heartbeat:Connect(TS.async(function()
				local unitPosition = self.unit:GetPosition()
				local groundedPosition = Vector3.new(position.X, unitPosition.Y, position.Z)
				local distance = (groundedPosition - unitPosition).Magnitude
				self.unit.model.Humanoid:MoveTo(position)
				if distance <= 2 then
					conn:Disconnect()
					resolve(true)
				end
			end))
			self.loopConnection = conn
			self.unit.maid:GiveTask(conn)
		end)
		return promise
	end)
end
return {
	default = UnitMovement,
}
