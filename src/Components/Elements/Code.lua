-- Phantasm Code Block
local Creator = require(script.Parent.Parent.Parent.Creator)
local Utility = require(script.Parent.Parent.Parent.Utils.Utility)
local Maid = require(script.Parent.Parent.Parent.Utils.Maid)

local Code = {}
Code.__index = Code

function Code.new(container, options, window)
	local self = setmetatable({}, Code)
	options = options or {}

	self.Maid = Maid.new()
	self.Window = window
	self.Options = options

	self.Code = tostring(options.Code or options.Content or "")
	self._baseTransparency = 0.12

	local hasTitle = type(options.Title) == "string" and options.Title ~= ""
	local title = hasTitle and options.Title or "Code"

	self.Frame = Creator.New("Frame", {
		Parent = container,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
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

	local header = Instance.new("Frame")
	header.BackgroundTransparency = 1
	header.Size = UDim2.new(1, 0, 0, 18)
	header.Parent = self.Frame
	self.Maid:GiveTask(header)

	self.TitleLabel = Creator.New("TextLabel", {
		Parent = header,
		Size = UDim2.new(1, -40, 1, 0),
		BackgroundTransparency = 1,
		Text = title,
		Font = Enum.Font.GothamSemibold,
		TextSize = 13,
		TextColor3 = "Text",
		TextXAlignment = Enum.TextXAlignment.Left,
		ThemeTag = { TextColor3 = "Text" },
	})

	self.CopyButton = Creator.New("TextButton", {
		Parent = header,
		Size = UDim2.fromOffset(30, 18),
		Position = UDim2.new(1, -30, 0, 0),
		BackgroundColor3 = "Surface2",
		BackgroundTransparency = 0.85,
		Text = "",
		AutoButtonColor = false,
		ThemeTag = { BackgroundColor3 = "Surface2" },
	})
	Creator.AddCorner(self.CopyButton, 8)

	self.CopyIcon = Creator.New("ImageLabel", {
		Parent = self.CopyButton,
		Size = UDim2.fromOffset(14, 14),
		Position = UDim2.new(0.5, -7, 0.5, -7),
		BackgroundTransparency = 1,
		Image = Utility.GetIcon("copy"),
		ImageColor3 = "Icon",
		ThemeTag = { ImageColor3 = "Icon" },
	})

	self.Maid:GiveTask(self.CopyButton.MouseEnter:Connect(function()
		Utility.Tween(self.CopyButton, TweenInfo.new(0.12, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
			BackgroundTransparency = 0.6,
		})
	end))
	self.Maid:GiveTask(self.CopyButton.MouseLeave:Connect(function()
		Utility.Tween(self.CopyButton, TweenInfo.new(0.12, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
			BackgroundTransparency = 0.85,
		})
	end))

	self.CodeBox = Creator.New("TextBox", {
		Parent = self.Frame,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundColor3 = "Surface2",
		BackgroundTransparency = 0.3,
		BorderSizePixel = 0,
		ClearTextOnFocus = false,
		Text = self.Code,
		Font = Enum.Font.Code,
		TextSize = 13,
		TextColor3 = "Text",
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
		TextWrapped = true,
		MultiLine = true,
		TextEditable = false,
		ThemeTag = { BackgroundColor3 = "Surface2", TextColor3 = "Text" },
	})
	Creator.AddCorner(self.CodeBox, 12)
	Creator.AddStroke(self.CodeBox, { Color = "Outline", Thickness = 1, Transparency = 0.75, ThemeTag = { Color = "Outline" } })
	Creator.AddPadding(self.CodeBox, 10)

	self.Maid:GiveTask(self.CopyButton.MouseButton1Click:Connect(function()
		local ok = false
		if type(setclipboard) == "function" then
			ok = pcall(function()
				setclipboard(self.Code)
			end)
		end
		if ok then
			if self.Window and self.Window.Notify then
				self.Window:Notify({ Title = "Code", Content = "Copied to clipboard.", Duration = 2 })
			end
			return
		end
		if self.Window and self.Window.Dialog then
			self.Window:Dialog({
				Title = "Copy Code",
				Content = "Your executor doesn't support clipboard. Select and copy manually:",
				Input = { Default = self.Code, Multiline = true, ReadOnly = true },
				Buttons = { { Title = "Close", Primary = true } },
			})
		end
	end))

	local layout = Instance.new("UIListLayout")
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Padding = UDim.new(0, 10)
	layout.Parent = self.Frame
	self.Maid:GiveTask(layout)

	return self
end

function Code:Set(code)
	self.Code = tostring(code or "")
	self.CodeBox.Text = self.Code
end

function Code:Get()
	return self.Code
end

function Code:Destroy()
	self.Maid:DoCleaning()
end

return Code

