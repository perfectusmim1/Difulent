-- Phantasm ColorPicker (UI-first remake)
local UserInputService = game:GetService("UserInputService")

local Creator = require(script.Parent.Parent.Parent.Creator)
local Utility = require(script.Parent.Parent.Parent.Utils.Utility)
local Maid = require(script.Parent.Parent.Parent.Utils.Maid)

local ColorPicker = {}
ColorPicker.__index = ColorPicker

local function clamp01(x)
	return math.clamp(x, 0, 1)
end

function ColorPicker.new(container, options, window)
	local self = setmetatable({}, ColorPicker)

	options = options or {}
	self.Maid = Maid.new()
	self.PopupMaid = nil
	self.Window = window
	self.Options = options

	self.Value = options.Default or Color3.new(1, 1, 1)
	self.Callback = options.Callback or function() end
	self.Flag = options.Flag
	self.Disabled = false
	self.Locked = false
	self._baseTransparency = 0.12

	if self.Flag and self.Window then
		self.Window.Flags[self.Flag] = self.Value
	end

	self.Frame = Creator.New("TextButton", {
		Parent = container,
		Size = UDim2.new(1, 0, 0, 44),
		BackgroundColor3 = "Surface",
		BackgroundTransparency = self._baseTransparency,
		Text = "",
		AutoButtonColor = false,
		BorderSizePixel = 0,
		ThemeTag = { BackgroundColor3 = "Surface" },
	})
	Creator.AddCorner(self.Frame, 14)
	Creator.AddStroke(self.Frame, { Color = "Outline", Thickness = 1, Transparency = 0.7, ThemeTag = { Color = "Outline" } })
	Utility.AddGradient(self.Frame, "Surface2", "Surface", NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.05),
		NumberSequenceKeypoint.new(1, 0.15),
	}))
	self.Maid:GiveTask(self.Frame)

	self.TitleLabel = Creator.New("TextLabel", {
		Parent = self.Frame,
		Size = UDim2.new(1, -70, 1, 0),
		Position = UDim2.fromOffset(14, 0),
		BackgroundTransparency = 1,
		Text = options.Title or "ColorPicker",
		Font = Enum.Font.GothamSemibold,
		TextSize = 13,
		TextColor3 = "Text",
		TextXAlignment = Enum.TextXAlignment.Left,
		ThemeTag = { TextColor3 = "Text" },
	})

	self.Indicator = Creator.New("Frame", {
		Parent = self.Frame,
		Size = UDim2.fromOffset(46, 24),
		Position = UDim2.new(1, -14 - 46, 0.5, -12),
		BackgroundColor3 = self.Value,
		BorderSizePixel = 0,
	})
	Creator.AddCorner(self.Indicator, 10)
	Creator.AddStroke(self.Indicator, { Color = "Outline", Thickness = 1, Transparency = 0.7, ThemeTag = { Color = "Outline" } })

	self.Maid:GiveTask(self.Frame.MouseButton1Click:Connect(function()
		if self.Disabled or self.Locked then
			return
		end
		self:Toggle()
	end))

	self.Maid:GiveTask(self.Frame.MouseEnter:Connect(function()
		if self.Disabled or self.Locked then
			return
		end
		Utility.Tween(self.Frame, TweenInfo.new(0.12, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { BackgroundTransparency = 0.06 })
	end))
	self.Maid:GiveTask(self.Frame.MouseLeave:Connect(function()
		if self.Disabled or self.Locked then
			return
		end
		Utility.Tween(self.Frame, TweenInfo.new(0.12, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { BackgroundTransparency = self._baseTransparency })
	end))

	if self.Window and self.Window.OnClose then
		self.Maid:GiveTask(self.Window.OnClose:Connect(function()
			self:Close()
		end))
	end

	self:_syncState()
	return self
end

function ColorPicker:_setChannel(channel, v01)
	v01 = clamp01(v01)
	local r, g, b = self.Value.R, self.Value.G, self.Value.B
	if channel == "R" then
		r = v01
	elseif channel == "G" then
		g = v01
	elseif channel == "B" then
		b = v01
	end
	self:Set(Color3.new(r, g, b))
end

function ColorPicker:_updatePopup()
	if not self.PopupFrame then
		return
	end
	self.Preview.BackgroundColor3 = self.Value

	if self.Sliders then
		self.Sliders.R.Fill.Size = UDim2.new(self.Value.R, 0, 1, 0)
		self.Sliders.G.Fill.Size = UDim2.new(self.Value.G, 0, 1, 0)
		self.Sliders.B.Fill.Size = UDim2.new(self.Value.B, 0, 1, 0)
		self.Sliders.R.Knob.Position = UDim2.new(self.Value.R, 0, 0.5, 0)
		self.Sliders.G.Knob.Position = UDim2.new(self.Value.G, 0, 0.5, 0)
		self.Sliders.B.Knob.Position = UDim2.new(self.Value.B, 0, 0.5, 0)
	end
end

function ColorPicker:Open()
	if self.Disabled or self.Locked then
		return
	end
	if self.PopupFrame then
		return
	end

	if self.PopupMaid then
		self.PopupMaid:DoCleaning()
	end
	self.PopupMaid = Maid.new()

	local main = self.Window and (self.Window.OverlayLayer or self.Window.Main) or self.Frame

	local overlay = Instance.new("TextButton")
	overlay.Name = "ColorPickerOverlay"
	overlay.BackgroundTransparency = 1
	overlay.Text = ""
	overlay.AutoButtonColor = false
	overlay.Size = UDim2.fromScale(1, 1)
	overlay.ZIndex = 320
	overlay.Parent = main
	self.PopupMaid:GiveTask(overlay)

	self.PopupMaid:GiveTask(overlay.MouseButton1Click:Connect(function()
		self:Close()
	end))

	self.PopupFrame = Creator.New("Frame", {
		Parent = main,
		Size = UDim2.fromOffset(280, 190),
		BackgroundColor3 = "Surface",
		BackgroundTransparency = 0.06,
		BorderSizePixel = 0,
		ZIndex = 330,
		ThemeTag = { BackgroundColor3 = "Surface" },
	})
	Creator.AddCorner(self.PopupFrame, 12)
	Creator.AddStroke(self.PopupFrame, { Color = "Outline", Thickness = 1, Transparency = 0.6, ThemeTag = { Color = "Outline" } })
	Utility.AddGradient(self.PopupFrame, "Surface2", "Surface", NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.05),
		NumberSequenceKeypoint.new(1, 0.12),
	}))
	Creator.AddPadding(self.PopupFrame, 12)

	local mainAbs = main.AbsolutePosition
	local frameAbs = self.Frame.AbsolutePosition
	local relX = frameAbs.X - mainAbs.X
	local relY = frameAbs.Y - mainAbs.Y + self.Frame.AbsoluteSize.Y + 8

	-- Keep popup inside window
	local maxX = main.AbsoluteSize.X - 10 - 280
	local maxY = main.AbsoluteSize.Y - 10 - 190
	relX = math.clamp(relX, 10, math.max(10, maxX))
	relY = math.clamp(relY, 10, math.max(10, maxY))

	self.PopupFrame.Position = UDim2.fromOffset(relX, relY)

	self.Preview = Instance.new("Frame")
	self.Preview.Name = "Preview"
	self.Preview.Size = UDim2.new(1, 0, 0, 34)
	self.Preview.BackgroundColor3 = self.Value
	self.Preview.BorderSizePixel = 0
	self.Preview.ZIndex = 331
	self.Preview.Parent = self.PopupFrame
	Creator.AddCorner(self.Preview, 10)
	Creator.AddStroke(self.Preview, { Color = "Outline", Thickness = 1, Transparency = 0.8, ThemeTag = { Color = "Outline" } })

	local layout = Instance.new("UIListLayout")
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Padding = UDim.new(0, 10)
	layout.Parent = self.PopupFrame

	local function makeChannel(channel, barColor)
		local row = Instance.new("Frame")
		row.BackgroundTransparency = 1
		row.Size = UDim2.new(1, 0, 0, 34)
		row.ZIndex = 331
		row.Parent = self.PopupFrame

		local label = Creator.New("TextLabel", {
			Parent = row,
			Size = UDim2.fromOffset(18, 18),
			Position = UDim2.new(0, 0, 0.5, -9),
			BackgroundTransparency = 1,
			Text = channel,
			Font = Enum.Font.GothamBold,
			TextSize = 12,
			TextColor3 = "SubText",
			TextXAlignment = Enum.TextXAlignment.Left,
			ZIndex = 102,
			ThemeTag = { TextColor3 = "SubText" },
		})

		local bar = Creator.New("TextButton", {
			Parent = row,
			Size = UDim2.new(1, -28, 0, 8),
			Position = UDim2.new(0, 24, 0.5, -4),
			BackgroundColor3 = "Surface2",
			BackgroundTransparency = 0.25,
			Text = "",
			AutoButtonColor = false,
			BorderSizePixel = 0,
			ZIndex = 102,
			ThemeTag = { BackgroundColor3 = "Surface2" },
		})
		Creator.AddCorner(bar, 8)

		local fill = Instance.new("Frame")
		fill.BackgroundColor3 = barColor
		fill.BorderSizePixel = 0
		fill.Size = UDim2.new(0, 0, 1, 0)
		fill.ZIndex = 103
		fill.Parent = bar
		Creator.AddCorner(fill, 8)

		local knob = Creator.New("Frame", {
			Parent = bar,
			Size = UDim2.fromOffset(14, 14),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0, 0, 0.5, 0),
			BackgroundColor3 = "Text",
			BorderSizePixel = 0,
			ZIndex = 104,
			ThemeTag = { BackgroundColor3 = "Text" },
		})
		Creator.AddCorner(knob, 7)

		return {
			Bar = bar,
			Fill = fill,
			Knob = knob,
			Channel = channel,
		}
	end

	self.Sliders = {
		R = makeChannel("R", Color3.fromRGB(255, 90, 90)),
		G = makeChannel("G", Color3.fromRGB(90, 255, 140)),
		B = makeChannel("B", Color3.fromRGB(90, 160, 255)),
	}

	local dragging = nil

	local function setFromInput(input)
		if not dragging then
			return
		end
		local bar = dragging.Bar
		local barX = bar.AbsolutePosition.X
		local barW = bar.AbsoluteSize.X
		if barW <= 1 then
			return
		end
		local alpha = clamp01((input.Position.X - barX) / barW)
		self:_setChannel(dragging.Channel, alpha)
	end

	for _, slider in pairs(self.Sliders) do
		self.PopupMaid:GiveTask(slider.Bar.InputBegan:Connect(function(input)
			if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then
				return
			end
			dragging = slider
			setFromInput(input)
		end))
	end

	self.PopupMaid:GiveTask(UserInputService.InputChanged:Connect(function(input)
		if not dragging then
			return
		end
		if input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch then
			return
		end
		setFromInput(input)
	end))

	self.PopupMaid:GiveTask(UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = nil
		end
	end))

	self:_updatePopup()
end

function ColorPicker:Close()
	if not self.PopupFrame then
		return
	end

	if self.PopupMaid then
		self.PopupMaid:DoCleaning()
		self.PopupMaid = nil
	end

	if self.PopupFrame then
		self.PopupFrame:Destroy()
		self.PopupFrame = nil
	end
	self.Preview = nil
	self.Sliders = nil
end

function ColorPicker:Toggle()
	if self.PopupFrame then
		self:Close()
	else
		self:Open()
	end
end

function ColorPicker:Set(color, silent)
	if typeof(color) ~= "Color3" then
		return
	end
	self.Value = color
	self.Indicator.BackgroundColor3 = color
	self:_updatePopup()

	if self.Flag and self.Window then
		self.Window.Flags[self.Flag] = self.Value
	end
	if not silent then
		if self.Flag and self.Window and type(self.Window._flagChanged) == "function" then
			self.Window:_flagChanged(self.Flag)
		end
		self.Callback(self.Value)
	end
end

function ColorPicker:Get()
	return self.Value
end

function ColorPicker:SetEnabled(enabled)
	self.Disabled = not enabled
	self:_syncState()
	if self.Disabled then
		self:Close()
	end
end

function ColorPicker:SetLocked(locked)
	self.Locked = locked and true or false
	self:_syncState()
	if self.Locked then
		self:Close()
	end
end

function ColorPicker:_syncState()
	local blocked = self.Disabled or self.Locked
	self.Frame.BackgroundTransparency = blocked and 0.6 or self._baseTransparency
	self.TitleLabel.TextTransparency = blocked and 0.4 or 0
	self.Indicator.BackgroundTransparency = blocked and 0.3 or 0
	self.Frame.Active = not blocked
end

function ColorPicker:Destroy()
	self:Close()
	self.Maid:DoCleaning()
end

return ColorPicker
