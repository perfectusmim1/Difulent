-- Phantasm Tab
local Creator = require(script.Parent.Parent.Creator)
local Utility = require(script.Parent.Parent.Utils.Utility)
local ThemeManager = require(script.Parent.Parent.ThemeManager)

local Tab = {}
Tab.__index = Tab

function Tab.new(window, options)
    local self = setmetatable({}, Tab)
    self.Window = window
    self.Title = options.Title or "Tab"
    self.Icon = options.Icon
    
    -- Create Sidebar Button
    self.Button = Creator.New("TextButton", {
        Parent = window.SidebarList,
        Size = UDim2.new(1, 0, 0, 32),
        BackgroundTransparency = 1,
        Text = "",
        Name = self.Title
    })
    Creator.AddCorner(self.Button, 6)
    
    local iconImg
    if self.Icon then
        iconImg = Creator.New("ImageLabel", {
            Parent = self.Button,
            Size = UDim2.fromOffset(20, 20),
            Position = UDim2.fromOffset(10, 6),
            BackgroundTransparency = 1,
            Image = Utility.GetIcon(self.Icon),
            ImageColor3 = "SubText",
            ThemeTag = {ImageColor3 = "SubText"}
        })
    end
    
    local textPos = self.Icon and 40 or 10
    self.Label = Creator.New("TextLabel", {
        Parent = self.Button,
        Size = UDim2.new(1, -textPos, 1, 0),
        Position = UDim2.fromOffset(textPos, 0),
        BackgroundTransparency = 1,
        Text = self.Title,
        Font = Enum.Font.GothamMedium,
        TextSize = 14,
        TextColor3 = "SubText",
        TextXAlignment = Enum.TextXAlignment.Left,
        ThemeTag = {TextColor3 = "SubText"}
    })
    
    -- Tab Container (Content)
    self.Container = Creator.New("ScrollingFrame", {
        Name = self.Title .. "Container",
        Parent = window.Content,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        ScrollBarThickness = 2,
        Visible = false
    })
    Creator.AddPadding(self.Container, 15)
    
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 10)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = self.Container
    
    -- AutoCanvasSize
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        self.Container.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 30)
    end)
    
    -- Selection Logic
    self.Button.MouseButton1Click:Connect(function()
        self:Select()
    end)
    
    return self
end

function Tab:Select()
    -- Deselect all
    for _, t in ipairs(self.Window.Tabs) do
        t.Container.Visible = false
        Utility.Tween(t.Label, TweenInfo.new(0.2), {TextColor3 = ThemeManager:GetColor("SubText")}) 
        if t.Button:FindFirstChild("ImageLabel") then
             Utility.Tween(t.Button.ImageLabel, TweenInfo.new(0.2), {ImageColor3 = ThemeManager:GetColor("SubText")})
        end
        Utility.Tween(t.Button, TweenInfo.new(0.2), {BackgroundTransparency = 1})
    end
    
    -- Select self
    self.Container.Visible = true
    Utility.Tween(self.Label, TweenInfo.new(0.2), {TextColor3 = ThemeManager:GetColor("Text")})
    if self.Button:FindFirstChild("ImageLabel") then
        Utility.Tween(self.Button.ImageLabel, TweenInfo.new(0.2), {ImageColor3 = ThemeManager:GetColor("Text")})
    end
    Utility.Tween(self.Button, TweenInfo.new(0.2), {BackgroundColor3 = ThemeManager:GetColor("Surface2"), BackgroundTransparency = 0})
end

-- Proxy Methods for Elements
-- Note: In a real module loading system, we'd require the Element modules here.
-- To ensure single-file compatibility later, we assume these exist.

function Tab:AddButton(options)
    local Button = require(script.Parent.Elements.Button)
    return Button.new(self.Container, options)
end

function Tab:AddToggle(options)
    local Toggle = require(script.Parent.Elements.Toggle)
    return Toggle.new(self.Container, options, self.Window)
end

function Tab:AddSlider(options)
    local Slider = require(script.Parent.Elements.Slider)
    return Slider.new(self.Container, options, self.Window)
end

function Tab:AddLabel(options)
    local Label = require(script.Parent.Elements.Label)
    return Label.new(self.Container, options)
end

function Tab:AddInput(options)
    local Input = require(script.Parent.Elements.Input)
    return Input.new(self.Container, options, self.Window)
end

function Tab:AddDropdown(options)
    local Dropdown = require(script.Parent.Elements.Dropdown)
    return Dropdown.new(self.Container, options, self.Window)
end

return Tab
