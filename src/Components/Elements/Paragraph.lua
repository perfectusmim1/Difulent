-- Phantasm Paragraph
local Creator = require(script.Parent.Parent.Parent.Creator)

local Paragraph = {}
Paragraph.__index = Paragraph

function Paragraph.new(container, options)
    local self = setmetatable({}, Paragraph)
    
    self.Frame = Creator.New("Frame", {
        Parent = container,
        Size = UDim2.new(1, 0, 0, 0), -- Auto
        BackgroundTransparency = 1,
        AutomaticSize = Enum.AutomaticSize.Y
    })
    
    self.TitleLabel = Creator.New("TextLabel", {
        Parent = self.Frame,
        Size = UDim2.new(1, 0, 0, 20),
        BackgroundTransparency = 1,
        Text = options.Title or "Paragraph",
        Font = Enum.Font.GothamMedium,
        TextSize = 14,
        TextColor3 = "Text",
        TextXAlignment = Enum.TextXAlignment.Left,
        ThemeTag = {TextColor3 = "Text"}
    })
    
    self.ContentLabel = Creator.New("TextLabel", {
        Parent = self.Frame,
        Size = UDim2.new(1, 0, 0, 0),
        Position = UDim2.fromOffset(0, 25),
        BackgroundTransparency = 1,
        Text = options.Content or "",
        Font = Enum.Font.Gotham,
        TextSize = 13,
        TextColor3 = "SubText",
        TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = true,
        AutomaticSize = Enum.AutomaticSize.Y,
        ThemeTag = {TextColor3 = "SubText"}
    })
    
    local pad = Instance.new("UIPadding")
    pad.PaddingBottom = UDim.new(0, 10)
    pad.Parent = self.Frame

    return self
end

function Paragraph:Set(options)
    if options.Title then self.TitleLabel.Text = options.Title end
    if options.Content then self.ContentLabel.Text = options.Content end
end

return Paragraph
