-- Phantasm Progress Bar
local Creator = require(script.Parent.Parent.Parent.Creator)
local Utility = require(script.Parent.Parent.Parent.Utils.Utility)
local Maid = require(script.Parent.Parent.Parent.Utils.Maid)

local Progress = {}
Progress.__index = Progress

function Progress.new(container, options, window)
	local self = setmetatable({}, Progress)
	options = options or {}

	self.Maid = Maid.new()
	self.Window = window
	self.Options = options

	self.Min = tonumber(options.Min) or 0
	self.Max = tonumber(options.Max) or 100
	if self.Max == self.Min then
		self.Max = self.Min + 1
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

	local hasDesc = type(options.Desc) == "string" and options.Desc ~= ""
	local height = hasDesc and 74 or 58

	self.Frame = Creator.New("Frame", {
		Parent = container,
		Size = UDim2.new(1, 0, 0, height),
		BackgroundColor3 = "Surface",
		BackgroundTransparency = self._baseTransparency,
		BorderSizePixel = 0,
		ThemeTag = { BackgroundColor3 = "Surface" },
	})
	Creator.AddCorner(self.Frame, 14)
	Creator.AddStroke(self.Frame, { Color = "Outline", Thickness = 1, Transparency = 0.7, ThemeTag = { Color = "Outline" } })
	Utility.AddGradient(self.Frame, "Surface2", "Surface", NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.05),
		NumberSequenceKeypoint.new(1, 0.15),
	}))
	Creator.AddPadding(self.Frame, 14)
	self.Maid:GiveTask(self.Frame)

	self.TitleLabel = Creator.New("TextLabel", {
		Parent = self.Frame,
		Size = UDim2.new(1, -90, 0, 18),
		BackgroundTransparency = 1,
		Text = options.Title or "Progress",
		Font = Enum.Font.GothamSemibold,
		TextSize = 13,
		TextColor3 = "Text",
		TextXAlignment = Enum.TextXAlignment.Left,
		ThemeTag = { TextColor3 = "Text" },
	})

	self.ValueLabel = Creator.New("TextLabel", {
		Parent = self.Frame,
		Size = UDim2.new(0, 90, 0, 18),
		Position = UDim2.new(1, -90, 0, 0),
		BackgroundTransparency = 1,
		Text = "",
		Font = Enum.Font.Gotham,
		TextSize = 13,
		TextColor3 = "SubText",
		TextXAlignment = Enum.TextXAlignment.Right,
		ThemeTag = { TextColor3 = "SubText" },
	})

	if hasDesc then
		self.DescLabel = Creator.New("TextLabel", {
			Parent = self.Frame,
			Size = UDim2.new(1, 0, 0, 16),
			Position = UDim2.new(0, 0, 0, 20),
			BackgroundTransparency = 1,
			Text = options.Desc,
			Font = Enum.Font.Gotham,
			TextSize = 12,
			TextColor3 = "SubText",
			TextTransparency = 0.15,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd,
			ThemeTag = { TextColor3 = "SubText" },
		})
	end

	local barY = hasDesc and 46 or 30
	self.Bar = Creator.New("Frame", {
		Parent = self.Frame,
		Size = UDim2.new(1, 0, 0, 8),
		Position = UDim2.new(0, 0, 0, barY),
		BackgroundColor3 = "Surface2",
		BackgroundTransparency = 0.3,
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

	self:Set(self.Value, true)
	self:_syncState()
	return self
end

function Progress:_toAlpha(value)
	local v = math.clamp(value, self.Min, self.Max)
	return (v - self.Min) / (self.Max - self.Min)
end

function Progress:Set(value, silent)
	value = tonumber(value) or self.Min
	value = math.clamp(value, self.Min, self.Max)
	self.Value = value

	local alpha = self:_toAlpha(value)
	Utility.Tween(self.Fill, TweenInfo.new(0.14, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
		Size = UDim2.new(alpha, 0, 1, 0),
	})

	local prefix = self.Options.Prefix or ""
	local suffix = self.Options.Suffix or "%"
	local percent = math.floor((alpha * 100) + 0.5)
	self.ValueLabel.Text = prefix .. tostring(percent) .. suffix

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

function Progress:Get()
	return self.Value
end

function Progress:SetEnabled(enabled)
	self.Disabled = not enabled
	self:_syncState()
end

function Progress:SetLocked(locked)
	self.Locked = locked and true or false
	self:_syncState()
end

function Progress:_syncState()
	local blocked = self.Disabled or self.Locked
	self.Frame.BackgroundTransparency = blocked and 0.6 or self._baseTransparency
	self.TitleLabel.TextTransparency = blocked and 0.4 or 0
	self.ValueLabel.TextTransparency = blocked and 0.5 or 0
	if self.DescLabel then
		self.DescLabel.TextTransparency = blocked and 0.55 or 0.15
	end
	self.Fill.BackgroundTransparency = blocked and 0.35 or 0
end

function Progress:Destroy()
	self.Maid:DoCleaning()
end

return Progress

