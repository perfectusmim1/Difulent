-- Phantasm Button
local Creator = require(script.Parent.Parent.Parent.Creator)
local Utility = require(script.Parent.Parent.Parent.Utils.Utility)
local ThemeManager = require(script.Parent.Parent.Parent.ThemeManager)

local Button = {}
Button.__index = Button

function Button.new(container, options)
    local self = setmetatable({}, Button)
    
    self.Options = options
    self.Callback = options.Callback or function() end
    
    self.Frame = Creator.New("TextButton", {
        Parent = container,
        Size = UDim2.new(1, 0, 0, 32),
        BackgroundColor3 = "Surface2",
        ThemeTag = {BackgroundColor3 = "Surface2"},
        Text = "",
        AutoButtonColor = false
    })
    Creator.AddCorner(self.Frame, 6)
    
    self.TitleLabel = Creator.New("TextLabel", {
        Parent = self.Frame,
        Size = UDim2.new(1, -20, 1, 0),
        Position = UDim2.fromOffset(10, 0),
        BackgroundTransparency = 1,
        Text = options.Title or "Button",
        Font = Enum.Font.GothamMedium,
        TextSize = 13,
        TextColor3 = "Text",
        TextXAlignment = Enum.TextXAlignment.Left,
        ThemeTag = {TextColor3 = "Text"}
    })
    
    -- Icon arrow
    local icon = Creator.New("ImageLabel", {
        Parent = self.Frame,
        Size = UDim2.fromOffset(16, 16),
        Position = UDim2.new(1, -26, 0.5, -8),
        BackgroundTransparency = 1,
        Image = Utility.GetIcon("chevron-right"),
        ImageColor3 = "SubText",
        ThemeTag = {ImageColor3 = "SubText"}
    })
    
    -- Interactions
    self.Frame.MouseEnter:Connect(function()
        Utility.Tween(self.Frame, TweenInfo.new(0.2), {BackgroundColor3 = ThemeManager:GetColor("Outline")})
    end)
    self.Frame.MouseLeave:Connect(function()
        Utility.Tween(self.Frame, TweenInfo.new(0.2), {BackgroundColor3 = ThemeManager:GetColor("Surface2")})
    end)
    
    self.Frame.MouseButton1Click:Connect(function()
        Utility.AddRipple(self.Frame)
        self.Callback()
    end)
    
    return self
end

function Button:SetTitle(text)
    self.TitleLabel.Text = text
end

function Button:SetCallback(fn)
    self.Callback = fn
end

return Button
