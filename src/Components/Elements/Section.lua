-- Phantasm Section
local Creator = require(script.Parent.Parent.Parent.Creator)
local Utility = require(script.Parent.Parent.Parent.Utils.Utility)
local ThemeManager = require(script.Parent.Parent.Parent.ThemeManager)

local Section = {}
Section.__index = Section

function Section.new(parentContainer, options)
    local self = setmetatable({}, Section)
    self.Container = parentContainer
    self.Title = options.Title or "Section"
    
    -- Main Frame
    self.Frame = Creator.New("Frame", {
        Parent = parentContainer,
        Size = UDim2.new(1, 0, 0, 0), -- Auto size handles Y
        BackgroundColor3 = "Surface",
        ThemeTag = {BackgroundColor3 = "Surface"},
        AutomaticSize = Enum.AutomaticSize.Y
    })
    Creator.AddCorner(self.Frame, 8)
    Creator.AddStroke(self.Frame, {Color="Outline", ThemeTag={Color="Outline"}})
    
    -- Title
    self.Label = Creator.New("TextLabel", {
        Parent = self.Frame,
        Size = UDim2.new(1, -20, 0, 30),
        Position = UDim2.fromOffset(10, 0),
        BackgroundTransparency = 1,
        Text = self.Title,
        Font = Enum.Font.GothamBold,
        TextSize = 14,
        TextColor3 = "Text",
        TextXAlignment = Enum.TextXAlignment.Left,
        ThemeTag = {TextColor3 = "Text"}
    })
    
    -- Content Holder
    self.Content = Creator.New("Frame", {
        Parent = self.Frame,
        Size = UDim2.new(1, -20, 0, 0),
        Position = UDim2.fromOffset(10, 30),
        BackgroundTransparency = 1,
        AutomaticSize = Enum.AutomaticSize.Y
    })
    
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 8)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = self.Content
    
    -- Padding check
    local pad = Instance.new("UIPadding")
    pad.PaddingBottom = UDim.new(0, 10)
    pad.Parent = self.Content

    return self
end

-- Function to add elements to the section
-- Note: Elements will parent to self.Content

function Section:AddButton(options)
    local Button = require(script.Parent.Button)
    return Button.new(self.Content, options)
end

function Section:AddToggle(options)
    local Toggle = require(script.Parent.Toggle)
    return Toggle.new(self.Content, options) -- Pass window? Need config context
end

-- ... etc

return Section
