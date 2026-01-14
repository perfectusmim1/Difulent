-- Phantasm Spacer
local Maid = require(script.Parent.Parent.Parent.Utils.Maid)

local Spacer = {}
Spacer.__index = Spacer

function Spacer.new(container, options)
	local self = setmetatable({}, Spacer)
	options = options or {}

	self.Maid = Maid.new()

	local height = tonumber(options.Size or options.Height) or 10

	self.Frame = Instance.new("Frame")
	self.Frame.Name = "Spacer"
	self.Frame.BackgroundTransparency = 1
	self.Frame.Size = UDim2.new(1, 0, 0, height)
	self.Frame.Parent = container
	self.Maid:GiveTask(self.Frame)

	return self
end

function Spacer:SetSize(height)
	height = tonumber(height) or 10
	self.Frame.Size = UDim2.new(1, 0, 0, height)
end

function Spacer:Destroy()
	self.Maid:DoCleaning()
end

return Spacer

