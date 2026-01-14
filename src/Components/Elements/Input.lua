-- Phantasm Input (UI-first remake)
local Creator = require(script.Parent.Parent.Parent.Creator)
local Utility = require(script.Parent.Parent.Parent.Utils.Utility)
local Maid = require(script.Parent.Parent.Parent.Utils.Maid)

local Input = {}
Input.__index = Input

function Input.new(container, options, window)
	local self = setmetatable({}, Input)

	options = options or {}
	self.Maid = Maid.new()
	self.Window = window
	self.Options = options

	self.Value = options.Default or ""
	self.Callback = options.Callback or function() end
	self.Flag = options.Flag
	self.Numeric = options.Numeric == true
	self.Disabled = false
	self.Locked = false
	self._baseTransparency = 0.12

	if self.Flag and self.Window then
		self.Window.Flags[self.Flag] = self.Value
	end

	self.Frame = Creator.New("Frame", {
		Parent = container,
		Size = UDim2.new(1, 0, 0, 70),
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
		Size = UDim2.new(1, 0, 0, 18),
		BackgroundTransparency = 1,
		Text = options.Title or "Input",
		Font = Enum.Font.GothamSemibold,
		TextSize = 13,
		TextColor3 = "Text",
		TextXAlignment = Enum.TextXAlignment.Left,
		ThemeTag = { TextColor3 = "Text" },
	})

	self.BoxFrame = Creator.New("Frame", {
		Parent = self.Frame,
		Size = UDim2.new(1, 0, 0, 34),
		Position = UDim2.new(0, 0, 0, 26),
		BackgroundColor3 = "Surface2",
		BackgroundTransparency = 0.3,
		BorderSizePixel = 0,
		ThemeTag = { BackgroundColor3 = "Surface2" },
	})
	Creator.AddCorner(self.BoxFrame, 10)
	Creator.AddStroke(self.BoxFrame, { Color = "Outline", Thickness = 1, Transparency = 0.75, ThemeTag = { Color = "Outline" } })

	self.Box = Creator.New("TextBox", {
		Parent = self.BoxFrame,
		Size = UDim2.new(1, -22, 1, 0),
		Position = UDim2.fromOffset(12, 0),
		BackgroundTransparency = 1,
		Text = tostring(self.Value),
		PlaceholderText = options.Placeholder or "Enter text...",
		Font = Enum.Font.Gotham,
		TextSize = 13,
		TextColor3 = "Text",
		PlaceholderColor3 = "Placeholder",
		TextXAlignment = Enum.TextXAlignment.Left,
		ClearTextOnFocus = false,
		ThemeTag = { TextColor3 = "Text", PlaceholderColor3 = "Placeholder" },
	})

	self.Maid:GiveTask(self.Box.FocusLost:Connect(function(enterPressed)
		if self.Disabled or self.Locked then
			self.Box.Text = tostring(self.Value)
			return
		end
		local raw = self.Box.Text
		local val = raw

		if self.Numeric then
			local num = tonumber(raw)
			if num == nil then
				self.Box.Text = tostring(self.Value)
				return
			end
			val = num
		end

		self:Set(val)

		if type(options.Finished) == "function" and enterPressed then
			options.Finished(val)
		end
	end))

	self:_syncState()
	return self
end

function Input:Set(val, silent)
	self.Value = val
	self.Box.Text = tostring(val)

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

function Input:Get()
	return self.Value
end

function Input:SetEnabled(enabled)
	self.Disabled = not enabled
	self:_syncState()
end

function Input:SetLocked(locked)
	self.Locked = locked and true or false
	self:_syncState()
end

function Input:_syncState()
	local blocked = self.Disabled or self.Locked
	self.Frame.BackgroundTransparency = blocked and 0.6 or self._baseTransparency
	self.TitleLabel.TextTransparency = blocked and 0.4 or 0
	self.Box.TextTransparency = blocked and 0.4 or 0
	self.Box.Active = not blocked
	pcall(function()
		self.Box.TextEditable = not blocked
	end)
end

function Input:Destroy()
	self.Maid:DoCleaning()
end

return Input
