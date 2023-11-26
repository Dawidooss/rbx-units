-- Compiled with roblox-ts v2.2.0
local TS = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local _services = TS.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "services")
local ReplicatedFirst = _services.ReplicatedFirst
local Workspace = _services.Workspace
local Utils = TS.import(script, game:GetService("ReplicatedStorage"), "Shared", "Utils").default
local camera = Workspace.CurrentCamera
local Formation
do
	Formation = {}
	function Formation:constructor(actionType)
		self.destroyed = false
		self.circle = ReplicatedFirst:WaitForChild(actionType):Clone()
		self.arrow = self.circle.Arrow
	end
	function Formation:MatchUnitsToCFrames(units, cframes, mainCFrame)
		local matchedUnitsToCFrames = {}
		local distancesArray = {}
		for unit in units do
			local pivotPosition = unit:GetPosition()
			for _, cframe in cframes do
				local _position = cframe.Position
				local distance = (pivotPosition - _position).Magnitude
				local _distancesArray = distancesArray
				local _arg0 = { unit, distance, cframe }
				table.insert(_distancesArray, _arg0)
			end
		end
		local _distancesArray = distancesArray
		local _arg0 = function(a, b)
			return a[2] < b[2]
		end
		table.sort(_distancesArray, _arg0)
		local visitedUnits = {}
		local visitedCFrames = {}
		for _, _binding in distancesArray do
			local unit = _binding[1]
			local cframe = _binding[3]
			if visitedUnits[unit] ~= nil or visitedCFrames[cframe] ~= nil then
				continue
			end
			matchedUnitsToCFrames[unit] = cframe
			visitedUnits[unit] = true
			visitedCFrames[cframe] = true
		end
		return matchedUnitsToCFrames
	end
	function Formation:VisualisePositions(units, cframe, spread)
		if self.destroyed then
			return nil
		end
		self.circle:PivotTo(cframe)
		self.circle.Parent = camera
		self.arrow.Parent = if spread < 2 then nil else self.circle
		local _cframe = cframe
		local _cFrame = CFrame.new(0, 0, -spread / 2)
		local arrowMiddle = (_cframe * _cFrame).Position
		self.arrow:PivotTo(CFrame.new(arrowMiddle, cframe.Position))
		self.arrow.Length.Size = Vector3.new(spread, self.arrow.Length.Size.Y, self.arrow.Length.Size.Z)
		self.arrow.Length.Attachment.CFrame = CFrame.new(spread / 2, 0, 0)
		self.arrow.Left:PivotTo(self.arrow.Length.Attachment.WorldCFrame)
		self.arrow.Right:PivotTo(self.arrow.Length.Attachment.WorldCFrame)
		-- visualise positions
		local mainCFrame = self.circle:GetPivot()
		local matchedCframes = self:GetCFramesInFormation(units, mainCFrame, spread)
		self.circle.Positions:ClearAllChildren()
		local _arg0 = function(cframe)
			local positionPart = self.circle.Middle:Clone()
			positionPart.Transparency = 0
			local _fn = Utils
			local _position = cframe.Position
			local _vector3 = Vector3.new(0, 100, 0)
			local groundPositionResult = _fn:RaycastBottom(_position + _vector3, { Workspace.TerrainParts }, Enum.RaycastFilterType.Include)
			if not groundPositionResult then
				return nil
			end
			local _fn_1 = positionPart
			local _exp = groundPositionResult.Position
			local _position_1 = groundPositionResult.Position
			local _normal = groundPositionResult.Normal
			local _cFrame_1 = CFrame.new(_exp, _position_1 + _normal)
			local _arg0_1 = CFrame.Angles(math.pi / 2, 0, 0)
			_fn_1:PivotTo(_cFrame_1 * _arg0_1)
			positionPart.Parent = self.circle.Positions
		end
		for _k, _v in matchedCframes do
			_arg0(_v, _k - 1, matchedCframes)
		end
	end
	function Formation:GetSpreadLimits(amountOfUnits)
		return { 4, 12 }
	end
	function Formation:Hide()
		self.circle.Parent = nil
	end
	function Formation:Destroy()
		self.destroyed = true
		self.circle:Destroy()
	end
end
return {
	default = Formation,
}
