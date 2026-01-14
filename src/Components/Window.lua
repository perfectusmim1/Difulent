-- Phantasm Window (UI-first remake)
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")

local Maid = require(script.Parent.Parent.Utils.Maid)
local Creator = require(script.Parent.Parent.Creator)
local ThemeManager = require(script.Parent.Parent.ThemeManager)
local Utility = require(script.Parent.Parent.Utils.Utility)
local Signal = require(script.Parent.Parent.Utils.Signal)
local ConfigManager = require(script.Parent.Parent.ConfigManager)
local Tab = require(script.Parent.Tab)

local Window = {}
Window.__index = Window

local WINDOW_ID = 0
local function nextWindowId()
	WINDOW_ID = WINDOW_ID + 1
	return WINDOW_ID
end

local sharedBlur
local blurUsers = 0

local function tryGetHui()
	local ok, result = pcall(function()
		if typeof(gethui) == "function" then
			return gethui()
		end
		return nil
	end)
	if ok and typeof(result) == "Instance" then
		return result
	end
	return nil
end

local function getDefaultGuiParent()
	local hui = tryGetHui()
	if hui then
		return hui
	end
	local player = Players.LocalPlayer
	if player then
		return player:WaitForChild("PlayerGui")
	end
	return game:GetService("CoreGui")
end

local function getViewportSize()
	local camera = workspace.CurrentCamera
	if camera then
		return camera.ViewportSize
	end
	return Vector2.new(1920, 1080)
end

local function udim2ToOffset(size, fallback)
	if size.X.Scale ~= 0 or size.Y.Scale ~= 0 then
		return fallback
	end
	return Vector2.new(size.X.Offset, size.Y.Offset)
end

function Window.new(options)
	local self = setmetatable({}, Window)
	options = options or {}

	self.Id = nextWindowId()
	self.Maid = Maid.new()
	self.Options = options

	self.Title = options.Title or "Phantasm"
	self.SubTitle = options.SubTitle or options.Author or ""
	self.SidebarWidth = options.SideBarWidth or options.TabWidth or 210

	self.Size = options.Size or UDim2.fromOffset(640, 460)
	self.MinSize = options.MinSize or UDim2.fromOffset(520, 360)
	self.MaxSize = options.MaxSize or UDim2.fromOffset(1040, 760)

	self.Enabled = true
	self.Minimized = false
	self.Tabs = {}
	self.ActiveTab = nil
	self.Elements = {}
	self.Flags = {}
	self.ToggleKey = options.ToggleKey or Enum.KeyCode.RightShift

	self.DialogMaid = nil
	self.PopupMaid = nil
	self.ActiveDialog = nil
	self.ActivePopup = nil

	self.ConfigOptions = options.Configs or {}
	self.ConfigsEnabled = options.Configs ~= nil and self.ConfigOptions.Enabled ~= false
	self.AutoSave = self.ConfigsEnabled and self.ConfigOptions.AutoSave == true
	self.AutoSaveName = self.ConfigOptions.Name or "autosave"
	self.AutoSaveDebounce = tonumber(self.ConfigOptions.DebounceSeconds) or 1.25
	self._autoSavePending = false

	self.ConfigManager = ConfigManager.new(options.Folder or ("Phantasm_" .. tostring(self.Id)), self.Flags)

	self.OnOpen = Signal.new()
	self.OnClose = Signal.new()
	self.OnDestroy = Signal.new()

	if options.Theme then
		ThemeManager:SetTheme(options.Theme)
	end

	self:_buildUI()
	self:_hookInput()

	return self
end

function Window:_registerElement(element)
	table.insert(self.Elements, element)
	if element and element.Flag and self.ConfigManager and type(self.ConfigManager.Register) == "function" then
		self.ConfigManager:Register(element.Flag, element)
	end
	return element
end

function Window:_queueAutoSave()
	if not (self.ConfigsEnabled and self.AutoSave) then
		return
	end
	if self._autoSavePending then
		return
	end
	self._autoSavePending = true
	task.delay(self.AutoSaveDebounce, function()
		self._autoSavePending = false
		self.ConfigManager:Save(self.AutoSaveName)
	end)
end

function Window:_flagChanged()
	self:_queueAutoSave()
end

function Window:_closeDialog()
	if self.DialogMaid then
		self.DialogMaid:DoCleaning()
		self.DialogMaid = nil
	end
	if self.ActiveDialog then
		pcall(function()
			self.ActiveDialog:Destroy()
		end)
		self.ActiveDialog = nil
	end
end

function Window:_closePopup()
	if self.PopupMaid then
		self.PopupMaid:DoCleaning()
		self.PopupMaid = nil
	end
	if self.ActivePopup then
		pcall(function()
			self.ActivePopup:Destroy()
		end)
		self.ActivePopup = nil
	end
end

function Window:_buildUI()
	local material = tostring(self.Options.Material or (self.Options.Transparent and "Transparent" or "Opaque"))
	material = string.lower(material)
	if material == "solid" then
		material = "opaque"
	end

	local baseTransparency = 0
	if material == "transparent" then
		baseTransparency = 0.18
	elseif material == "acrylic" then
		baseTransparency = 0.12
	end

	-- Global blur (Acrylic)
	if material == "acrylic" then
		blurUsers = blurUsers + 1
		if not sharedBlur then
			sharedBlur = Instance.new("BlurEffect")
			sharedBlur.Name = "PhantasmAcrylicBlur"
			sharedBlur.Size = 18
			sharedBlur.Parent = Lighting
		end
		self.Maid:GiveTask(function()
			blurUsers = blurUsers - 1
			if blurUsers <= 0 and sharedBlur then
				sharedBlur:Destroy()
				sharedBlur = nil
				blurUsers = 0
			end
		end)
	end

	local parent = getDefaultGuiParent()
	self.Gui = Instance.new("ScreenGui")
	self.Gui.Name = "Phantasm_" .. tostring(self.Id)
	self.Gui.IgnoreGuiInset = true
	self.Gui.ResetOnSpawn = false
	self.Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	self.Gui.Parent = parent
	self.Maid:GiveTask(self.Gui)

	-- Shadow (must not be clipped)
	self.Shadow = Instance.new("ImageLabel")
	self.Shadow.Name = "Shadow"
	self.Shadow.AnchorPoint = Vector2.new(0.5, 0.5)
	self.Shadow.Position = UDim2.fromScale(0.5, 0.5)
	self.Shadow.BackgroundTransparency = 1
	self.Shadow.Image = "rbxassetid://6015897843"
	self.Shadow.ImageTransparency = 0.55
	self.Shadow.ImageColor3 = Color3.new(0, 0, 0)
	self.Shadow.ScaleType = Enum.ScaleType.Slice
	self.Shadow.SliceCenter = Rect.new(49, 49, 450, 450)
	self.Shadow.SliceScale = 1
	self.Shadow.ZIndex = 1
	self.Shadow.Parent = self.Gui
	self.Maid:GiveTask(self.Shadow)

	-- Main frame
	self.Main = Creator.New("Frame", {
		Name = "Main",
		Parent = self.Gui,
		Size = self.Size,
		Position = UDim2.fromScale(0.5, 0.5),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = "Background",
		BackgroundTransparency = baseTransparency,
		ThemeTag = { BackgroundColor3 = "Background" },
		ClipsDescendants = true,
		ZIndex = 2,
	})
	Creator.AddCorner(self.Main, 12)
	Creator.AddStroke(self.Main, {
		Color = "Outline",
		Thickness = 1,
		Transparency = 0.7,
		ThemeTag = { Color = "Outline" },
	})

	-- Background image (optional)
	if type(self.Options.Background) == "string" and self.Options.Background ~= "" then
		local bg = Instance.new("ImageLabel")
		bg.Name = "Background"
		bg.BackgroundTransparency = 1
		bg.Size = UDim2.fromScale(1, 1)
		bg.Image = self.Options.Background
		bg.ImageTransparency = self.Options.BackgroundImageTransparency or 0.6
		bg.ScaleType = Enum.ScaleType.Crop
		bg.ZIndex = 2
		bg.Parent = self.Main
		self.Maid:GiveTask(bg)
	end

	-- Acrylic layering (noise + soft gradient)
	if material == "acrylic" then
		local tint = Instance.new("Frame")
		tint.Name = "AcrylicTint"
		tint.BackgroundColor3 = ThemeManager:GetColor("Surface")
		ThemeManager:Bind(tint, { BackgroundColor3 = "Surface" })
		tint.BackgroundTransparency = 0.35
		tint.BorderSizePixel = 0
		tint.Size = UDim2.fromScale(1, 1)
		tint.ZIndex = 3
		tint.Parent = self.Main
		self.Maid:GiveTask(tint)

		local grad = Instance.new("UIGradient")
		grad.Rotation = 90
		grad.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.05),
			NumberSequenceKeypoint.new(1, 0.35),
		})
		grad.Parent = tint
		self.Maid:GiveTask(grad)

		local noise = Instance.new("ImageLabel")
		noise.Name = "Noise"
		noise.BackgroundTransparency = 1
		noise.Size = UDim2.fromScale(1, 1)
		noise.Image = "rbxassetid://12975764033"
		noise.ImageTransparency = 0.92
		local ok, resampleEnum = pcall(function()
			return Enum.ResampleMode
		end)
		if ok and resampleEnum then
			noise.ResampleMode = resampleEnum.Tile
		end
		noise.ScaleType = Enum.ScaleType.Tile
		noise.TileSize = UDim2.fromOffset(128, 128)
		noise.ZIndex = 4
		noise.Parent = self.Main
		self.Maid:GiveTask(noise)
	end

	-- Topbar
	local TOPBAR_H = 46
	self.Topbar = Creator.New("Frame", {
		Name = "Topbar",
		Parent = self.Main,
		Size = UDim2.new(1, 0, 0, TOPBAR_H),
		BackgroundColor3 = "Surface",
		BackgroundTransparency = material == "opaque" and 0 or 0.15,
		BorderSizePixel = 0,
		ZIndex = 10,
		ThemeTag = { BackgroundColor3 = "Surface" },
	})

	local topSep = Creator.New("Frame", {
		Name = "TopbarSeparator",
		Parent = self.Topbar,
		Size = UDim2.new(1, 0, 0, 1),
		Position = UDim2.new(0, 0, 1, -1),
		BackgroundColor3 = "Outline",
		BackgroundTransparency = 0.7,
		BorderSizePixel = 0,
		ZIndex = 11,
		ThemeTag = { BackgroundColor3 = "Outline" },
	})

	local left = Instance.new("Frame")
	left.Name = "Left"
	left.BackgroundTransparency = 1
	left.Size = UDim2.new(1, -140, 1, 0)
	left.Position = UDim2.fromOffset(14, 0)
	left.ZIndex = 11
	left.Parent = self.Topbar
	self.Maid:GiveTask(left)

	if self.Options.Icon then
		local icon = Creator.New("ImageLabel", {
			Parent = left,
			Size = UDim2.fromOffset(18, 18),
			Position = UDim2.new(0, 0, 0.5, -9),
			BackgroundTransparency = 1,
			Image = Utility.GetIcon(self.Options.Icon),
			ImageColor3 = "Icon",
			ZIndex = 12,
			ThemeTag = { ImageColor3 = "Icon" },
		})
		self.TopbarIcon = icon
	end

	local titleX = self.Options.Icon and 26 or 0
	self.TopbarTitle = Creator.New("TextLabel", {
		Parent = left,
		Size = UDim2.new(1, 0, 0, 18),
		Position = UDim2.new(0, titleX, 0.5, self.SubTitle ~= "" and -14 or -9),
		BackgroundTransparency = 1,
		Text = self.Title,
		Font = Enum.Font.GothamBold,
		TextSize = 14,
		TextColor3 = "Text",
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Center,
		ZIndex = 12,
		ThemeTag = { TextColor3 = "Text" },
	})

	if self.SubTitle ~= "" then
		self.TopbarSubTitle = Creator.New("TextLabel", {
			Parent = left,
			Size = UDim2.new(1, 0, 0, 14),
			Position = UDim2.new(0, titleX, 0.5, 2),
			BackgroundTransparency = 1,
			Text = self.SubTitle,
			Font = Enum.Font.Gotham,
			TextSize = 12,
			TextColor3 = "SubText",
			TextTransparency = 0.1,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Center,
			ZIndex = 12,
			ThemeTag = { TextColor3 = "SubText" },
		})
	end

	local function makeIconButton(iconName)
		local btn = Creator.New("TextButton", {
			Parent = self.Topbar,
			Size = UDim2.fromOffset(30, 30),
			BackgroundColor3 = "Surface2",
			BackgroundTransparency = 1,
			Text = "",
			AutoButtonColor = false,
			ZIndex = 12,
			ThemeTag = { BackgroundColor3 = "Surface2" },
		})
		Creator.AddCorner(btn, 8)

		local img = Creator.New("ImageLabel", {
			Parent = btn,
			Size = UDim2.fromOffset(16, 16),
			Position = UDim2.new(0.5, -8, 0.5, -8),
			BackgroundTransparency = 1,
			Image = Utility.GetIcon(iconName),
			ImageColor3 = "Icon",
			ZIndex = 13,
			ThemeTag = { ImageColor3 = "Icon" },
		})

		self.Maid:GiveTask(btn.MouseEnter:Connect(function()
			Utility.Tween(btn, TweenInfo.new(0.12, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { BackgroundTransparency = 0.35 })
		end))
		self.Maid:GiveTask(btn.MouseLeave:Connect(function()
			Utility.Tween(btn, TweenInfo.new(0.12, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { BackgroundTransparency = 1 })
		end))

		return btn, img
	end

	local closeBtn = makeIconButton("x")
	closeBtn.Position = UDim2.new(1, -12 - 30, 0.5, -15)
	self.Maid:GiveTask(closeBtn.MouseButton1Click:Connect(function()
		self:Destroy()
	end))

	local minBtn = makeIconButton("minus")
	minBtn.Position = UDim2.new(1, -12 - 30 - 30 - 8, 0.5, -15)
	self.Maid:GiveTask(minBtn.MouseButton1Click:Connect(function()
		self:SetMinimized(not self.Minimized)
	end))

	-- Sidebar
	self.Sidebar = Creator.New("Frame", {
		Name = "Sidebar",
		Parent = self.Main,
		Size = UDim2.new(0, self.SidebarWidth, 1, -TOPBAR_H),
		Position = UDim2.fromOffset(0, TOPBAR_H),
		BackgroundColor3 = "Surface",
		BackgroundTransparency = material == "opaque" and 0 or 0.12,
		BorderSizePixel = 0,
		ZIndex = 10,
		ThemeTag = { BackgroundColor3 = "Surface" },
	})

	Creator.New("Frame", {
		Name = "SidebarSeparator",
		Parent = self.Sidebar,
		Size = UDim2.new(0, 1, 1, 0),
		Position = UDim2.new(1, -1, 0, 0),
		BackgroundColor3 = "Outline",
		BackgroundTransparency = 0.7,
		BorderSizePixel = 0,
		ZIndex = 11,
		ThemeTag = { BackgroundColor3 = "Outline" },
	})

	local sidebarTop = 12
	if not self.Options.HideSearchBar then
		self.SearchBoxFrame = Creator.New("Frame", {
			Name = "Search",
			Parent = self.Sidebar,
			Size = UDim2.new(1, -24, 0, 34),
			Position = UDim2.fromOffset(12, 12),
			BackgroundColor3 = "Surface2",
			BackgroundTransparency = 0.25,
			BorderSizePixel = 0,
			ZIndex = 12,
			ThemeTag = { BackgroundColor3 = "Surface2" },
		})
		Creator.AddCorner(self.SearchBoxFrame, 10)
		Creator.AddStroke(self.SearchBoxFrame, {
			Color = "Outline",
			Thickness = 1,
			Transparency = 0.75,
			ThemeTag = { Color = "Outline" },
		})

		local searchIcon = Creator.New("ImageLabel", {
			Parent = self.SearchBoxFrame,
			Size = UDim2.fromOffset(16, 16),
			Position = UDim2.fromOffset(10, 9),
			BackgroundTransparency = 1,
			Image = Utility.GetIcon("search"),
			ImageColor3 = "Icon",
			ZIndex = 13,
			ThemeTag = { ImageColor3 = "Icon" },
		})

		self.SearchBox = Creator.New("TextBox", {
			Parent = self.SearchBoxFrame,
			Size = UDim2.new(1, -36, 1, 0),
			Position = UDim2.fromOffset(30, 0),
			BackgroundTransparency = 1,
			Text = "",
			PlaceholderText = "Search",
			Font = Enum.Font.Gotham,
			TextSize = 13,
			TextColor3 = "Text",
			PlaceholderColor3 = "Placeholder",
			TextXAlignment = Enum.TextXAlignment.Left,
			ClearTextOnFocus = false,
			ZIndex = 13,
			ThemeTag = { TextColor3 = "Text", PlaceholderColor3 = "Placeholder" },
		})

		self.Maid:GiveTask(self.SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
			self:_applyTabFilter(self.SearchBox.Text)
		end))

		sidebarTop = 12 + 34 + 10
	end

	self.SidebarList = Creator.New("ScrollingFrame", {
		Name = "Tabs",
		Parent = self.Sidebar,
		Size = UDim2.new(1, 0, 1, -sidebarTop),
		Position = UDim2.fromOffset(0, sidebarTop),
		BackgroundTransparency = 1,
		ScrollBarThickness = (self.Options.ScrollBarEnabled == false) and 0 or 3,
		CanvasSize = UDim2.new(0, 0, 0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ZIndex = 11,
	})
	Creator.AddPadding(self.SidebarList, 10)

	local tabsLayout = Instance.new("UIListLayout")
	tabsLayout.SortOrder = Enum.SortOrder.LayoutOrder
	tabsLayout.Padding = UDim.new(0, 6)
	tabsLayout.Parent = self.SidebarList
	self.Maid:GiveTask(tabsLayout)

	-- Content
	self.Content = Creator.New("Frame", {
		Name = "Content",
		Parent = self.Main,
		Size = UDim2.new(1, -self.SidebarWidth, 1, -TOPBAR_H),
		Position = UDim2.fromOffset(self.SidebarWidth, TOPBAR_H),
		BackgroundTransparency = 1,
		ZIndex = 10,
	})

	-- Notifications container
	self.NotifyHolder = Instance.new("Frame")
	self.NotifyHolder.Name = "Notifications"
	self.NotifyHolder.BackgroundTransparency = 1
	self.NotifyHolder.Size = UDim2.new(0, 320, 1, -20)
	self.NotifyHolder.Position = UDim2.new(1, -340, 0, 10)
	self.NotifyHolder.ZIndex = 200
	self.NotifyHolder.Parent = self.Gui
	self.Maid:GiveTask(self.NotifyHolder)

	local notifyList = Instance.new("UIListLayout")
	notifyList.VerticalAlignment = Enum.VerticalAlignment.Bottom
	notifyList.HorizontalAlignment = Enum.HorizontalAlignment.Right
	notifyList.Padding = UDim.new(0, 8)
	notifyList.Parent = self.NotifyHolder
	self.Maid:GiveTask(notifyList)

	-- Resize grip
	local resizable = self.Options.Resize == true or self.Options.Resizable == true or self.Options.Resizeable == true
	if resizable then
		self:_enableResizeGrip()
	end

	self:_syncShadow()
	self.Maid:GiveTask(self.Main:GetPropertyChangedSignal("Size"):Connect(function()
		self:_syncShadow()
	end))
	self.Maid:GiveTask(self.Main:GetPropertyChangedSignal("Position"):Connect(function()
		self:_syncShadow()
	end))
end

function Window:_syncShadow()
	if not (self.Shadow and self.Main) then
		return
	end
	self.Shadow.Position = self.Main.Position

	local absSize = self.Main.AbsoluteSize
	self.Shadow.Size = UDim2.fromOffset(absSize.X + 70, absSize.Y + 70)
end

function Window:_hookInput()
	-- Dragging (topbar only)
	local dragging = false
	local dragStart = nil
	local startPos = nil

	self.Maid:GiveTask(self.Topbar.InputBegan:Connect(function(input)
		if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then
			return
		end
		dragging = true
		dragStart = input.Position
		startPos = self.Main.Position

		local conn
		conn = input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
				if conn then
					conn:Disconnect()
				end
			end
		end)
		self.Maid:GiveTask(conn)
	end))

	self.Maid:GiveTask(UserInputService.InputChanged:Connect(function(input)
		if not dragging then
			return
		end
		if input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch then
			return
		end
		if not dragStart or not startPos then
			return
		end

		local delta = input.Position - dragStart
		local viewport = getViewportSize()

		local scaleX = startPos.X.Scale
		local scaleY = startPos.Y.Scale
		local baseCenter = Vector2.new(viewport.X * scaleX, viewport.Y * scaleY)
		local center = baseCenter + Vector2.new(startPos.X.Offset + delta.X, startPos.Y.Offset + delta.Y)

		local half = self.Main.AbsoluteSize * 0.5
		center = Vector2.new(
			math.clamp(center.X, half.X, viewport.X - half.X),
			math.clamp(center.Y, half.Y, viewport.Y - half.Y)
		)

		local newOffset = center - baseCenter
		self.Main.Position = UDim2.new(scaleX, newOffset.X, scaleY, newOffset.Y)
	end))

	-- Toggle key
	self.Maid:GiveTask(UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then
			return
		end
		if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == self.ToggleKey then
			self:Toggle()
		end
	end))
end

function Window:_enableResizeGrip()
	if self.ResizeMaid then
		self.ResizeMaid:DoCleaning()
	end
	self.ResizeMaid = Maid.new()

	local grip = Instance.new("ImageButton")
	grip.Name = "ResizeGrip"
	grip.AnchorPoint = Vector2.new(1, 1)
	grip.Position = UDim2.new(1, -6, 1, -6)
	grip.Size = UDim2.fromOffset(18, 18)
	grip.BackgroundTransparency = 1
	grip.Image = Utility.GetIcon("maximize-2")
	grip.ImageTransparency = 0.6
	grip.ImageColor3 = ThemeManager:GetColor("Icon")
	ThemeManager:Bind(grip, { ImageColor3 = "Icon" })
	grip.ZIndex = 50
	grip.Parent = self.Main
	self.ResizeGrip = grip
	self.ResizeMaid:GiveTask(grip)

	local resizing = false
	local startMouse = nil
	local startSize = nil

	local min = udim2ToOffset(self.MinSize, Vector2.new(520, 360))
	local max = udim2ToOffset(self.MaxSize, Vector2.new(1040, 760))

	self.ResizeMaid:GiveTask(grip.InputBegan:Connect(function(input)
		if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then
			return
		end
		resizing = true
		startMouse = input.Position
		startSize = self.Main.AbsoluteSize

		local conn
		conn = input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				resizing = false
				if conn then
					conn:Disconnect()
				end
			end
		end)
		self.ResizeMaid:GiveTask(conn)
	end))

	self.ResizeMaid:GiveTask(UserInputService.InputChanged:Connect(function(input)
		if not resizing then
			return
		end
		if input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch then
			return
		end
		if not startMouse or not startSize then
			return
		end

		local delta = input.Position - startMouse
		local newW = math.clamp(startSize.X + delta.X, min.X, max.X)
		local newH = math.clamp(startSize.Y + delta.Y, min.Y, max.Y)
		self.Main.Size = UDim2.fromOffset(newW, newH)
	end))
end

function Window:_applyTabFilter(text)
	local query = string.lower(text or "")
	for _, tab in ipairs(self.Tabs) do
		local visible = (query == "") or (string.find(string.lower(tab.Title), query, 1, true) ~= nil)
		if tab.Button then
			tab.Button.Visible = visible
		end
	end
end

function Window:AddTab(options)
	local tab = Tab.new(self, options or {})
	table.insert(self.Tabs, tab)

	if self.SearchBox then
		self:_applyTabFilter(self.SearchBox.Text)
	end

	if #self.Tabs == 1 then
		tab:Select()
	end

	return tab
end

function Window:SetMinimized(minimized)
	minimized = minimized and true or false
	if self.Minimized == minimized then
		return
	end
	self.Minimized = minimized

	if minimized then
		self._preMinimizeSize = self.Main.AbsoluteSize
		self.Sidebar.Visible = false
		self.Content.Visible = false
		self.Main.ClipsDescendants = true
		self.Main.Size = UDim2.fromOffset(self._preMinimizeSize.X, 56)
	else
		local restore = self._preMinimizeSize or self.Main.AbsoluteSize
		self.Sidebar.Visible = true
		self.Content.Visible = true
		self.Main.Size = UDim2.fromOffset(restore.X, restore.Y)
	end
end

function Window:Open()
	self.Enabled = true
	self.Gui.Enabled = true
	self.OnOpen:Fire()
end

function Window:Close()
	self.Enabled = false
	self.Gui.Enabled = false
	self.OnClose:Fire()
end

function Window:Toggle()
	if self.Enabled then
		self:Close()
	else
		self:Open()
	end
end

function Window:SetTheme(nameOrTable)
	ThemeManager:SetTheme(nameOrTable)
end

function Window:SetToggleKey(keyCode)
	self.ToggleKey = keyCode or Enum.KeyCode.RightShift
end

function Window:SetSize(size)
	if typeof(size) == "UDim2" then
		self.Main.Size = size
	end
end

function Window:SetResizable(enabled)
	enabled = enabled and true or false
	if enabled and not self.ResizeGrip then
		self:_enableResizeGrip()
	elseif not enabled and self.ResizeGrip then
		if self.ResizeMaid then
			self.ResizeMaid:DoCleaning()
			self.ResizeMaid = nil
		end
		self.ResizeGrip = nil
	end
end

function Window:SaveConfig(name)
	return self.ConfigManager:Save(name or self.AutoSaveName)
end

function Window:LoadConfig(name, silent)
	return self.ConfigManager:Load(name or self.AutoSaveName, silent)
end

function Window:ExportConfig()
	return self.ConfigManager:Export()
end

function Window:ImportConfig(json, silent)
	return self.ConfigManager:Import(json, silent)
end

function Window:CreateConfigUI(container, options)
	options = options or {}
	if not container then
		return nil
	end

	local root = container
	if type(container.AddSection) == "function" and options.Section ~= false then
		root = container:AddSection({
			Title = options.SectionTitle or "Configs",
			Collapsible = options.Collapsible ~= false,
			Opened = options.Opened ~= false,
		})
	end

	local state = {
		Name = options.DefaultName or self.AutoSaveName,
	}

	local nameInput = nil
	if type(root.AddInput) == "function" then
		nameInput = root:AddInput({
			Title = "Config Name",
			Default = state.Name,
			Placeholder = "config name",
			Callback = function(text)
				state.Name = text
			end,
		})
	end

	local configs = {}
	if self.ConfigManager and type(self.ConfigManager.GetConfigs) == "function" then
		configs = self.ConfigManager:GetConfigs()
	end

	local listDropdown = nil
	if type(root.AddDropdown) == "function" then
		listDropdown = root:AddDropdown({
			Title = "Existing Configs",
			Values = configs,
			AllowNone = true,
			Callback = function(val)
				if val and val ~= "" then
					state.Name = val
					if nameInput and type(nameInput.Set) == "function" then
						nameInput:Set(val, true)
					end
				end
			end,
		})
	end

	local function refreshList()
		if listDropdown and type(listDropdown.Refresh) == "function" then
			listDropdown:Refresh(self.ConfigManager:GetConfigs())
		end
	end

	if type(root.AddButton) == "function" then
		root:AddButton({
			Title = "Refresh List",
			Callback = function()
				refreshList()
				self:Notify({ Title = "Configs", Content = "List refreshed.", Duration = 2 })
			end,
		})

		root:AddButton({
			Title = "Save Config",
			Callback = function()
				local ok, msg = self:SaveConfig(state.Name)
				self:Notify({
					Title = ok and "Config" or "Config Error",
					Content = ok and ("Saved " .. tostring(state.Name)) or (msg or "Save failed"),
					Duration = 2,
				})
				refreshList()
			end,
		})

		root:AddButton({
			Title = "Load Config",
			Callback = function()
				local ok, msg = self:LoadConfig(state.Name, true)
				self:Notify({
					Title = ok and "Config" or "Config Error",
					Content = ok and ("Loaded " .. tostring(state.Name)) or (msg or "Load failed"),
					Duration = 2,
				})
			end,
		})

		root:AddButton({
			Title = "Export Config",
			Callback = function()
				local json = self:ExportConfig()
				local copied = false
				if type(setclipboard) == "function" then
					pcall(function()
						setclipboard(json)
						copied = true
					end)
				end

				if copied then
					self:Notify({ Title = "Config", Content = "Export copied to clipboard.", Duration = 2 })
				else
					self:Dialog({
						Title = "Export Config",
						Content = "Copy the JSON below.",
						Input = {
							Default = json,
							Multiline = true,
							ReadOnly = true,
						},
						Buttons = {
							{ Title = "Close", Primary = true },
						},
					})
				end
			end,
		})

		root:AddButton({
			Title = "Import Config",
			Callback = function()
				self:Dialog({
					Title = "Import Config",
					Content = "Paste JSON below to apply.",
					Input = {
						Default = "",
						Placeholder = "Paste config JSON",
						Multiline = true,
					},
					Buttons = {
						{
							Title = "Import",
							Primary = true,
							Callback = function(text)
								local ok, msg = self:ImportConfig(text or "", true)
								self:Notify({
									Title = ok and "Config" or "Config Error",
									Content = ok and "Imported config." or (msg or "Import failed"),
									Duration = 2,
								})
							end,
						},
						{ Title = "Cancel" },
					},
				})
			end,
		})
	end

	return {
		State = state,
		NameInput = nameInput,
		ListDropdown = listDropdown,
		Root = root,
	}
end

function Window:LockAllElements()
	for _, element in ipairs(self.Elements) do
		if type(element) == "table" and type(element.SetLocked) == "function" then
			element:SetLocked(true)
		end
	end
end

function Window:UnlockAllElements()
	for _, element in ipairs(self.Elements) do
		if type(element) == "table" and type(element.SetLocked) == "function" then
			element:SetLocked(false)
		end
	end
end

function Window:GetAllElements()
	return self.Elements
end

function Window:GetLockedElements()
	local locked = {}
	for _, element in ipairs(self.Elements) do
		if type(element) == "table" and element.Locked == true then
			table.insert(locked, element)
		end
	end
	return locked
end

function Window:GetUnlockedElements()
	local unlocked = {}
	for _, element in ipairs(self.Elements) do
		if type(element) == "table" and element.Locked ~= true then
			table.insert(unlocked, element)
		end
	end
	return unlocked
end

function Window:Dialog(options)
	options = options or {}
	self:_closeDialog()

	local maid = Maid.new()
	self.DialogMaid = maid

	local overlay = Instance.new("TextButton")
	overlay.Name = "DialogOverlay"
	overlay.AutoButtonColor = false
	overlay.Text = ""
	overlay.BackgroundColor3 = Color3.new(0, 0, 0)
	overlay.BackgroundTransparency = 0.45
	overlay.Size = UDim2.fromScale(1, 1)
	overlay.ZIndex = 400
	overlay.Parent = self.Gui
	maid:GiveTask(overlay)

	local closeOnOutside = options.CloseOnOutside ~= false
	if closeOnOutside then
		maid:GiveTask(overlay.MouseButton1Click:Connect(function()
			self:_closeDialog()
		end))
	end

	if options.CloseOnEscape ~= false then
		maid:GiveTask(UserInputService.InputBegan:Connect(function(input, gp)
			if gp then
				return
			end
			if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == Enum.KeyCode.Escape then
				self:_closeDialog()
			end
		end))
	end

	local dialog = Creator.New("Frame", {
		Parent = self.Gui,
		Size = UDim2.fromOffset(options.Width or 360, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		Position = UDim2.fromScale(0.5, 0.5),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = "Surface",
		BackgroundTransparency = 0.05,
		BorderSizePixel = 0,
		ZIndex = 401,
		ThemeTag = { BackgroundColor3 = "Surface" },
	})
	Creator.AddCorner(dialog, 14)
	Creator.AddStroke(dialog, { Color = "Outline", Thickness = 1, Transparency = 0.7, ThemeTag = { Color = "Outline" } })
	Creator.AddPadding(dialog, 16)
	maid:GiveTask(dialog)
	self.ActiveDialog = dialog

	local title = Creator.New("TextLabel", {
		Parent = dialog,
		Size = UDim2.new(1, 0, 0, 18),
		BackgroundTransparency = 1,
		Text = options.Title or "Dialog",
		Font = Enum.Font.GothamBold,
		TextSize = 15,
		TextColor3 = "Text",
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 402,
		ThemeTag = { TextColor3 = "Text" },
	})
	title.LayoutOrder = 1

	local contentText = options.Content or options.Text or ""
	local content = Creator.New("TextLabel", {
		Parent = dialog,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		Text = contentText,
		Font = Enum.Font.Gotham,
		TextSize = 13,
		TextColor3 = "SubText",
		TextXAlignment = Enum.TextXAlignment.Left,
		TextWrapped = true,
		ZIndex = 402,
		ThemeTag = { TextColor3 = "SubText" },
	})
	content.LayoutOrder = 2

	local inputBox = nil
	if type(options.Input) == "table" then
		local input = options.Input
		local height = input.Multiline and 110 or 34
		inputBox = Creator.New("TextBox", {
			Parent = dialog,
			Size = UDim2.new(1, 0, 0, height),
			BackgroundColor3 = "Surface2",
			BackgroundTransparency = 0.2,
			BorderSizePixel = 0,
			ClearTextOnFocus = false,
			Text = input.Default or "",
			PlaceholderText = input.Placeholder or "",
			Font = Enum.Font.Gotham,
			TextSize = 13,
			TextColor3 = "Text",
			PlaceholderColor3 = "Placeholder",
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = input.Multiline and Enum.TextYAlignment.Top or Enum.TextYAlignment.Center,
			TextWrapped = input.Multiline == true,
			MultiLine = input.Multiline == true,
			ZIndex = 402,
			ThemeTag = {
				BackgroundColor3 = "Surface2",
				TextColor3 = "Text",
				PlaceholderColor3 = "Placeholder",
			},
		})
		Creator.AddCorner(inputBox, 10)
		Creator.AddStroke(inputBox, { Color = "Outline", Thickness = 1, Transparency = 0.8, ThemeTag = { Color = "Outline" } })
		if input.ReadOnly == true then
			inputBox.TextEditable = false
		end
		inputBox.LayoutOrder = 3
	end

	local buttonRow = Instance.new("Frame")
	buttonRow.Name = "Buttons"
	buttonRow.BackgroundTransparency = 1
	buttonRow.Size = UDim2.new(1, 0, 0, 34)
	buttonRow.ZIndex = 402
	buttonRow.Parent = dialog
	buttonRow.LayoutOrder = 4

	local buttonLayout = Instance.new("UIListLayout")
	buttonLayout.FillDirection = Enum.FillDirection.Horizontal
	buttonLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
	buttonLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	buttonLayout.Padding = UDim.new(0, 8)
	buttonLayout.Parent = buttonRow

	local buttons = options.Buttons
	if type(buttons) ~= "table" or #buttons == 0 then
		buttons = { { Title = "OK", Primary = true } }
	end

	for _, btn in ipairs(buttons) do
		local isPrimary = btn.Primary == true
		local button = Creator.New("TextButton", {
			Parent = buttonRow,
			Size = UDim2.fromOffset(btn.Width or 90, 30),
			BackgroundColor3 = isPrimary and "Accent" or "Surface2",
			BackgroundTransparency = isPrimary and 0.05 or 0.2,
			Text = btn.Title or "Button",
			AutoButtonColor = false,
			Font = Enum.Font.GothamMedium,
			TextSize = 13,
			TextColor3 = isPrimary and "Background" or "Text",
			ZIndex = 403,
			ThemeTag = {
				BackgroundColor3 = isPrimary and "Accent" or "Surface2",
				TextColor3 = isPrimary and "Background" or "Text",
			},
		})
		Creator.AddCorner(button, 10)

		maid:GiveTask(button.MouseEnter:Connect(function()
			Utility.Tween(button, TweenInfo.new(0.12, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
				BackgroundTransparency = isPrimary and 0 or 0.1,
			})
		end))
		maid:GiveTask(button.MouseLeave:Connect(function()
			Utility.Tween(button, TweenInfo.new(0.12, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
				BackgroundTransparency = isPrimary and 0.05 or 0.2,
			})
		end))

		maid:GiveTask(button.MouseButton1Click:Connect(function()
			local value = inputBox and inputBox.Text or nil
			if type(btn.Callback) == "function" then
				btn.Callback(value)
			end
			if btn.Close ~= false then
				self:_closeDialog()
			end
		end))
	end

	local layout = Instance.new("UIListLayout")
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Padding = UDim.new(0, 10)
	layout.Parent = dialog

	return {
		Close = function()
			self:_closeDialog()
		end,
		Dialog = dialog,
		Input = inputBox,
	}
end

function Window:Popup(options)
	options = options or {}
	self:_closePopup()

	local maid = Maid.new()
	self.PopupMaid = maid

	local main = self.Main
	local overlay = Instance.new("TextButton")
	overlay.Name = "PopupOverlay"
	overlay.AutoButtonColor = false
	overlay.Text = ""
	overlay.BackgroundTransparency = 1
	overlay.Size = UDim2.fromScale(1, 1)
	overlay.ZIndex = 350
	overlay.Parent = main
	maid:GiveTask(overlay)

	maid:GiveTask(overlay.MouseButton1Click:Connect(function()
		self:_closePopup()
	end))

	local frame = Creator.New("Frame", {
		Parent = main,
		Size = UDim2.fromOffset(options.Width or 200, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundColor3 = "Surface",
		BackgroundTransparency = 0.05,
		BorderSizePixel = 0,
		ZIndex = 360,
		ThemeTag = { BackgroundColor3 = "Surface" },
	})
	Creator.AddCorner(frame, 12)
	Creator.AddStroke(frame, { Color = "Outline", Thickness = 1, Transparency = 0.7, ThemeTag = { Color = "Outline" } })
	Creator.AddPadding(frame, 8)
	self.ActivePopup = frame
	maid:GiveTask(frame)

	local list = Instance.new("UIListLayout")
	list.SortOrder = Enum.SortOrder.LayoutOrder
	list.Padding = UDim.new(0, 4)
	list.Parent = frame

	local function anchorPosition()
		if typeof(options.Position) == "Vector2" then
			return options.Position
		end
		if typeof(options.Position) == "UDim2" then
			return main.AbsolutePosition + Vector2.new(options.Position.X.Offset, options.Position.Y.Offset)
		end
		local target = options.Target or options.Anchor
		if typeof(target) == "Instance" and target:IsA("GuiObject") then
			return target.AbsolutePosition + Vector2.new(0, target.AbsoluteSize.Y + 6)
		end
		local mousePos = UserInputService:GetMouseLocation()
		return Vector2.new(mousePos.X, mousePos.Y)
	end

	local function clampPosition()
		local pos = anchorPosition()
		local mainPos = main.AbsolutePosition
		local rel = pos - mainPos
		local size = frame.AbsoluteSize
		local maxX = main.AbsoluteSize.X - size.X - 8
		local maxY = main.AbsoluteSize.Y - size.Y - 8
		local x = math.clamp(rel.X, 8, math.max(8, maxX))
		local y = math.clamp(rel.Y, 8, math.max(8, maxY))
		frame.Position = UDim2.fromOffset(x, y)
	end

	maid:GiveTask(list:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		clampPosition()
	end))

	local items = options.Items or {}
	for _, item in ipairs(items) do
		if item.Separator then
			local sep = Creator.New("Frame", {
				Parent = frame,
				Size = UDim2.new(1, -8, 0, 1),
				BackgroundColor3 = "Outline",
				BackgroundTransparency = 0.7,
				BorderSizePixel = 0,
				ZIndex = 361,
				ThemeTag = { BackgroundColor3 = "Outline" },
			})
		else
			local disabled = item.Disabled == true
			local row = Creator.New("TextButton", {
				Parent = frame,
				Size = UDim2.new(1, 0, 0, 30),
				BackgroundColor3 = "Surface2",
				BackgroundTransparency = 1,
				Text = "",
				AutoButtonColor = false,
				ZIndex = 361,
				ThemeTag = { BackgroundColor3 = "Surface2" },
			})
			Creator.AddCorner(row, 8)

			local icon = nil
			local leftPad = 10
			if item.Icon then
				icon = Creator.New("ImageLabel", {
					Parent = row,
					Size = UDim2.fromOffset(16, 16),
					Position = UDim2.new(0, 8, 0.5, -8),
					BackgroundTransparency = 1,
					Image = Utility.GetIcon(item.Icon),
					ImageColor3 = "Icon",
					ZIndex = 362,
					ThemeTag = { ImageColor3 = "Icon" },
				})
				leftPad = 30
			end

			local label = Creator.New("TextLabel", {
				Parent = row,
				Size = UDim2.new(1, -40, 1, 0),
				Position = UDim2.fromOffset(leftPad, 0),
				BackgroundTransparency = 1,
				Text = item.Title or "Item",
				Font = Enum.Font.Gotham,
				TextSize = 13,
				TextColor3 = "Text",
				TextXAlignment = Enum.TextXAlignment.Left,
				ZIndex = 362,
				ThemeTag = { TextColor3 = "Text" },
			})

			local check = Creator.New("ImageLabel", {
				Parent = row,
				Size = UDim2.fromOffset(16, 16),
				Position = UDim2.new(1, -22, 0.5, -8),
				BackgroundTransparency = 1,
				Image = Utility.GetIcon("check"),
				ImageColor3 = "Accent",
				Visible = item.Checked == true,
				ZIndex = 362,
				ThemeTag = { ImageColor3 = "Accent" },
			})

			if disabled then
				label.TextTransparency = 0.4
				if icon then
					icon.ImageTransparency = 0.4
				end
				check.ImageTransparency = 0.4
			end

			maid:GiveTask(row.MouseEnter:Connect(function()
				if disabled then
					return
				end
				Utility.Tween(row, TweenInfo.new(0.1, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { BackgroundTransparency = 0.5 })
			end))
			maid:GiveTask(row.MouseLeave:Connect(function()
				if disabled then
					return
				end
				Utility.Tween(row, TweenInfo.new(0.1, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { BackgroundTransparency = 1 })
			end))

			maid:GiveTask(row.MouseButton1Click:Connect(function()
				if disabled then
					return
				end
				local keepOpen = item.KeepOpen == true
				if item.Toggle then
					item.Checked = not item.Checked
					check.Visible = item.Checked == true
					keepOpen = item.KeepOpen ~= false
				end
				if type(item.Callback) == "function" then
					item.Callback(item.Checked, item)
				end
				if not keepOpen then
					self:_closePopup()
				end
			end))
		end
	end

	task.defer(function()
		clampPosition()
	end)

	return {
		Close = function()
			self:_closePopup()
		end,
		Popup = frame,
	}
end

function Window:Notify(options)
	options = options or {}

	local toast = Creator.New("Frame", {
		Parent = self.NotifyHolder,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundColor3 = "Surface",
		BackgroundTransparency = 0.08,
		BorderSizePixel = 0,
		ZIndex = 201,
		ThemeTag = { BackgroundColor3 = "Surface" },
	})
	Creator.AddCorner(toast, 12)
	Creator.AddStroke(toast, { Color = "Outline", Thickness = 1, Transparency = 0.7, ThemeTag = { Color = "Outline" } })
	Creator.AddPadding(toast, 12)

	local title = Creator.New("TextLabel", {
		Parent = toast,
		Size = UDim2.new(1, 0, 0, 18),
		BackgroundTransparency = 1,
		Text = options.Title or "Notification",
		Font = Enum.Font.GothamBold,
		TextSize = 14,
		TextColor3 = "Text",
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 202,
		ThemeTag = { TextColor3 = "Text" },
	})

	local body = Creator.New("TextLabel", {
		Parent = toast,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		Text = options.Content or "",
		Font = Enum.Font.Gotham,
		TextSize = 12,
		TextColor3 = "SubText",
		TextTransparency = 0.05,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextWrapped = true,
		ZIndex = 202,
		ThemeTag = { TextColor3 = "SubText" },
	})

	local layout = Instance.new("UIListLayout")
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Padding = UDim.new(0, 6)
	layout.Parent = toast

	toast.BackgroundTransparency = 1
	title.TextTransparency = 1
	body.TextTransparency = 1

	Utility.Tween(toast, TweenInfo.new(0.18, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { BackgroundTransparency = 0.08 })
	Utility.Tween(title, TweenInfo.new(0.18, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { TextTransparency = 0 })
	Utility.Tween(body, TweenInfo.new(0.18, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { TextTransparency = 0.05 })

	task.delay(options.Duration or 3, function()
		if not toast.Parent then
			return
		end
		Utility.Tween(toast, TweenInfo.new(0.18, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { BackgroundTransparency = 1 })
		Utility.Tween(title, TweenInfo.new(0.18, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { TextTransparency = 1 })
		Utility.Tween(body, TweenInfo.new(0.18, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { TextTransparency = 1 }, function()
			if toast then
				toast:Destroy()
			end
		end)
	end)
end

function Window:Destroy()
	for _, element in ipairs(self.Elements) do
		if type(element) == "table" and type(element.Destroy) == "function" then
			pcall(function()
				element:Destroy()
			end)
		end
	end
	for _, tab in ipairs(self.Tabs) do
		if type(tab) == "table" and type(tab.Destroy) == "function" then
			pcall(function()
				tab:Destroy()
			end)
		end
	end

	self:_closeDialog()
	self:_closePopup()

	if self.ResizeMaid then
		self.ResizeMaid:DoCleaning()
		self.ResizeMaid = nil
	end

	self.OnDestroy:Fire()
	self.OnOpen:Destroy()
	self.OnClose:Destroy()
	self.OnDestroy:Destroy()
	self.Maid:DoCleaning()
end

return Window
