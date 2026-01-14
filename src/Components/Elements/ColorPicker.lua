-- Phantasm ColorPicker
local UserInputService = game:GetService("UserInputService")
local Creator = require(script.Parent.Parent.Parent.Creator)
local Utility = require(script.Parent.Parent.Parent.Utils.Utility)
local ThemeManager = require(script.Parent.Parent.Parent.ThemeManager)

local ColorPicker = {}
ColorPicker.__index = ColorPicker

function ColorPicker.new(container, options, window)
    local self = setmetatable({}, ColorPicker)
    
    self.Window = window
    self.Options = options
    self.Value = options.Default or Color3.new(1,1,1)
    self.Transparency = options.Transparency or 0
    self.Callback = options.Callback or function() end
    self.Flag = options.Flag
    
    if self.Flag and self.Window then
        self.Window.Flags[self.Flag] = self.Value
    end
    
    self.Frame = Creator.New("TextButton", {
        Parent = container,
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundTransparency = 1,
        Text = "",
        AutoButtonColor = false
    })
    
    self.TitleLabel = Creator.New("TextLabel", {
        Parent = self.Frame,
        Size = UDim2.new(1, -60, 0, 20),
        Position = UDim2.fromOffset(0, 10),
        BackgroundTransparency = 1,
        Text = options.Title or "ColorPicker",
        Font = Enum.Font.GothamMedium,
        TextSize = 13,
        TextColor3 = "Text",
        TextXAlignment = Enum.TextXAlignment.Left,
        ThemeTag = {TextColor3 = "Text"}
    })
    
    self.Indicator = Creator.New("Frame", {
        Parent = self.Frame,
        Size = UDim2.fromOffset(40, 20),
        Position = UDim2.new(1, -40, 0.5, -10),
        BackgroundColor3 = self.Value
    })
    Creator.AddCorner(self.Indicator, 6)
    Creator.AddStroke(self.Indicator, {Color="Outline", ThemeTag={Color="Outline"}})
    
    self.Open = false
    
    -- Inputs Container (Hidden by default)
    self.Container = Creator.New("Frame", {
        Parent = container,
        Size = UDim2.new(1, 0, 0, 0),
        BackgroundTransparency = 1,
        ClipsDescendants = true,
        Visible = false
    })
    
    local layout = Instance.new("UIListLayout")
    layout.Parent = self.Container
    
    -- Helper to create RGB slider
    local function MakeSlider(name, colorKey)
        local sFrame = Creator.New("Frame", {
            Parent = self.Container,
            Size = UDim2.new(1, 0, 0, 30),
            BackgroundTransparency = 1
        })
        
        local sLabel = Creator.New("TextLabel", {
            Parent = sFrame,
            Size = UDim2.new(0, 20, 1, 0),
            Text = name,
            TextColor3 = "SubText",
            BackgroundTransparency = 1,
            Font = Enum.Font.GothamBold,
            TextSize = 12,
            ThemeTag = {TextColor3 = "SubText"}
        })
        
        local sBar = Creator.New("TextButton", {
            Parent = sFrame,
            Size = UDim2.new(1, -40, 0, 6),
            Position = UDim2.new(0, 30, 0.5, -3),
            BackgroundColor3 = "Surface2",
            ThemeTag = {BackgroundColor3 = "Surface2"},
            Text = "",
            AutoButtonColor = false
        })
        Creator.AddCorner(sBar, 3)
        
        local sFill = Creator.New("Frame", {
            Parent = sBar,
            Size = UDim2.new(0,0,1,0),
            BackgroundColor3 = "Accent",
            ThemeTag = {BackgroundColor3 = "Accent"}
        })
        Creator.AddCorner(sFill, 3)
        
        -- Logic
        local dragging = false
        local function Update(input)
             local relative = math.clamp((input.Position.X - sBar.AbsolutePosition.X) / sBar.AbsoluteSize.X, 0, 1)
             sFill.Size = UDim2.new(relative, 0, 1, 0)
             
             local r,g,b = self.Value.R, self.Value.G, self.Value.B
             if name == "R" then r = relative end
             if name == "G" then g = relative end
             if name == "B" then b = relative end
             
             self:Set(Color3.new(r,g,b))
        end
        
        sBar.MouseButton1Down:Connect(function() dragging = true; Update(UserInputService:GetMouse()) end)
        UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
        UserInputService.InputChanged:Connect(function(input) if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then Update(input) end end)
        
        -- Sync (Basic)
        -- We'd need a way to reverse update sliders if Set() is called externally.
        -- For now, we skip reverse-sync for simplicity in this generated code.
    end
    
    MakeSlider("R")
    MakeSlider("G")
    MakeSlider("B")
    
    self.Frame.MouseButton1Click:Connect(function()
        self.Open = not self.Open
        self.Container.Visible = self.Open
        Utility.Tween(self.Container, TweenInfo.new(0.3), {Size = UDim2.new(1, 0, 0, self.Open and 100 or 0)})
    end)
    
    return self
end

function ColorPicker:Set(val)
    self.Value = val
    self.Indicator.BackgroundColor3 = val
    
    if self.Flag and self.Window then
        self.Window.Flags[self.Flag] = self.Value
    end
    self.Callback(val)
end

return ColorPicker
