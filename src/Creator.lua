-- Phantasm Creator
local ThemeManager = require(script.Parent.ThemeManager)

local Creator = {}

-- Helper to apply properties
local function ApplyProperties(instance, props)
    for k, v in pairs(props) do
        if k ~= "ThemeTag" and k ~= "Parent" then
			if ThemeManager:IsToken(v) then
				instance[k] = ThemeManager:GetColor(v)
				ThemeManager:Bind(instance, { [k] = v })
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
		ThemeManager:Bind(instance, props.ThemeTag)
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
		ThemeManager:Bind(stroke, props.ThemeTag)
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
