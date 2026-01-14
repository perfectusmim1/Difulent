-- Phantasm Toggle
local Creator = require(script.Parent.Parent.Parent.Creator)
local Utility = require(script.Parent.Parent.Parent.Utils.Utility)
local ThemeManager = require(script.Parent.Parent.Parent.ThemeManager)

local Toggle = {}
Toggle.__index = Toggle

function Toggle.new(container, options, window)
    local self = setmetatable({}, Toggle)
    
    self.Window = window
    self.Options = options
    self.Value = options.Default or false
    self.Callback = options.Callback or function() end
    self.Flag = options.Flag
    
    if self.Flag and self.Window then
        self.Window.Flags[self.Flag] = self.Value
    end
    
    -- Frame
    self.Frame = Creator.New("TextButton", {
        Parent = container,
        Size = UDim2.new(1, 0, 0, 32),
        BackgroundTransparency = 1,
        Text = "",
        AutoButtonColor = false
    })
    
    self.TitleLabel = Creator.New("TextLabel", {
        Parent = self.Frame,
        Size = UDim2.new(1, -60, 1, 0),
        Position = UDim2.fromOffset(0, 0),
        BackgroundTransparency = 1,
        Text = options.Title or "Toggle",
        Font = Enum.Font.GothamMedium,
        TextSize = 13,
        TextColor3 = "Text",
        TextXAlignment = Enum.TextXAlignment.Left,
        ThemeTag = {TextColor3 = "Text"}
    })
    
    -- Switch
    self.Switch = Creator.New("Frame", {
        Parent = self.Frame,
        Size = UDim2.fromOffset(40, 20),
        Position = UDim2.new(1, -40, 0.5, -10),
        BackgroundColor3 = "Surface2",
        ThemeTag = {BackgroundColor3 = "Surface2"}
    })
    Creator.AddCorner(self.Switch, 10)
    Creator.AddStroke(self.Switch, {Color="Outline", ThemeTag={Color="Outline"}, Thickness=1})
    
    self.Knob = Creator.New("Frame", {
        Parent = self.Switch,
        Size = UDim2.fromOffset(16, 16),
        Position = UDim2.fromOffset(2, 2),
        BackgroundColor3 = "SubText",
        ThemeTag = {BackgroundColor3 = "SubText"}
    })
    Creator.AddCorner(self.Knob, 8)
    
    -- Interaction
    self.Frame.MouseButton1Click:Connect(function()
        self:Set(not self.Value)
    end)
    
    -- Init
    self:UpdateDisplay()
    
    return self
end

function Toggle:UpdateDisplay()
    local targetPos = self.Value and UDim2.fromOffset(22, 2) or UDim2.fromOffset(2, 2)
    local targetColor = self.Value and ThemeManager:GetColor("Accent") or ThemeManager:GetColor("SubText")
    local switchColor = self.Value and ThemeManager:GetColor("Accent") or ThemeManager:GetColor("Surface2")
    
    Utility.Tween(self.Knob, TweenInfo.new(0.2), {Position = targetPos, BackgroundColor3 = ThemeManager:GetColor("Text")}) -- Knob white on active
    Utility.Tween(self.Switch, TweenInfo.new(0.2), {BackgroundColor3 = switchColor})
end

function Toggle:Set(val)
    self.Value = val
    if self.Flag and self.Window then
        self.Window.Flags[self.Flag] = self.Value
    end
    self:UpdateDisplay()
    self.Callback(val)
end

return Toggle
