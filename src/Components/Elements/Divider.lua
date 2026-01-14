-- Phantasm Divider
local Creator = require(script.Parent.Parent.Parent.Creator)
local Maid = require(script.Parent.Parent.Parent.Utils.Maid)

local Divider = {}
Divider.__index = Divider

function Divider.new(container, options)
	local self = setmetatable({}, Divider)
	options = options or {}

	self.Maid = Maid.new()

	local thickness = tonumber(options.Thickness) or 1
	local paddingY = tonumber(options.Padding) or 8
	local inset = tonumber(options.Inset) or 2

	self.Frame = Instance.new("Frame")
	self.Frame.Name = "Divider"
	self.Frame.BackgroundTransparency = 1
	self.Frame.Size = UDim2.new(1, 0, 0, (paddingY * 2) + thickness)
	self.Frame.Parent = container
	self.Maid:GiveTask(self.Frame)

	self.Line = Creator.New("Frame", {
		Parent = self.Frame,
		Size = UDim2.new(1, -inset * 2, 0, thickness),
		Position = UDim2.new(0, inset, 0.5, -math.floor(thickness / 2)),
		BackgroundColor3 = "Outline",
		BackgroundTransparency = 0.7,
		BorderSizePixel = 0,
		ThemeTag = { BackgroundColor3 = "Outline" },
	})

	return self
end

function Divider:Destroy()
	self.Maid:DoCleaning()
end

return Divider

