-- Phantasm Section (UI-first remake)
local Creator = require(script.Parent.Parent.Parent.Creator)
local Utility = require(script.Parent.Parent.Parent.Utils.Utility)
local Maid = require(script.Parent.Parent.Parent.Utils.Maid)

local Section = {}
Section.__index = Section

function Section.new(parentContainer, options, window)
	local self = setmetatable({}, Section)

	options = options or {}
	self.Maid = Maid.new()
	self.Window = window
	self.Options = options
	self.Title = options.Title or "Section"
	self.Collapsible = options.Collapsible ~= false
	self.Opened = options.Opened ~= false

	self.Frame = Creator.New("Frame", {
		Parent = parentContainer,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundColor3 = "Surface",
		BackgroundTransparency = 0.08,
		BorderSizePixel = 0,
		ThemeTag = { BackgroundColor3 = "Surface" },
	})
	Creator.AddCorner(self.Frame, 14)
	Creator.AddStroke(self.Frame, { Color = "Outline", Thickness = 1, Transparency = 0.8, ThemeTag = { Color = "Outline" } })
	Creator.AddPadding(self.Frame, 12)
	Utility.AddGradient(self.Frame, "Surface2", "Surface", NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.05),
		NumberSequenceKeypoint.new(1, 0.12),
	}))
	self.Maid:GiveTask(self.Frame)

	local frameLayout = Instance.new("UIListLayout")
	frameLayout.Padding = UDim.new(0, 8)
	frameLayout.SortOrder = Enum.SortOrder.LayoutOrder
	frameLayout.Parent = self.Frame
	self.Maid:GiveTask(frameLayout)

	self.Header = Creator.New("TextButton", {
		Parent = self.Frame,
		Size = UDim2.new(1, 0, 0, 28),
		BackgroundColor3 = "Surface2",
		BackgroundTransparency = 1,
		Text = "",
		AutoButtonColor = false,
	})
	self.Header.LayoutOrder = 1

	self.Label = Creator.New("TextLabel", {
		Parent = self.Header,
		Size = UDim2.new(1, -34, 1, 0),
		Position = UDim2.fromOffset(0, 0),
		BackgroundTransparency = 1,
		Text = self.Title,
		Font = Enum.Font.GothamSemibold,
		TextSize = 13,
		TextColor3 = "Text",
		TextXAlignment = Enum.TextXAlignment.Left,
		ThemeTag = { TextColor3 = "Text" },
	})

	self.Chevron = Creator.New("ImageLabel", {
		Parent = self.Header,
		Size = UDim2.fromOffset(16, 16),
		Position = UDim2.new(1, -16, 0.5, -8),
		BackgroundTransparency = 1,
		Image = Utility.GetIcon("chevron-down"),
		ImageColor3 = "Icon",
		Visible = self.Collapsible,
		ThemeTag = { ImageColor3 = "Icon" },
	})

	self.Content = Creator.New("Frame", {
		Parent = self.Frame,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		Visible = self.Opened,
	})
	self.Content.LayoutOrder = 2

	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 10)
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Parent = self.Content
	self.Maid:GiveTask(layout)

	if self.Collapsible then
		self.Maid:GiveTask(self.Header.MouseButton1Click:Connect(function()
			self:SetOpened(not self.Opened)
		end))
	end

	self.Maid:GiveTask(self.Header.MouseEnter:Connect(function()
		if not self.Collapsible then
			return
		end
		Utility.Tween(self.Header, TweenInfo.new(0.12, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
			BackgroundTransparency = 0.7,
		})
	end))
	self.Maid:GiveTask(self.Header.MouseLeave:Connect(function()
		Utility.Tween(self.Header, TweenInfo.new(0.12, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
			BackgroundTransparency = 1,
		})
	end))

	self:_syncChevron(false)
	return self
end

function Section:_syncChevron(animated)
	if not self.Chevron or not self.Collapsible then
		return
	end
	local rot = self.Opened and 0 or -90
	if animated then
		Utility.Tween(self.Chevron, TweenInfo.new(0.16, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { Rotation = rot })
	else
		self.Chevron.Rotation = rot
	end
end

function Section:SetTitle(title)
	self.Title = title
	self.Label.Text = title
end

function Section:SetOpened(opened)
	if not self.Collapsible then
		opened = true
	end
	self.Opened = opened and true or false
	self.Content.Visible = self.Opened
	self:_syncChevron(true)
end

function Section:Collapse()
	self:SetOpened(false)
end

function Section:Expand()
	self:SetOpened(true)
end

function Section:Destroy()
	self.Maid:DoCleaning()
end

-- Element helpers (same API as Tab)
function Section:_register(element)
	if self.Window and type(self.Window._registerElement) == "function" then
		return self.Window:_registerElement(element)
	end
	return element
end

function Section:AddButton(options) return self:_register(require(script.Parent.Button).new(self.Content, options, self.Window)) end
function Section:AddToggle(options) return self:_register(require(script.Parent.Toggle).new(self.Content, options, self.Window)) end
function Section:AddSlider(options) return self:_register(require(script.Parent.Slider).new(self.Content, options, self.Window)) end
function Section:AddLabel(options) return self:_register(require(script.Parent.Label).new(self.Content, options, self.Window)) end
function Section:AddParagraph(options) return self:_register(require(script.Parent.Paragraph).new(self.Content, options, self.Window)) end
function Section:AddInput(options) return self:_register(require(script.Parent.Input).new(self.Content, options, self.Window)) end
function Section:AddDropdown(options) return self:_register(require(script.Parent.Dropdown).new(self.Content, options, self.Window)) end
function Section:AddKeybind(options) return self:_register(require(script.Parent.Keybind).new(self.Content, options, self.Window)) end
function Section:AddColorPicker(options) return self:_register(require(script.Parent.ColorPicker).new(self.Content, options, self.Window)) end
function Section:AddSection(options) return self:_register(Section.new(self.Content, options, self.Window)) end
function Section:AddDivider(options) return self:_register(require(script.Parent.Divider).new(self.Content, options, self.Window)) end
function Section:AddSpacer(options) return self:_register(require(script.Parent.Spacer).new(self.Content, options, self.Window)) end
function Section:AddCode(options) return self:_register(require(script.Parent.Code).new(self.Content, options, self.Window)) end
function Section:AddProgress(options) return self:_register(require(script.Parent.Progress).new(self.Content, options, self.Window)) end
function Section:AddGroup(options) return require(script.Parent.Group).new(self.Content, options, self.Window) end

return Section
