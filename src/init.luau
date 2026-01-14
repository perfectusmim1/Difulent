-- Phantasm Library
local Window = require(script.Components.Window)
local ThemeManager = require(script.ThemeManager)

local Library = {}
Library.Version = "1.0.0"

function Library.CreateWindow(options)
    return Window.new(options)
end

function Library:SetTheme(theme)
    ThemeManager:SetTheme(theme)
end

function Library:Notify(options)
    -- Notify logic usually tied to a window or global overlay.
    -- If we have multiple windows, we should pick the most recently active one or create a global screenGui.
    -- Since our Window creates its own ScreenGui, we need to pick one.
    -- For simplicity, Phantasm works best with 1 Main Window.
    warn("Notify should be called on the Window instance for now.")
end

-- Expose classes for direct usage if needed
Library.ThemeManager = ThemeManager

return Library
