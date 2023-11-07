-- Compiled with roblox-ts v2.1.1
local SelectionType
local Selectable
do
	Selectable = {}
	function Selectable:constructor()
		self.selectionType = SelectionType.None
	end
end
do
	local _inverse = {}
	SelectionType = setmetatable({}, {
		__index = _inverse,
	})
	SelectionType.Selected = 0
	_inverse[0] = "Selected"
	SelectionType.Hovering = 1
	_inverse[1] = "Hovering"
	SelectionType.None = 2
	_inverse[2] = "None"
end
return {
	default = Selectable,
	SelectionType = SelectionType,
}
