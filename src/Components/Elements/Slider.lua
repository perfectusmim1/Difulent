-- Phantasm Slider (UI-first remake)
local UserInputService = game:GetService("UserInputService")

local Creator = require(script.Parent.Parent.Parent.Creator)
local Utility = require(script.Parent.Parent.Parent.Utils.Utility)
local ThemeManager = require(script.Parent.Parent.Parent.ThemeManager)
local Maid = require(script.Parent.Parent.Parent.Utils.Maid)

local Slider = {}
Slider.__index = Slider

function Slider.new(container, options, window)
	local self = setmetatable({}, Slider)

	options = options or {}
	self.Maid = Maid.new()
	self.Window = window
	self.Options = options

	self.Min = tonumber(options.Min) or 0
	self.Max = tonumber(options.Max) or 100
	self.Step = tonumber(options.Step) or 1
	if self.Step <= 0 then
		self.Step = 1
	end

	self.Value = tonumber(options.Default) or self.Min
	self.Callback = options.Callback or function() end
	self.Flag = options.Flag
	self.Disabled = false
	self.Locked = false
	self._baseTransparency = 0.12

	if self.Flag and self.Window then
		self.Window.Flags[self.Flag] = self.Value
	end

	self.Frame = Creator.New("Frame", {
		Parent = container,
		Size = UDim2.new(1, 0, 0, 56),
		BackgroundColor3 = "Surface",
		BackgroundTransparency = self._baseTransparency,
		BorderSizePixel = 0,
		ThemeTag = { BackgroundColor3 = "Surface" },
	})
	Creator.AddCorner(self.Frame, 14)
	Creator.AddStroke(self.Frame, { Color = "Outline", Thickness = 1, Transparency = 0.7, ThemeTag = { Color = "Outline" } })
	Creator.AddPadding(self.Frame, 14)
	Utility.AddGradient(self.Frame, "Surface2", "Surface", NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.05),
		NumberSequenceKeypoint.new(1, 0.15),
	}))
	self.Maid:GiveTask(self.Frame)

	self.TitleLabel = Creator.New("TextLabel", {
		Parent = self.Frame,
		Size = UDim2.new(1, -70, 0, 18),
		BackgroundTransparency = 1,
		Text = options.Title or "Slider",
		Font = Enum.Font.GothamSemibold,
		TextSize = 13,
		TextColor3 = "Text",
		TextXAlignment = Enum.TextXAlignment.Left,
		ThemeTag = { TextColor3 = "Text" },
	})

	self.ValueLabel = Creator.New("TextLabel", {
		Parent = self.Frame,
		Size = UDim2.new(0, 70, 0, 18),
		Position = UDim2.new(1, -70, 0, 0),
		BackgroundTransparency = 1,
		Text = "",
		Font = Enum.Font.Gotham,
		TextSize = 13,
		TextColor3 = "SubText",
		TextXAlignment = Enum.TextXAlignment.Right,
		ThemeTag = { TextColor3 = "SubText" },
	})

	self.Bar = Creator.New("TextButton", {
		Parent = self.Frame,
		Size = UDim2.new(1, 0, 0, 8),
		Position = UDim2.new(0, 0, 0, 30),
		BackgroundColor3 = "Surface2",
		BackgroundTransparency = 0.3,
		Text = "",
		AutoButtonColor = false,
		BorderSizePixel = 0,
		ThemeTag = { BackgroundColor3 = "Surface2" },
	})
	Creator.AddCorner(self.Bar, 8)

	self.Fill = Creator.New("Frame", {
		Parent = self.Bar,
		Size = UDim2.new(0, 0, 1, 0),
		BackgroundColor3 = "Accent",
		BorderSizePixel = 0,
		ThemeTag = { BackgroundColor3 = "Accent" },
	})
	Creator.AddCorner(self.Fill, 8)

	self.Knob = Creator.New("Frame", {
		Parent = self.Bar,
		Size = UDim2.fromOffset(14, 14),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0, 0, 0.5, 0),
		BackgroundColor3 = "Text",
		BorderSizePixel = 0,
		ThemeTag = { BackgroundColor3 = "Text" },
	})
	Creator.AddCorner(self.Knob, 7)

	local dragging = false

	local function setFromX(x)
		if self.Disabled or self.Locked then
			return
		end
		local barX = self.Bar.AbsolutePosition.X
		local barW = self.Bar.AbsoluteSize.X
		if barW <= 1 then
			return
		end
		local alpha = math.clamp((x - barX) / barW, 0, 1)
		local raw = self.Min + ((self.Max - self.Min) * alpha)
		local stepped = math.floor((raw / self.Step) + 0.5) * self.Step
		self:Set(stepped)
	end

	self.Maid:GiveTask(self.Bar.InputBegan:Connect(function(input)
		if self.Disabled or self.Locked then
			return
		end
		if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then
			return
		end
		dragging = true
		setFromX(input.Position.X)
	end))

	self.Maid:GiveTask(UserInputService.InputChanged:Connect(function(input)
		if self.Disabled or self.Locked then
			return
		end
		if not dragging then
			return
		end
		if input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch then
			return
		end
		setFromX(input.Position.X)
	end))

	self.Maid:GiveTask(UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end))

	self:Set(self.Value)
	self:_syncState()
	return self
end

function Slider:Set(value, silent)
	value = tonumber(value) or self.Min
	value = math.clamp(value, self.Min, self.Max)

	self.Value = value

	local range = (self.Max - self.Min)
	local alpha = 0
	if range ~= 0 then
		alpha = (self.Value - self.Min) / range
	end

	Utility.Tween(self.Fill, TweenInfo.new(0.12, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
		Size = UDim2.new(alpha, 0, 1, 0),
	})
	Utility.Tween(self.Knob, TweenInfo.new(0.12, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
		Position = UDim2.new(alpha, 0, 0.5, 0),
	})

	local prefix = self.Options.Prefix or ""
	local suffix = self.Options.Suffix or ""
	self.ValueLabel.Text = prefix .. tostring(self.Value) .. suffix

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

function Slider:Get()
	return self.Value
end

function Slider:SetEnabled(enabled)
	self.Disabled = not enabled
	self:_syncState()
end

function Slider:SetLocked(locked)
	self.Locked = locked and true or false
	self:_syncState()
end

function Slider:_syncState()
	local blocked = self.Disabled or self.Locked
	self.Frame.BackgroundTransparency = blocked and 0.6 or self._baseTransparency
	self.TitleLabel.TextTransparency = blocked and 0.4 or 0
	self.ValueLabel.TextTransparency = blocked and 0.5 or 0
	self.Bar.Active = not blocked
end

function Slider:Destroy()
	self.Maid:DoCleaning()
end

return Slider
