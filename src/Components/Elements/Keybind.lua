-- Phantasm Keybind
local UserInputService = game:GetService("UserInputService")
local Creator = require(script.Parent.Parent.Parent.Creator)
local Utility = require(script.Parent.Parent.Parent.Utils.Utility)
local ThemeManager = require(script.Parent.Parent.Parent.ThemeManager)

local Keybind = {}
Keybind.__index = Keybind

function Keybind.new(container, options, window)
    local self = setmetatable({}, Keybind)
    
    self.Window = window
    self.Options = options
    self.Value = options.Default -- KeyCode or nil
    self.Callback = options.Callback or function() end
    self.Flag = options.Flag
    self.Binding = false
    
    if self.Flag and self.Window then
        self.Window.Flags[self.Flag] = self.Value
    end
    
    self.Frame = Creator.New("Frame", {
        Parent = container,
        Size = UDim2.new(1, 0, 0, 32),
        BackgroundTransparency = 1
    })
    
    self.TitleLabel = Creator.New("TextLabel", {
        Parent = self.Frame,
        Size = UDim2.new(1, -60, 1, 0),
        BackgroundTransparency = 1,
        Text = options.Title or "Keybind",
        Font = Enum.Font.GothamMedium,
        TextSize = 13,
        TextColor3 = "Text",
        TextXAlignment = Enum.TextXAlignment.Left,
        ThemeTag = {TextColor3 = "Text"}
    })
    
    self.Button = Creator.New("TextButton", {
        Parent = self.Frame,
        Size = UDim2.new(0, 80, 0, 24),
        Position = UDim2.new(1, -80, 0, 4),
        BackgroundColor3 = "Surface2",
        ThemeTag = {BackgroundColor3 = "Surface2"},
        Text = "",
        AutoButtonColor = false
    })
    Creator.AddCorner(self.Button, 4)
    Creator.AddStroke(self.Button, {Color="Outline", ThemeTag={Color="Outline"}})
    
    self.BindLabel = Creator.New("TextLabel", {
        Parent = self.Button,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = self.Value and self.Value.Name or "None",
        Font = Enum.Font.Gotham,
        TextSize = 12,
        TextColor3 = "SubText",
        ThemeTag = {TextColor3 = "SubText"}
    })
    
    self.Button.MouseButton1Click:Connect(function()
        self.Binding = true
        self.BindLabel.Text = "..."
    end)
    
    UserInputService.InputBegan:Connect(function(input)
        if self.Binding then
            if input.UserInputType == Enum.UserInputType.Keyboard then
                self.Binding = false
                if input.KeyCode == Enum.KeyCode.Escape then
                    self:Set(nil)
                else
                    self:Set(input.KeyCode)
                end
            elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
                 self.Binding = false
                 self:Set(nil)
            end
        elseif self.Value and input.KeyCode == self.Value then
            self.Callback()
        end
    end)
    
    return self
end

function Keybind:Set(key)
    self.Value = key
    self.BindLabel.Text = key and key.Name or "None"
    
    if self.Flag and self.Window then
         self.Window.Flags[self.Flag] = self.Value
    end
end

return Keybind
