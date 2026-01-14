-- Phantasm Window
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local Creator = require(script.Parent.Parent.Creator)
local ThemeManager = require(script.Parent.Parent.ThemeManager)
local Utility = require(script.Parent.Parent.Utils.Utility)
local Signal = require(script.Parent.Parent.Utils.Signal)
local ConfigManager = require(script.Parent.Parent.ConfigManager)
local Tab = require(script.Parent.Tab)

local Window = {}
Window.__index = Window

function Window.new(options)
    local self = setmetatable({}, Window)
    
    self.Options = options or {}
    self.Title = options.Title or "Phantasm"
    self.SubTitle = options.SubTitle or ""
    self.Size = options.Size or UDim2.fromOffset(580, 460)
    self.Enabled = true
    self.Tabs = {}
    self.Flags = {} 
    
    -- Setup Config Manager
    self.ConfigManager = ConfigManager.new(options.Folder or "Phantasm", self.Flags)

    -- Create GUI
    self:BuildUI()
    
    -- Register Events
    self.OnOpen = Signal.new()
    self.OnClose = Signal.new()
    
    return self
end

function Window:BuildUI()
    -- Main ScreenGui
    local target = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
    -- Try CoreGui if executor
    pcall(function()
        if gethui then target = gethui() end
    end)
    
    self.Gui = Instance.new("ScreenGui")
    self.Gui.Name = "PhantasmLibrary"
    self.Gui.Parent = target
    self.Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    self.Gui.ResetOnSpawn = false
    
    -- Main Frame
    self.Main = Creator.New("Frame", {
        Name = "Main",
        Parent = self.Gui,
        Size = self.Size,
        Position = UDim2.fromScale(0.5, 0.5),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = "Background",
        ThemeTag = {BackgroundColor3 = "Background"},
        ClipsDescendants = true
    })
    
    Creator.AddCorner(self.Main, 10)
    Creator.AddStroke(self.Main, {
        Color = "Outline",
        Thickness = 1,
        Transparency = 0.6,
        ThemeTag = {Color = "Outline"}
    })
    
    -- Shadow
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.AnchorPoint = Vector2.new(0.5, 0.5)
    shadow.Position = UDim2.fromScale(0.5, 0.5)
    shadow.Size = UDim2.new(1, 40, 1, 40)
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxassetid://6015897843" -- Soft shadow
    shadow.ImageColor3 = Color3.new(0,0,0)
    shadow.ImageTransparency = 0.5
    shadow.SliceCenter = Rect.new(49, 49, 450, 450)
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceScale = 1
    shadow.ZIndex = -1
    shadow.Parent = self.Main
    
    -- Acrylic Effect (Optional Noise overlay)
    if self.Options.Material == "Acrylic" then
        -- Simple noise texture
        local noise = Instance.new("ImageLabel")
        noise.BackgroundTransparency = 1
        noise.Size = UDim2.fromScale(1,1)
        noise.Image = "rbxassetid://12975764033" -- Noise grain
        noise.ImageTransparency = 0.92
        noise.ResampleMode = Enum.ResampleMode.Tile
        noise.Parent = self.Main
        self.Main.BackgroundTransparency = 0.1 -- Slight see-through
    end

    -- Dragging
    Utility.EnableDragging(self.Main)
    
    -- Sidebar
    self.Sidebar = Creator.New("Frame", {
        Name = "Sidebar",
        Parent = self.Main,
        Size = UDim2.new(0, 200, 1, 0),
        BackgroundColor3 = "Surface",
        ThemeTag = {BackgroundColor3 = "Surface"},
        BorderSizePixel = 0
    })
    -- Sidebar separator
    local sep = Creator.New("Frame", {
        Parent = self.Sidebar,
        Size = UDim2.new(0, 1, 1, 0),
        Position = UDim2.new(1, -1, 0, 0),
        BackgroundColor3 = "Outline",
        ThemeTag = {BackgroundColor3 = "Outline"}
    })
    
    -- Sidebar Content
    self.SidebarList = Creator.New("ScrollingFrame", {
        Parent = self.Sidebar,
        Size = UDim2.new(1, 0, 1, -50), -- Reserve top for Search/Title
        Position = UDim2.new(0, 0, 0, 50),
        BackgroundTransparency = 1,
        ScrollBarThickness = 2,
        CanvasSize = UDim2.new(0,0,0,0)
    })
    local uiList = Instance.new("UIListLayout")
    uiList.Padding = UDim.new(0, 5)
    uiList.SortOrder = Enum.SortOrder.LayoutOrder
    uiList.Parent = self.SidebarList
    Creator.AddPadding(self.SidebarList, 10)
    
    -- Window Title in Sidebar
    local titleLabel = Creator.New("TextLabel", {
        Parent = self.Sidebar,
        Size = UDim2.new(1, -20, 0, 40),
        Position = UDim2.new(0, 10, 0, 10),
        BackgroundTransparency = 1,
        Text = self.Title,
        Font = Enum.Font.GothamBold,
        TextSize = 18,
        TextColor3 = "Text",
        TextXAlignment = Enum.TextXAlignment.Left,
        ThemeTag = {TextColor3 = "Text"}
    })
    
    -- Content Area
    self.Content = Creator.New("Frame", {
        Name = "Content",
        Parent = self.Main,
        Size = UDim2.new(1, -200, 1, 0),
        Position = UDim2.new(0, 200, 0, 0),
        BackgroundTransparency = 1
    })
    
    -- Notifications Container
    self.NotifyHolder = Instance.new("Frame")
    self.NotifyHolder.Name = "Notifications"
    self.NotifyHolder.Size = UDim2.new(1, -20, 1, -20)
    self.NotifyHolder.Position = UDim2.new(0, 10, 0, 10)
    self.NotifyHolder.BackgroundTransparency = 1
    self.NotifyHolder.Parent = self.Gui
    self.NotifyHolder.ZIndex = 100
    
    local notifyList = Instance.new("UIListLayout")
    notifyList.VerticalAlignment = Enum.VerticalAlignment.Bottom
    notifyList.HorizontalAlignment = Enum.HorizontalAlignment.Right
    notifyList.Padding = UDim.new(0, 5)
    notifyList.Parent = self.NotifyHolder
    
    -- Keybind Toggle
    if self.Options.ToggleKey then
        UserInputService.InputBegan:Connect(function(input, gp)
            if not gp and input.KeyCode == self.Options.ToggleKey then
                self:Toggle()
            end
        end)
    end
end

function Window:AddTab(options)
    local tab = Tab.new(self, options)
    table.insert(self.Tabs, tab)
    
    -- Activate first tab by default
    if #self.Tabs == 1 then
        tab:Select()
    end
    
    return tab
end

function Window:Toggle()
    self.Enabled = not self.Enabled
    self.Gui.Enabled = self.Enabled
    if self.Enabled then self.OnOpen:Fire() else self.OnClose:Fire() end
end

function Window:Notify(options)
    -- Create Notification
    local notify = Creator.New("Frame", {
        Parent = self.NotifyHolder,
        Size = UDim2.new(0, 250, 0, 60),
        BackgroundColor3 = "Surface",
        ThemeTag = {BackgroundColor3 = "Surface"}
    })
    Creator.AddCorner(notify, 8)
    Creator.AddStroke(notify, {Color="Outline", ThemeTag={Color="Outline"}})
    
    local title = Creator.New("TextLabel", {
        Parent = notify,
        Position = UDim2.new(0, 10, 0, 5),
        Size = UDim2.new(1, -20, 0, 20),
        Text = options.Title or "Notification",
        Font = Enum.Font.GothamBold,
        TextSize = 14,
        TextColor3 = "Text",
        BackgroundTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Left,
        ThemeTag = {TextColor3 = "Text"}
    })
    
    local content = Creator.New("TextLabel", {
        Parent = notify,
        Position = UDim2.new(0, 10, 0, 25),
        Size = UDim2.new(1, -20, 0, 30),
        Text = options.Content or "",
        Font = Enum.Font.Gotham,
        TextSize = 12,
        TextColor3 = "SubText",
        BackgroundTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = true,
        ThemeTag = {TextColor3 = "SubText"}
    })
    
    -- Animate In
    notify.BackgroundTransparency = 1
    title.TextTransparency = 1
    content.TextTransparency = 1
    
    Utility.Tween(notify, TweenInfo.new(0.3), {BackgroundTransparency=0})
    Utility.Tween(title, TweenInfo.new(0.3), {TextTransparency=0})
    Utility.Tween(content, TweenInfo.new(0.3), {TextTransparency=0})
    
    task.delay(options.Duration or 3, function()
        Utility.Tween(notify, TweenInfo.new(0.3), {BackgroundTransparency=1})
        Utility.Tween(title, TweenInfo.new(0.3), {TextTransparency=1})
        Utility.Tween(content, TweenInfo.new(0.3), {TextTransparency=1}, function()
            notify:Destroy()
        end)
    end)
end

function Window:Destroy()
    self.Gui:Destroy()
    self.OnOpen:Destroy()
    self.OnClose:Destroy()
end

return Window
