-- Phantasm Group (horizontal layout helper)
local Maid = require(script.Parent.Parent.Parent.Utils.Maid)

local Group = {}
Group.__index = Group

function Group.new(container, options, window)
	local self = setmetatable({}, Group)
	options = options or {}

	self.Maid = Maid.new()
	self.Window = window
	self.Options = options
	self.Elements = {}

	self.Frame = Instance.new("Frame")
	self.Frame.Name = "Group"
	self.Frame.BackgroundTransparency = 1
	self.Frame.Size = UDim2.new(1, 0, 0, 0)
	self.Frame.AutomaticSize = Enum.AutomaticSize.Y
	self.Frame.Parent = container
	self.Maid:GiveTask(self.Frame)

	local layout = Instance.new("UIListLayout")
	layout.FillDirection = Enum.FillDirection.Horizontal
	layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	layout.VerticalAlignment = Enum.VerticalAlignment.Top
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Padding = UDim.new(0, tonumber(options.Gap) or 10)
	layout.Parent = self.Frame
	self.Layout = layout
	self.Maid:GiveTask(layout)

	return self
end

function Group:_register(element)
	if self.Window and type(self.Window._registerElement) == "function" then
		return self.Window:_registerElement(element)
	end
	return element
end

function Group:_reflow()
	local stretch = {}
	for _, element in ipairs(self.Elements) do
		if element and element.Frame and element.Frame:IsA("GuiObject") then
			table.insert(stretch, element)
		end
	end
	local count = #stretch
	if count == 0 then
		return
	end

	local gap = tonumber(self.Layout.Padding.Offset) or 0
	local totalGap = gap * (count - 1)
	local totalOffset = -totalGap
	local baseOffset = math.floor(totalOffset / count)
	local remainder = totalOffset - (baseOffset * count)

	for i, element in ipairs(stretch) do
		local extra = (i <= math.abs(remainder)) and -1 or 0
		local sizeY = element.Frame.Size.Y
		element.Frame.Size = UDim2.new(1 / count, baseOffset + extra, sizeY.Scale, sizeY.Offset)
	end
end

function Group:AddButton(options)
	local element = self:_register(require(script.Parent.Button).new(self.Frame, options, self.Window))
	table.insert(self.Elements, element)
	self:_reflow()
	return element
end

function Group:AddToggle(options)
	local element = self:_register(require(script.Parent.Toggle).new(self.Frame, options, self.Window))
	table.insert(self.Elements, element)
	self:_reflow()
	return element
end

function Group:AddSlider(options)
	local element = self:_register(require(script.Parent.Slider).new(self.Frame, options, self.Window))
	table.insert(self.Elements, element)
	self:_reflow()
	return element
end

function Group:AddDropdown(options)
	local element = self:_register(require(script.Parent.Dropdown).new(self.Frame, options, self.Window))
	table.insert(self.Elements, element)
	self:_reflow()
	return element
end

function Group:AddInput(options)
	local element = self:_register(require(script.Parent.Input).new(self.Frame, options, self.Window))
	table.insert(self.Elements, element)
	self:_reflow()
	return element
end

function Group:AddKeybind(options)
	local element = self:_register(require(script.Parent.Keybind).new(self.Frame, options, self.Window))
	table.insert(self.Elements, element)
	self:_reflow()
	return element
end

function Group:AddColorPicker(options)
	local element = self:_register(require(script.Parent.ColorPicker).new(self.Frame, options, self.Window))
	table.insert(self.Elements, element)
	self:_reflow()
	return element
end

function Group:AddProgress(options)
	local element = self:_register(require(script.Parent.Progress).new(self.Frame, options, self.Window))
	table.insert(self.Elements, element)
	self:_reflow()
	return element
end

function Group:AddCode(options)
	local element = self:_register(require(script.Parent.Code).new(self.Frame, options, self.Window))
	table.insert(self.Elements, element)
	self:_reflow()
	return element
end

function Group:AddDivider(options)
	local element = self:_register(require(script.Parent.Divider).new(self.Frame, options, self.Window))
	table.insert(self.Elements, element)
	self:_reflow()
	return element
end

function Group:AddSpacer(options)
	local element = self:_register(require(script.Parent.Spacer).new(self.Frame, options, self.Window))
	table.insert(self.Elements, element)
	self:_reflow()
	return element
end

function Group:Destroy()
	self.Maid:DoCleaning()
end

return Group

