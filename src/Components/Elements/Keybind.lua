-- Phantasm Keybind (UI-first remake)
local UserInputService = game:GetService("UserInputService")

local Creator = require(script.Parent.Parent.Parent.Creator)
local Utility = require(script.Parent.Parent.Parent.Utils.Utility)
local Maid = require(script.Parent.Parent.Parent.Utils.Maid)

local Keybind = {}
Keybind.__index = Keybind

function Keybind.new(container, options, window)
	local self = setmetatable({}, Keybind)

	options = options or {}
	self.Maid = Maid.new()
	self.Window = window
	self.Options = options

	self.Value = options.Default -- Enum.KeyCode?
	self.Callback = options.Callback or function() end
	self.Flag = options.Flag
	self.Binding = false
	self.Disabled = false
	self.Locked = false
	self._baseTransparency = 0.25

	if self.Flag and self.Window then
		self.Window.Flags[self.Flag] = self.Value
	end

	self.Frame = Creator.New("Frame", {
		Parent = container,
		Size = UDim2.new(1, 0, 0, 42),
		BackgroundColor3 = "Surface2",
		BackgroundTransparency = self._baseTransparency,
		BorderSizePixel = 0,
		ThemeTag = { BackgroundColor3 = "Surface2" },
	})
	Creator.AddCorner(self.Frame, 12)
	Creator.AddStroke(self.Frame, { Color = "Outline", Thickness = 1, Transparency = 0.8, ThemeTag = { Color = "Outline" } })
	self.Maid:GiveTask(self.Frame)

	self.TitleLabel = Creator.New("TextLabel", {
		Parent = self.Frame,
		Size = UDim2.new(1, -110, 1, 0),
		Position = UDim2.fromOffset(14, 0),
		BackgroundTransparency = 1,
		Text = options.Title or "Keybind",
		Font = Enum.Font.GothamMedium,
		TextSize = 13,
		TextColor3 = "Text",
		TextXAlignment = Enum.TextXAlignment.Left,
		ThemeTag = { TextColor3 = "Text" },
	})

	self.Button = Creator.New("TextButton", {
		Parent = self.Frame,
		Size = UDim2.fromOffset(92, 30),
		Position = UDim2.new(1, -14 - 92, 0.5, -15),
		BackgroundColor3 = "Surface",
		BackgroundTransparency = 0.25,
		Text = "",
		AutoButtonColor = false,
		BorderSizePixel = 0,
		ThemeTag = { BackgroundColor3 = "Surface" },
	})
	Creator.AddCorner(self.Button, 10)
	Creator.AddStroke(self.Button, { Color = "Outline", Thickness = 1, Transparency = 0.85, ThemeTag = { Color = "Outline" } })

	self.BindLabel = Creator.New("TextLabel", {
		Parent = self.Button,
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		Text = self.Value and self.Value.Name or "None",
		Font = Enum.Font.Gotham,
		TextSize = 12,
		TextColor3 = "SubText",
		TextTruncate = Enum.TextTruncate.AtEnd,
		ThemeTag = { TextColor3 = "SubText" },
	})

	self.Maid:GiveTask(self.Button.MouseButton1Click:Connect(function()
		if self.Disabled or self.Locked then
			return
		end
		self.Binding = true
		self.BindLabel.Text = "..."
	end))

	self.Maid:GiveTask(UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if self.Disabled or self.Locked then
			return
		end
		if gameProcessed then
			return
		end

		if self.Binding then
			if input.UserInputType == Enum.UserInputType.Keyboard then
				self.Binding = false
				if input.KeyCode == Enum.KeyCode.Escape then
					self:Set(nil)
				else
					self:Set(input.KeyCode)
				end
			elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
				self.Binding = false
				self:Set(nil)
			end
			return
		end

		if self.Value and input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == self.Value then
			self.Callback()
		end
	end))

	self.Maid:GiveTask(self.Frame.MouseEnter:Connect(function()
		if self.Disabled or self.Locked then
			return
		end
		Utility.Tween(self.Frame, TweenInfo.new(0.12, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { BackgroundTransparency = 0.12 })
	end))
	self.Maid:GiveTask(self.Frame.MouseLeave:Connect(function()
		if self.Disabled or self.Locked then
			return
		end
		Utility.Tween(self.Frame, TweenInfo.new(0.12, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { BackgroundTransparency = self._baseTransparency })
	end))

	self:_syncState()
	return self
end

function Keybind:Set(keyCode, silent)
	self.Value = keyCode
	self.BindLabel.Text = keyCode and keyCode.Name or "None"

	if self.Flag and self.Window then
		self.Window.Flags[self.Flag] = self.Value
		if not silent and type(self.Window._flagChanged) == "function" then
			self.Window:_flagChanged(self.Flag)
		end
	end
end

function Keybind:Get()
	return self.Value
end

function Keybind:SetEnabled(enabled)
	self.Disabled = not enabled
	self:_syncState()
end

function Keybind:SetLocked(locked)
	self.Locked = locked and true or false
	self:_syncState()
end

function Keybind:_syncState()
	local blocked = self.Disabled or self.Locked
	self.Frame.BackgroundTransparency = blocked and 0.6 or self._baseTransparency
	self.TitleLabel.TextTransparency = blocked and 0.4 or 0
	self.BindLabel.TextTransparency = blocked and 0.4 or 0
	self.Button.Active = not blocked
end

function Keybind:Destroy()
	self.Maid:DoCleaning()
end

return Keybind
