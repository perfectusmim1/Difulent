-- Phantasm Dropdown (UI-first remake)
local Creator = require(script.Parent.Parent.Parent.Creator)
local Utility = require(script.Parent.Parent.Parent.Utils.Utility)
local ThemeManager = require(script.Parent.Parent.Parent.ThemeManager)
local Maid = require(script.Parent.Parent.Parent.Utils.Maid)

local Dropdown = {}
Dropdown.__index = Dropdown

local function orderedMultiText(values, map)
	local out = {}
	for _, v in ipairs(values) do
		if map[v] then
			table.insert(out, v)
		end
	end
	return #out > 0 and table.concat(out, ", ") or "None"
end

function Dropdown.new(container, options, window)
	local self = setmetatable({}, Dropdown)

	options = options or {}
	self.Maid = Maid.new()
	self.Window = window
	self.Options = options

	self.Values = options.Values or {}
	self.Multi = options.Multi == true
	self.AllowNone = options.AllowNone == true
	self.Callback = options.Callback or function() end
	self.Flag = options.Flag
	self.Disabled = false
	self.Locked = false
	self._baseTransparency = 0.12

	if self.Multi then
		self.Value = options.Default or {}
	else
		self.Value = options.Default or (self.Values[1] or "")
	end

	if self.Flag and self.Window then
		self.Window.Flags[self.Flag] = self.Value
	end

	self.Frame = Creator.New("Frame", {
		Parent = container,
		Size = UDim2.new(1, 0, 0, 68),
		BackgroundColor3 = "Surface",
		BackgroundTransparency = 0.5,
		BorderSizePixel = 0,
		ThemeTag = { BackgroundColor3 = "Surface" },
	})
	Creator.AddCorner(self.Frame, 10)
	self.Stroke = Creator.AddStroke(self.Frame, { Color = "Outline", Thickness = 1, Transparency = 0.8, ThemeTag = { Color = "Outline" } })
	Creator.AddPadding(self.Frame, 12)
	Utility.AddGradient(self.Frame, "Surface2", "Surface", NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.45),
		NumberSequenceKeypoint.new(1, 0.55),
	}))
	self.Maid:GiveTask(self.Frame)

	self.TitleLabel = Creator.New("TextLabel", {
		Parent = self.Frame,
		Size = UDim2.new(1, 0, 0, 18),
		BackgroundTransparency = 1,
		Text = options.Title or "Dropdown",
		Font = Enum.Font.GothamSemibold,
		TextSize = 13,
		TextColor3 = "Text",
		TextXAlignment = Enum.TextXAlignment.Left,
		ThemeTag = { TextColor3 = "Text" },
	})

	self.Display = Creator.New("TextButton", {
		Parent = self.Frame,
		Size = UDim2.new(1, 0, 0, 36),
		Position = UDim2.new(0, 0, 0, 26),
		BackgroundColor3 = "Surface2",
		BackgroundTransparency = 0.3,
		Text = "",
		AutoButtonColor = false,
		BorderSizePixel = 0,
		ThemeTag = { BackgroundColor3 = "Surface2" },
	})
	Creator.AddCorner(self.Display, 10)
	Creator.AddStroke(self.Display, { Color = "Outline", Thickness = 1, Transparency = 0.75, ThemeTag = { Color = "Outline" } })

	self.DisplayLabel = Creator.New("TextLabel", {
		Parent = self.Display,
		Size = UDim2.new(1, -34, 1, 0),
		Position = UDim2.fromOffset(12, 0),
		BackgroundTransparency = 1,
		Text = "",
		Font = Enum.Font.Gotham,
		TextSize = 13,
		TextColor3 = "SubText",
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
		ThemeTag = { TextColor3 = "SubText" },
	})

	self.Chevron = Creator.New("ImageLabel", {
		Parent = self.Display,
		Size = UDim2.fromOffset(16, 16),
		Position = UDim2.new(1, -24, 0.5, -8),
		BackgroundTransparency = 1,
		Image = Utility.GetIcon("chevron-down"),
		ImageColor3 = "Icon",
		ThemeTag = { ImageColor3 = "Icon" },
	})

	self.Opened = false
	self.Overlay = nil
	self.ListFrame = nil
	self.SearchBox = nil
	self.Scroll = nil
	self.PopupMaid = nil

	self.Maid:GiveTask(self.Display.MouseButton1Click:Connect(function()
		if self.Disabled or self.Locked then
			return
		end
		self:Toggle()
	end))

	if self.Window and self.Window.OnClose then
		self.Maid:GiveTask(self.Window.OnClose:Connect(function()
			self:Close()
		end))
	end

	if container:IsA("ScrollingFrame") then
		self.Maid:GiveTask(container:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
			self:Close()
		end))
	end

	self:UpdateDisplay(true)
	self:_syncState()
	return self
end

function Dropdown:GetText()
	if self.Multi then
		return orderedMultiText(self.Values, self.Value)
	end
	return tostring(self.Value)
end

function Dropdown:UpdateDisplay(silent)
	self.DisplayLabel.Text = self:GetText()
	if self.Flag and self.Window then
		self.Window.Flags[self.Flag] = self.Value
		if not silent and type(self.Window._flagChanged) == "function" then
			self.Window:_flagChanged(self.Flag)
		end
	end
end

function Dropdown:Toggle()
	if self.Opened then
		self:Close()
	else
		self:Open()
	end
end

function Dropdown:_buildList(filterText)
	if not self.Scroll then
		return
	end

	for _, child in ipairs(self.Scroll:GetChildren()) do
		if child:IsA("GuiObject") then
			child:Destroy()
		end
	end

	local function matches(value)
		if not filterText or filterText == "" then
			return true
		end
		return string.find(string.lower(value), string.lower(filterText), 1, true) ~= nil
	end

	for _, value in ipairs(self.Values) do
		if matches(value) then
			local row = Creator.New("TextButton", {
				Parent = self.Scroll,
				Size = UDim2.new(1, 0, 0, 32),
				BackgroundColor3 = "Surface2",
				BackgroundTransparency = 1,
				Text = "",
				AutoButtonColor = false,
				BorderSizePixel = 0,
				ZIndex = 332,
				ThemeTag = { BackgroundColor3 = "Surface2" },
			})
			Creator.AddCorner(row, 10)

			local label = Creator.New("TextLabel", {
				Parent = row,
				Size = UDim2.new(1, -44, 1, 0),
				Position = UDim2.fromOffset(12, 0),
				BackgroundTransparency = 1,
				Text = value,
				Font = Enum.Font.Gotham,
				TextSize = 13,
				TextColor3 = "SubText",
				TextXAlignment = Enum.TextXAlignment.Left,
				TextTruncate = Enum.TextTruncate.AtEnd,
				ZIndex = 333,
				ThemeTag = { TextColor3 = "SubText" },
			})

			local check = Creator.New("ImageLabel", {
				Parent = row,
				Size = UDim2.fromOffset(16, 16),
				Position = UDim2.new(1, -24, 0.5, -8),
				BackgroundTransparency = 1,
				Image = Utility.GetIcon("check"),
				ImageColor3 = "Accent",
				Visible = false,
				ZIndex = 333,
				ThemeTag = { ImageColor3 = "Accent" },
			})

			local selected = false
			if self.Multi then
				selected = self.Value[value] == true
			else
				selected = self.Value == value
			end
			if selected then
				label.TextColor3 = ThemeManager:GetColor("Text")
				ThemeManager:Bind(label, { TextColor3 = "Text" })
				check.Visible = true
			end

			row.MouseEnter:Connect(function()
				Utility.Tween(row, TweenInfo.new(0.12, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { BackgroundTransparency = 0.6 })
			end)
			row.MouseLeave:Connect(function()
				Utility.Tween(row, TweenInfo.new(0.12, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { BackgroundTransparency = 1 })
			end)

			row.MouseButton1Click:Connect(function()
				if self.Multi then
					if self.Value[value] then
						self.Value[value] = nil
					else
						self.Value[value] = true
					end
					self.Callback(self.Value)
					self:UpdateDisplay()
					self:_buildList(self.SearchBox and self.SearchBox.Text or "")
				else
					self.Value = value
					self.Callback(self.Value)
					self:UpdateDisplay()
					self:Close()
				end
			end)
		end
	end
end

function Dropdown:Open()
	if self.Disabled or self.Locked then
		return
	end
	if self.Opened then
		return
	end
	self.Opened = true

	if self.PopupMaid then
		self.PopupMaid:DoCleaning()
	end
	self.PopupMaid = Maid.new()

	Utility.Tween(self.Chevron, TweenInfo.new(0.12, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { Rotation = 180 })

	local main = self.Window and (self.Window.OverlayLayer or self.Window.Main) or self.Display

	self.Overlay = Instance.new("TextButton")
	self.Overlay.Name = "DropdownOverlay"
	self.Overlay.BackgroundTransparency = 1
	self.Overlay.Text = ""
	self.Overlay.AutoButtonColor = false
	self.Overlay.Size = UDim2.fromScale(1, 1)
	self.Overlay.ZIndex = 320
	self.Overlay.Parent = main

	self.PopupMaid:GiveTask(self.Overlay.MouseButton1Click:Connect(function()
		self:Close()
	end))

	self.ListFrame = Creator.New("Frame", {
		Parent = main,
		Size = UDim2.fromOffset(self.Display.AbsoluteSize.X, 0),
		BackgroundColor3 = "Surface",
		BackgroundTransparency = 0.06,
		BorderSizePixel = 0,
		ZIndex = 330,
		ThemeTag = { BackgroundColor3 = "Surface" },
	})
	Creator.AddCorner(self.ListFrame, 12)
	Creator.AddStroke(self.ListFrame, { Color = "Outline", Thickness = 1, Transparency = 0.6, ThemeTag = { Color = "Outline" } })
	Utility.AddGradient(self.ListFrame, "Surface2", "Surface", NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.05),
		NumberSequenceKeypoint.new(1, 0.12),
	}))

	local mainAbs = main.AbsolutePosition
	local dispAbs = self.Display.AbsolutePosition
	local relX = dispAbs.X - mainAbs.X
	local relY = dispAbs.Y - mainAbs.Y + self.Display.AbsoluteSize.Y + 8

	local maxHeight = 240
	local desired = (math.min(#self.Values, 8) * 32) + 40
	local targetHeight = math.min(desired, maxHeight)

	-- Flip upward if needed (keep list inside window bounds)
	if relY + targetHeight > main.AbsoluteSize.Y - 10 then
		relY = (dispAbs.Y - mainAbs.Y) - targetHeight - 8
	end

	self.ListFrame.Position = UDim2.fromOffset(relX, relY)

	self.SearchBox = Creator.New("TextBox", {
		Parent = self.ListFrame,
		Size = UDim2.new(1, -20, 0, 30),
		Position = UDim2.fromOffset(10, 10),
		BackgroundColor3 = "Surface2",
		BackgroundTransparency = 0.3,
		Text = "",
		PlaceholderText = "Search",
		Font = Enum.Font.Gotham,
		TextSize = 13,
		TextColor3 = "Text",
		PlaceholderColor3 = "Placeholder",
		ClearTextOnFocus = false,
		BorderSizePixel = 0,
		ZIndex = 331,
		ThemeTag = { BackgroundColor3 = "Surface2", TextColor3 = "Text", PlaceholderColor3 = "Placeholder" },
	})
	Creator.AddCorner(self.SearchBox, 10)

	self.Scroll = Creator.New("ScrollingFrame", {
		Parent = self.ListFrame,
		Size = UDim2.new(1, -20, 1, -50),
		Position = UDim2.fromOffset(10, 44),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 3,
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		CanvasSize = UDim2.new(0, 0, 0, 0),
		ZIndex = 331,
	})

	local layout = Instance.new("UIListLayout")
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Padding = UDim.new(0, 6)
	layout.Parent = self.Scroll

	self.PopupMaid:GiveTask(self.SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
		self:_buildList(self.SearchBox.Text)
	end))

	self:_buildList("")

	Utility.Tween(self.ListFrame, TweenInfo.new(0.16, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
		Size = UDim2.fromOffset(self.Display.AbsoluteSize.X, targetHeight),
	})
end

function Dropdown:Close()
	if not self.Opened then
		return
	end
	self.Opened = false

	if self.PopupMaid then
		self.PopupMaid:DoCleaning()
		self.PopupMaid = nil
	end

	Utility.Tween(self.Chevron, TweenInfo.new(0.12, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { Rotation = 0 })

	if self.Overlay then
		self.Overlay:Destroy()
		self.Overlay = nil
	end

	if self.ListFrame then
		local frame = self.ListFrame
		self.ListFrame = nil
		self.SearchBox = nil
		self.Scroll = nil
		Utility.Tween(frame, TweenInfo.new(0.14, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
			Size = UDim2.fromOffset(frame.AbsoluteSize.X, 0),
		}, function()
			if frame then
				frame:Destroy()
			end
		end)
	end
end

function Dropdown:Set(val, silent)
	if self.Multi then
		self.Value = val or {}
	else
		self.Value = val
	end
	self:UpdateDisplay(silent)
	if not silent then
		self.Callback(self.Value)
	end
end

function Dropdown:Get()
	return self.Value
end

function Dropdown:Refresh(newVals)
	self.Values = newVals or {}
	if not self.Multi then
		if not table.find(self.Values, self.Value) then
			self.Value = self.Values[1] or ""
		end
	end
	self:UpdateDisplay()
	if self.Opened then
		self:_buildList(self.SearchBox and self.SearchBox.Text or "")
	end
end

function Dropdown:SetEnabled(enabled)
	self.Disabled = not enabled
	self:_syncState()
	if self.Disabled then
		self:Close()
	end
end

function Dropdown:SetLocked(locked)
	self.Locked = locked and true or false
	self:_syncState()
	if self.Locked then
		self:Close()
	end
end

function Dropdown:_syncState()
	local blocked = self.Disabled or self.Locked
	self.Frame.BackgroundTransparency = blocked and 0.6 or self._baseTransparency
	self.Display.BackgroundTransparency = blocked and 0.5 or 0.25
	self.TitleLabel.TextTransparency = blocked and 0.4 or 0
	self.DisplayLabel.TextTransparency = blocked and 0.35 or 0
	if self.Chevron then
		self.Chevron.ImageTransparency = blocked and 0.35 or 0
	end
	self.Display.Active = not blocked
end

function Dropdown:Destroy()
	self:Close()
	self.Maid:DoCleaning()
end

return Dropdown
