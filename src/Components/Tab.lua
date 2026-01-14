-- Phantasm Tab (UI-first remake)
local Creator = require(script.Parent.Parent.Creator)
local Utility = require(script.Parent.Parent.Utils.Utility)
local ThemeManager = require(script.Parent.Parent.ThemeManager)
local Maid = require(script.Parent.Parent.Utils.Maid)

local Tab = {}
Tab.__index = Tab

local function tweenToToken(instance, prop, token)
	local start = instance[prop]
	ThemeManager:Bind(instance, { [prop] = token })
	instance[prop] = start
	Utility.Tween(instance, TweenInfo.new(0.16, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
		[prop] = ThemeManager:GetColor(token),
	})
end

function Tab.new(window, options)
	local self = setmetatable({}, Tab)

	self.Maid = Maid.new()
	self.Window = window
	self.Title = options.Title or "Tab"
	self.Icon = options.Icon

	-- Sidebar button
	self.Button = Creator.New("TextButton", {
		Parent = window.SidebarList,
		Size = UDim2.new(1, 0, 0, 36),
		BackgroundColor3 = "Surface2",
		BackgroundTransparency = 1,
		Text = "",
		AutoButtonColor = false,
		Name = self.Title,
		ZIndex = 12,
		ThemeTag = { BackgroundColor3 = "Surface2" },
	})
	Creator.AddCorner(self.Button, 10)
	self.SelectedStroke = Creator.AddStroke(self.Button, {
		Color = "Accent",
		Thickness = 1,
		Transparency = 1,
		ThemeTag = { Color = "Accent" },
	})
	Utility.AddGradient(self.Button, "Surface2", "Surface", NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.2),
		NumberSequenceKeypoint.new(1, 0.6),
	}))

	self.Indicator = Creator.New("Frame", {
		Parent = self.Button,
		Size = UDim2.fromOffset(3, 18),
		Position = UDim2.new(0, 8, 0.5, -9),
		BackgroundColor3 = "Accent",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ZIndex = 13,
		ThemeTag = { BackgroundColor3 = "Accent" },
	})
	Creator.AddCorner(self.Indicator, 2)

	local leftPad = 12
	if self.Icon then
		self.IconImage = Creator.New("ImageLabel", {
			Parent = self.Button,
			Size = UDim2.fromOffset(18, 18),
			Position = UDim2.new(0, 16, 0.5, -9),
			BackgroundTransparency = 1,
			Image = Utility.GetIcon(self.Icon),
			ImageColor3 = "Icon",
			ZIndex = 13,
			ThemeTag = { ImageColor3 = "Icon" },
		})
		leftPad = 16 + 18 + 10
	end

	self.Label = Creator.New("TextLabel", {
		Parent = self.Button,
		Size = UDim2.new(1, -leftPad, 1, 0),
		Position = UDim2.fromOffset(leftPad, 0),
		BackgroundTransparency = 1,
		Text = self.Title,
		Font = Enum.Font.GothamSemibold,
		TextSize = 13,
		TextColor3 = "SubText",
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Center,
		ZIndex = 13,
		ThemeTag = { TextColor3 = "SubText" },
	})

	-- Content container
	self.Container = Creator.New("ScrollingFrame", {
		Name = self.Title .. "Container",
		Parent = window.Content,
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = (window.Options.ScrollBarEnabled == false) and 0 or 3,
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		CanvasSize = UDim2.new(0, 0, 0, 0),
		Visible = false,
		ZIndex = 11,
	})
	Creator.AddPadding(self.Container, 18)

	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 12)
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Parent = self.Container
	self.Maid:GiveTask(layout)

	self.Maid:GiveTask(self.Button.MouseButton1Click:Connect(function()
		self:Select()
	end))

	-- Hover
	self.Maid:GiveTask(self.Button.MouseEnter:Connect(function()
		if self.Window.ActiveTab == self then
			return
		end
		Utility.Tween(self.Button, TweenInfo.new(0.12, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
			BackgroundTransparency = 0.7,
		})
	end))

	self.Maid:GiveTask(self.Button.MouseLeave:Connect(function()
		if self.Window.ActiveTab == self then
			return
		end
		Utility.Tween(self.Button, TweenInfo.new(0.12, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
			BackgroundTransparency = 1,
		})
	end))

	return self
end

function Tab:Select()
	self.Window.ActiveTab = self

	for _, t in ipairs(self.Window.Tabs) do
		t.Container.Visible = false

		if t.Indicator then
			Utility.Tween(t.Indicator, TweenInfo.new(0.12, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
				BackgroundTransparency = 1,
			})
		end

		if t.IconImage then
			tweenToToken(t.IconImage, "ImageColor3", "Icon")
		end
		if t.Label then
			tweenToToken(t.Label, "TextColor3", "SubText")
		end

		Utility.Tween(t.Button, TweenInfo.new(0.12, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
			BackgroundTransparency = 1,
		})
		if t.SelectedStroke then
			Utility.Tween(t.SelectedStroke, TweenInfo.new(0.12, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
				Transparency = 1,
			})
		end
	end

	self.Container.Visible = true

	if self.Indicator then
		Utility.Tween(self.Indicator, TweenInfo.new(0.12, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
			BackgroundTransparency = 0,
		})
	end

	if self.IconImage then
		tweenToToken(self.IconImage, "ImageColor3", "Text")
	end
	tweenToToken(self.Label, "TextColor3", "Text")

	Utility.Tween(self.Button, TweenInfo.new(0.12, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
		BackgroundTransparency = 0.2,
	})
	if self.SelectedStroke then
		Utility.Tween(self.SelectedStroke, TweenInfo.new(0.12, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
			Transparency = 0.45,
		})
	end
end

function Tab:Destroy()
	self.Maid:DoCleaning()
end

-- Proxy Methods for Elements
function Tab:_register(element)
	if self.Window and type(self.Window._registerElement) == "function" then
		return self.Window:_registerElement(element)
	end
	return element
end

function Tab:AddButton(options) return self:_register(require(script.Parent.Elements.Button).new(self.Container, options, self.Window)) end
function Tab:AddToggle(options) return self:_register(require(script.Parent.Elements.Toggle).new(self.Container, options, self.Window)) end
function Tab:AddSlider(options) return self:_register(require(script.Parent.Elements.Slider).new(self.Container, options, self.Window)) end
function Tab:AddLabel(options) return self:_register(require(script.Parent.Elements.Label).new(self.Container, options, self.Window)) end
function Tab:AddParagraph(options) return self:_register(require(script.Parent.Elements.Paragraph).new(self.Container, options, self.Window)) end
function Tab:AddInput(options) return self:_register(require(script.Parent.Elements.Input).new(self.Container, options, self.Window)) end
function Tab:AddDropdown(options) return self:_register(require(script.Parent.Elements.Dropdown).new(self.Container, options, self.Window)) end
function Tab:AddKeybind(options) return self:_register(require(script.Parent.Elements.Keybind).new(self.Container, options, self.Window)) end
function Tab:AddColorPicker(options) return self:_register(require(script.Parent.Elements.ColorPicker).new(self.Container, options, self.Window)) end
function Tab:AddSection(options) return self:_register(require(script.Parent.Elements.Section).new(self.Container, options, self.Window)) end
function Tab:AddDivider(options) return self:_register(require(script.Parent.Elements.Divider).new(self.Container, options, self.Window)) end
function Tab:AddSpacer(options) return self:_register(require(script.Parent.Elements.Spacer).new(self.Container, options, self.Window)) end
function Tab:AddCode(options) return self:_register(require(script.Parent.Elements.Code).new(self.Container, options, self.Window)) end
function Tab:AddProgress(options) return self:_register(require(script.Parent.Elements.Progress).new(self.Container, options, self.Window)) end
function Tab:AddGroup(options) return require(script.Parent.Elements.Group).new(self.Container, options, self.Window) end

return Tab
