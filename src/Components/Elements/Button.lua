-- Phantasm Button (UI-first remake)
local Creator = require(script.Parent.Parent.Parent.Creator)
local Utility = require(script.Parent.Parent.Parent.Utils.Utility)
local ThemeManager = require(script.Parent.Parent.Parent.ThemeManager)
local Maid = require(script.Parent.Parent.Parent.Utils.Maid)

local Button = {}
Button.__index = Button

function Button.new(container, options)
	local self = setmetatable({}, Button)

	options = options or {}
	self.Maid = Maid.new()
	self.Options = options
	self.Callback = options.Callback or function() end
	self.Disabled = false
	self.Locked = false
	self._baseTransparency = 0.12

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
	self.Stroke = Creator.AddStroke(self.Frame, {
		Color = "Outline",
		Thickness = 1,
		Transparency = 0.8,
		ThemeTag = { Color = "Outline" },
	})
	Utility.AddGradient(self.Frame, "Surface2", "Surface", NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.45),
		NumberSequenceKeypoint.new(1, 0.55),
	}))
	self.Maid:GiveTask(self.Frame)

	local rippleConn = Utility.AddRipple(self.Frame, ThemeManager:GetColor("Text"))
	self.Maid:GiveTask(rippleConn)

	self.TitleLabel = Creator.New("TextLabel", {
		Parent = self.Frame,
		Size = UDim2.new(1, -52, 1, 0),
		Position = UDim2.fromOffset(14, 0),
		BackgroundTransparency = 1,
		Text = options.Title or "Button",
		Font = Enum.Font.GothamSemibold,
		TextSize = 13,
		TextColor3 = "Text",
		TextXAlignment = Enum.TextXAlignment.Left,
		ThemeTag = { TextColor3 = "Text" },
	})

	self.Icon = Creator.New("ImageLabel", {
		Parent = self.Frame,
		Size = UDim2.fromOffset(16, 16),
		Position = UDim2.new(1, -26, 0.5, -8),
		BackgroundTransparency = 1,
		Image = Utility.GetIcon("chevron-right"),
		ImageColor3 = "Icon",
		ThemeTag = { ImageColor3 = "Icon" },
	})

	self.Maid:GiveTask(self.Frame.MouseEnter:Connect(function()
		if self.Disabled or self.Locked then
			return
		end
		Utility.Tween(self.Frame, TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
			BackgroundTransparency = 0.35,
		})
		Utility.Tween(self.Stroke, TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
			Transparency = 0.5,
		})
	end))
	self.Maid:GiveTask(self.Frame.MouseLeave:Connect(function()
		if self.Disabled or self.Locked then
			return
		end
		Utility.Tween(self.Frame, TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
			BackgroundTransparency = 0.5,
		})
		Utility.Tween(self.Stroke, TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
			Transparency = 0.8,
		})
	end))

	self.Maid:GiveTask(self.Frame.MouseButton1Click:Connect(function()
		if self.Disabled or self.Locked then
			return
		end
		self.Callback()
	end))

	self:_syncState()
	return self
end

function Button:_syncState()
	local blocked = self.Disabled or self.Locked
	self.Frame.Active = not blocked
	self.Frame.BackgroundTransparency = blocked and 0.6 or self._baseTransparency
	self.TitleLabel.TextTransparency = blocked and 0.4 or 0
	if self.Icon then
		self.Icon.ImageTransparency = blocked and 0.4 or 0
	end
end

function Button:SetTitle(text)
	self.TitleLabel.Text = text
end

function Button:SetCallback(fn)
	self.Callback = fn or function() end
end

function Button:SetEnabled(enabled)
	self.Disabled = not enabled
	self:_syncState()
end

function Button:SetLocked(locked)
	self.Locked = locked and true or false
	self:_syncState()
end

function Button:Destroy()
	self.Maid:DoCleaning()
end

return Button
