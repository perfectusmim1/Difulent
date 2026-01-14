-- Phantasm Slider
local UserInputService = game:GetService("UserInputService")
local Creator = require(script.Parent.Parent.Parent.Creator)
local Utility = require(script.Parent.Parent.Parent.Utils.Utility)
local ThemeManager = require(script.Parent.Parent.Parent.ThemeManager)

local Slider = {}
Slider.__index = Slider

function Slider.new(container, options, window)
    local self = setmetatable({}, Slider)
    
    self.Window = window
    self.Options = options
    self.Min = options.Min or 0
    self.Max = options.Max or 100
    self.Step = options.Step or 1
    self.Value = options.Default or self.Min
    self.Callback = options.Callback or function() end
    self.Flag = options.Flag
    
    self.Dragging = false
    
    if self.Flag and self.Window then
        self.Window.Flags[self.Flag] = self.Value
    end
    
    -- Frame
    self.Frame = Creator.New("Frame", {
        Parent = container,
        Size = UDim2.new(1, 0, 0, 50),
        BackgroundTransparency = 1
    })
    
    -- Title
    self.TitleLabel = Creator.New("TextLabel", {
        Parent = self.Frame,
        Size = UDim2.new(1, 0, 0, 20),
        BackgroundTransparency = 1,
        Text = options.Title or "Slider",
        Font = Enum.Font.GothamMedium,
        TextSize = 13,
        TextColor3 = "Text",
        TextXAlignment = Enum.TextXAlignment.Left,
        ThemeTag = {TextColor3 = "Text"}
    })
    
    -- Value Label
    self.ValueLabel = Creator.New("TextLabel", {
        Parent = self.Frame,
        Size = UDim2.new(0, 50, 0, 20),
        Position = UDim2.new(1, -50, 0, 0),
        BackgroundTransparency = 1,
        Text = tostring(self.Value),
        Font = Enum.Font.Gotham,
        TextSize = 13,
        TextColor3 = "SubText",
        TextXAlignment = Enum.TextXAlignment.Right,
        ThemeTag = {TextColor3 = "SubText"}
    })
    
    -- Slider Bar Container
    self.BarContainer = Creator.New("TextButton", { -- Button for easier clicking
        Parent = self.Frame,
        Size = UDim2.new(1, 0, 0, 6),
        Position = UDim2.new(0, 0, 1, -10),
        BackgroundColor3 = "Surface2",
        ThemeTag = {BackgroundColor3 = "Surface2"},
        Text = "",
        AutoButtonColor = false
    })
    Creator.AddCorner(self.BarContainer, 4)
    
    -- Fill
    self.Fill = Creator.New("Frame", {
        Parent = self.BarContainer,
        Size = UDim2.new(0.5, 0, 1, 0),
        BackgroundColor3 = "Accent",
        ThemeTag = {BackgroundColor3 = "Accent"},
        BorderSizePixel = 0
    })
    Creator.AddCorner(self.Fill, 4)
    
    -- Knob
    self.Knob = Creator.New("Frame", {
        Parent = self.Fill,
        Size = UDim2.fromOffset(12, 12),
        Position = UDim2.new(1, -6, 0.5, -6),
        BackgroundColor3 = "Text",
        ThemeTag = {BackgroundColor3 = "Text"}
    })
    Creator.AddCorner(self.Knob, 6)
    
    -- Logic
    local function Update(input)
        local sizeX = self.BarContainer.AbsoluteSize.X
        local pad = self.BarContainer.AbsolutePosition.X
        local relative = math.clamp((input.Position.X - pad) / sizeX, 0, 1)
        
        local rawValue = self.Min + ((self.Max - self.Min) * relative)
        
        -- Round to step
        local steppedValue = math.floor(rawValue / self.Step + 0.5) * self.Step
        self:Set(steppedValue)
    end
    
    self.BarContainer.MouseButton1Down:Connect(function()
        self.Dragging = true
        Update(UserInputService:GetMouse())
    end)
    
    self.BarContainer.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            self.Dragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if self.Dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            Update(input)
        end
    end)
    
    self:Set(self.Value)
    
    return self
end

function Slider:Set(value)
    self.Value = math.clamp(value, self.Min, self.Max)
    
    -- Update visuals
    local percent = (self.Value - self.Min) / (self.Max - self.Min)
    self.Fill:TweenSize(UDim2.new(percent, 0, 1, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Sine, 0.05, true)
    
    self.ValueLabel.Text = tostring(self.Value) .. (self.Options.Suffix or "")
    
    if self.Flag and self.Window then
        self.Window.Flags[self.Flag] = self.Value
    end
    self.Callback(self.Value)
end

return Slider
