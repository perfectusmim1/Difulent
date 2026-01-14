-- Phantasm Toggle (UI-first remake)
local Creator = require(script.Parent.Parent.Parent.Creator)
local Utility = require(script.Parent.Parent.Parent.Utils.Utility)
local ThemeManager = require(script.Parent.Parent.Parent.ThemeManager)
local Maid = require(script.Parent.Parent.Parent.Utils.Maid)

local Toggle = {}
Toggle.__index = Toggle

local function tweenToToken(instance, prop, token)
	local start = instance[prop]
	ThemeManager:Bind(instance, { [prop] = token })
	instance[prop] = start
	Utility.Tween(instance, TweenInfo.new(0.16, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
		[prop] = ThemeManager:GetColor(token),
	})
end

function Toggle.new(container, options, window)
	local self = setmetatable({}, Toggle)

	options = options or {}
	self.Maid = Maid.new()
	self.Window = window
	self.Options = options
	self.Value = options.Default == true
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
		Size = UDim2.new(1, 0, 0, 42),
		BackgroundColor3 = "Surface",
		BackgroundTransparency = 0.5,
		Text = "",
		AutoButtonColor = false,
		ThemeTag = { BackgroundColor3 = "Surface" },
	})
	Creator.AddCorner(self.Frame, 10)
	self.Stroke = Creator.AddStroke(self.Frame, { Color = "Outline", Thickness = 1, Transparency = 0.8, ThemeTag = { Color = "Outline" } })
	Utility.AddGradient(self.Frame, "Surface2", "Surface", NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.45),
		NumberSequenceKeypoint.new(1, 0.55),
	}))
	self.Maid:GiveTask(self.Frame)

	self.TitleLabel = Creator.New("TextLabel", {
		Parent = self.Frame,
		Size = UDim2.new(1, -70, 1, 0),
		Position = UDim2.fromOffset(14, 0),
		BackgroundTransparency = 1,
		Text = options.Title or "Toggle",
		Font = Enum.Font.GothamSemibold,
		TextSize = 13,
		TextColor3 = "Text",
		TextXAlignment = Enum.TextXAlignment.Left,
		ThemeTag = { TextColor3 = "Text" },
	})

	self.Switch = Creator.New("Frame", {
		Parent = self.Frame,
		Size = UDim2.fromOffset(46, 24),
		Position = UDim2.new(1, -14 - 46, 0.5, -12),
		BackgroundColor3 = self.Value and "Accent" or "Surface2",
		BackgroundTransparency = 0.15,
		BorderSizePixel = 0,
		ThemeTag = { BackgroundColor3 = self.Value and "Accent" or "Surface2" },
	})
	Creator.AddCorner(self.Switch, 12)
	Creator.AddStroke(self.Switch, { Color = "Outline", Thickness = 1, Transparency = 0.7, ThemeTag = { Color = "Outline" } })

	self.Knob = Creator.New("Frame", {
		Parent = self.Switch,
		Size = UDim2.fromOffset(18, 18),
		Position = self.Value and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9),
		BackgroundColor3 = "Text",
		BorderSizePixel = 0,
		ThemeTag = { BackgroundColor3 = "Text" },
	})
	Creator.AddCorner(self.Knob, 9)

	self.Maid:GiveTask(self.Frame.MouseEnter:Connect(function()
		if self.Disabled or self.Locked then
			return
		end
		Utility.Tween(self.Frame, TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { BackgroundTransparency = 0.35 })
		Utility.Tween(self.Stroke, TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { Transparency = 0.5 })
	end))
	self.Maid:GiveTask(self.Frame.MouseLeave:Connect(function()
		if self.Disabled or self.Locked then
			return
		end
		Utility.Tween(self.Frame, TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { BackgroundTransparency = 0.5 })
		Utility.Tween(self.Stroke, TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { Transparency = 0.8 })
	end))

	self.Maid:GiveTask(self.Frame.MouseButton1Click:Connect(function()
		if self.Disabled or self.Locked then
			return
		end
		self:Set(not self.Value)
	end))

	self:_syncState()
	return self
end

function Toggle:UpdateDisplay()
	local targetPos = self.Value and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)
	Utility.Tween(self.Knob, TweenInfo.new(0.16, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { Position = targetPos })

	tweenToToken(self.Switch, "BackgroundColor3", self.Value and "Accent" or "Surface2")
end

function Toggle:Set(val, silent)
	self.Value = val and true or false

	if self.Flag and self.Window then
		self.Window.Flags[self.Flag] = self.Value
	end

	self:UpdateDisplay()
	if not silent then
		if self.Flag and self.Window and type(self.Window._flagChanged) == "function" then
			self.Window:_flagChanged(self.Flag)
		end
		self.Callback(self.Value)
	end
end

function Toggle:Get()
	return self.Value
end

function Toggle:SetTitle(text)
	self.TitleLabel.Text = text
end

function Toggle:SetEnabled(enabled)
	self.Disabled = not enabled
	self:_syncState()
end

function Toggle:SetLocked(locked)
	self.Locked = locked and true or false
	self:_syncState()
end

function Toggle:_syncState()
	local blocked = self.Disabled or self.Locked
	self.Frame.Active = not blocked
	self.Frame.BackgroundTransparency = blocked and 0.6 or self._baseTransparency
	self.TitleLabel.TextTransparency = blocked and 0.4 or 0
	self.Switch.BackgroundTransparency = blocked and 0.4 or 0.15
end

function Toggle:Destroy()
	self.Maid:DoCleaning()
end

return Toggle
