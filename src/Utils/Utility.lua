-- Phantasm Utility Module
local TweenService = game:GetService("TweenService")
local TextService = game:GetService("TextService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local ThemeManager = require(script.Parent.Parent.ThemeManager)

local Utility = {}

-- Lucide Icon Map (Subset of commonly used icons)
-- In a full prod version, this might fetch from an external source or be huge.
local Icons = {
    ["search"] = "rbxassetid://18216666242",
    ["home"] = "rbxassetid://18216666456",
    ["settings"] = "rbxassetid://18216667519",
    ["user"] = "rbxassetid://18216667743",
    ["info"] = "rbxassetid://18216666699",
    ["x"] = "rbxassetid://18216668787",
    ["check"] = "rbxassetid://18216664972",
    ["chevron-down"] = "rbxassetid://18216665097",
    ["chevron-right"] = "rbxassetid://18216665241",
    ["moon"] = "rbxassetid://18216663242",
    ["sun"] = "rbxassetid://18216663456",
    ["trash"] = "rbxassetid://18216667520",
    ["edit"] = "rbxassetid://18216665798",
    ["lock"] = "rbxassetid://18216666991",
    ["unlock"] = "rbxassetid://18216667523",
    ["eye"] = "rbxassetid://18216666010",
    ["eye-off"] = "rbxassetid://18216666133",
    ["copy"] = "rbxassetid://18216665421",
    ["maximize-2"] = "rbxassetid://18216666992", -- used for open
    ["minus"] = "rbxassetid://18216667104",
    ["plus"] = "rbxassetid://18216667317",
    ["code"] = "rbxassetid://18216665096",
    ["file-text"] = "rbxassetid://18216666243",
    ["image"] = "rbxassetid://18216666573",
    ["layers"] = "rbxassetid://18216666804",
    ["more-horizontal"] = "rbxassetid://18216667102"
}

-- Default Fallback Icon
local MISSING_ICON = "rbxassetid://18216666699" -- Info icon

function Utility.GetIcon(name)
    if not name then return "" end
    if string.find(name, "rbxassetid://") then return name end
    return Icons[string.lower(name)] or MISSING_ICON
end

function Utility.Tween(instance, tweenInfo, goals, callback)
    local tween = TweenService:Create(instance, tweenInfo, goals)
    tween:Play()
    if callback then
        tween.Completed:Connect(callback)
    end
    return tween
end

function Utility.GetTextSize(text, font, textSize, maxWidth)
    return TextService:GetTextSize(text, textSize, font, Vector2.new(maxWidth or 9e9, 9e9))
end

function Utility.EnableDragging(frame, dragHandle)
    dragHandle = dragHandle or frame
    local dragging, dragInput, dragStart, startPos

    local function update(input)
        local delta = input.Position - dragStart
        local newPos = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        -- Optional clamping logic could go here
        local tween = TweenService:Create(frame, TweenInfo.new(0.1, Enum.EasingStyle.Sine), {Position = newPos})
        tween:Play()
    end

    dragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    dragHandle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end)
end

-- Ripple Effect
function Utility.AddRipple(button, color)
    color = color or Color3.fromRGB(255, 255, 255)
    button.ClipsDescendants = true

    local conn = button.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local x, y = input.Position.X - button.AbsolutePosition.X, input.Position.Y - button.AbsolutePosition.Y
            local size = math.max(button.AbsoluteSize.X, button.AbsoluteSize.Y) * 1.5
            
            local ripple = Instance.new("Frame")
            ripple.Name = "Ripple"
            ripple.BackgroundColor3 = color
            ripple.BackgroundTransparency = 0.8
            ripple.BorderSizePixel = 0
            ripple.AnchorPoint = Vector2.new(0.5, 0.5)
            ripple.Position = UDim2.new(0, x, 0, y)
            ripple.Size = UDim2.new(0, 0, 0, 0)
            ripple.Parent = button
            
            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(1, 0)
            corner.Parent = ripple
            
            TweenService:Create(ripple, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Size = UDim2.new(0, size, 0, size),
                BackgroundTransparency = 1
            }):Play()
            
            task.delay(0.5, function()
                ripple:Destroy()
            end)
        end
    end)

    return conn
end

local function buildColorSequence(theme, topToken, bottomToken)
    local top = theme[topToken] or Color3.new(1, 1, 1)
    local bottom = theme[bottomToken] or top
    return ColorSequence.new({
        ColorSequenceKeypoint.new(0, top),
        ColorSequenceKeypoint.new(1, bottom),
    })
end

function Utility.AddGradient(instance, topToken, bottomToken, transparency, rotation)
    local gradient = Instance.new("UIGradient")
    gradient.Rotation = rotation or 90
    if transparency then
        gradient.Transparency = transparency
    end
    ThemeManager:Bind(gradient, {
        Color = function(theme)
            return buildColorSequence(theme, topToken, bottomToken)
        end,
    })
    gradient.Parent = instance
    return gradient
end

function Utility.Join(t1, t2)
    local t = {}
    for k,v in pairs(t1) do t[k] = v end
    for k,v in pairs(t2) do t[k] = v end
    return t
end

return Utility
