-- Phantasm Input
local Creator = require(script.Parent.Parent.Parent.Creator)
local Utility = require(script.Parent.Parent.Parent.Utils.Utility)
local ThemeManager = require(script.Parent.Parent.Parent.ThemeManager)

local Input = {}
Input.__index = Input

function Input.new(container, options, window)
    local self = setmetatable({}, Input)
    
    self.Window = window
    self.Options = options
    self.Value = options.Default or ""
    self.Callback = options.Callback or function() end
    self.Flag = options.Flag
    self.Numeric = options.Numeric or false
    
    if self.Flag and self.Window then
        self.Window.Flags[self.Flag] = self.Value
    end
    
    -- Frame
    self.Frame = Creator.New("Frame", {
        Parent = container,
        Size = UDim2.new(1, 0, 0, 50),
        BackgroundTransparency = 1
    })
    
    self.TitleLabel = Creator.New("TextLabel", {
        Parent = self.Frame,
        Size = UDim2.new(1, 0, 0, 20),
        BackgroundTransparency = 1,
        Text = options.Title or "Input",
        Font = Enum.Font.GothamMedium,
        TextSize = 13,
        TextColor3 = "Text",
        TextXAlignment = Enum.TextXAlignment.Left,
        ThemeTag = {TextColor3 = "Text"}
    })
    
    -- Input Box Container
    self.BoxFrame = Creator.New("Frame", {
        Parent = self.Frame,
        Size = UDim2.new(1, 0, 0, 30),
        Position = UDim2.new(0, 0, 0, 20),
        BackgroundColor3 = "Surface2",
        ThemeTag = {BackgroundColor3 = "Surface2"}
    })
    Creator.AddCorner(self.BoxFrame, 6)
    Creator.AddStroke(self.BoxFrame, {Color="Outline", ThemeTag={Color="Outline"}})
    
    self.Box = Creator.New("TextBox", {
        Parent = self.BoxFrame,
        Size = UDim2.new(1, -20, 1, 0),
        Position = UDim2.fromOffset(10, 0),
        BackgroundTransparency = 1,
        Text = self.Value,
        PlaceholderText = options.Placeholder or "Enter text...",
        Font = Enum.Font.Gotham,
        TextSize = 13,
        TextColor3 = "Text",
        PlaceholderColor3 = "SubText",
        TextXAlignment = Enum.TextXAlignment.Left,
        ThemeTag = {TextColor3 = "Text", PlaceholderColor3 = "SubText"}
    })
    
    -- Validate & Update
    self.Box.FocusLost:Connect(function(enter)
        local val = self.Box.Text
        if self.Numeric then
            local num = tonumber(val)
            if not num then
                self.Box.Text = self.Value -- Revert
                return
            end
            val = num
        end
        self:Set(val)
        
        if options.Finished and enter then
            options.Finished(val)
        end
    end)
    
    return self
end

function Input:Set(val)
    self.Value = val
    self.Box.Text = tostring(val)
    
    if self.Flag and self.Window then
        self.Window.Flags[self.Flag] = self.Value
    end
    self.Callback(val)
end

return Input
