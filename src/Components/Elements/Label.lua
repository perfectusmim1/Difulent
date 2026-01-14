-- Phantasm Label
local Creator = require(script.Parent.Parent.Parent.Creator)

local Label = {}
Label.__index = Label

function Label.new(container, options)
    local self = setmetatable({}, Label)
    
    self.Frame = Creator.New("TextLabel", {
        Parent = container,
        Size = UDim2.new(1, 0, 0, 26),
        BackgroundTransparency = 1,
        Text = options.Title or "Label",
        Font = Enum.Font.Gotham,
        TextSize = 13,
        TextColor3 = "Text",
        TextXAlignment = Enum.TextXAlignment.Left,
        ThemeTag = {TextColor3 = "Text"}
    })
    
    return self
end

function Label:SetTitle(t)
    self.Frame.Text = t
end

return Label
