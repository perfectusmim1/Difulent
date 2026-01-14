-- Phantasm Creator
local ThemeManager = require(script.Parent.ThemeManager)
local Utility = require(script.Parent.Utils.Utility)

local Creator = {}

-- Helper to apply properties
local function ApplyProperties(instance, props)
    for k, v in pairs(props) do
        if k ~= "ThemeTag" and k ~= "Parent" then
            if type(v) == "string" and ThemeManager.BuiltInThemes.Dark[v] then
                 -- This is a theme token
                 instance[k] = ThemeManager:GetColor(v)
                 -- Bind for updates
                 ThemeManager.ThemeChanged:Connect(function()
                     instance[k] = ThemeManager:GetColor(v)
                 end)
            else
                instance[k] = v
            end
        end
    end
    -- Handle Parent last for performance
    if props.Parent then
        instance.Parent = props.Parent
    end
end

function Creator.New(className, props)
    local instance = Instance.new(className)
    ApplyProperties(instance, props or {})
    
    if props and props.ThemeTag then
        for prop, token in pairs(props.ThemeTag) do
            instance[prop] = ThemeManager:GetColor(token)
            ThemeManager.ThemeChanged:Connect(function()
                instance[prop] = ThemeManager:GetColor(token)
            end)
        end
    end
    
    return instance
end

function Creator.AddCorner(instance, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 6)
    corner.Parent = instance
    return corner
end

function Creator.AddStroke(instance, props)
    local stroke = Instance.new("UIStroke")
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = instance
    ApplyProperties(stroke, props or {})
    
    if props.ThemeTag then
         for prop, token in pairs(props.ThemeTag) do
            stroke[prop] = ThemeManager:GetColor(token)
            ThemeManager.ThemeChanged:Connect(function()
                stroke[prop] = ThemeManager:GetColor(token)
            end)
        end
    end
    return stroke
end

function Creator.AddPadding(instance, padding)
    local pad = Instance.new("UIPadding")
    pad.PaddingLeft = UDim.new(0, padding)
    pad.PaddingRight = UDim.new(0, padding)
    pad.PaddingTop = UDim.new(0, padding)
    pad.PaddingBottom = UDim.new(0, padding)
    pad.Parent = instance
    return pad
end

return Creator
