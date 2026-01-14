-- Phantasm Library
local Window = require(script.Components.Window)
local ThemeManager = require(script.ThemeManager)

local Library = {}
Library.Version = "1.3.0"
Library._windows = {}
Library._lastWindow = nil

function Library.CreateWindow(options)
    local win = Window.new(options)
    table.insert(Library._windows, win)
    Library._lastWindow = win

    if win.OnDestroy then
        win.OnDestroy:Connect(function()
            for i, w in ipairs(Library._windows) do
                if w == win then
                    table.remove(Library._windows, i)
                    break
                end
            end
            if Library._lastWindow == win then
                Library._lastWindow = Library._windows[#Library._windows]
            end
        end)
    end

    return win
end

function Library:SetTheme(theme)
    ThemeManager:SetTheme(theme)
end

function Library:AddTheme(themeTable)
    return ThemeManager:AddTheme(themeTable)
end

function Library:GetThemes()
    return ThemeManager:GetThemes()
end

function Library:GetTheme()
    return ThemeManager:GetTheme()
end

function Library:GetThemeName()
    return ThemeManager:GetThemeName()
end

function Library:Notify(options)
    local target = Library._lastWindow
    if target and target.Notify then
        target:Notify(options)
        return true
    end
    warn("Phantasm: No window available for notifications.")
    return false
end

function Library:Dialog(options)
    local target = Library._lastWindow
    if target and target.Dialog then
        return target:Dialog(options)
    end
    warn("Phantasm: No window available for dialogs.")
    return nil
end

function Library:Popup(options)
    local target = Library._lastWindow
    if target and target.Popup then
        return target:Popup(options)
    end
    warn("Phantasm: No window available for popups.")
    return nil
end

function Library:Destroy()
    for _, win in ipairs(Library._windows) do
        pcall(function()
            win:Destroy()
        end)
    end
    Library._windows = {}
    Library._lastWindow = nil
end

-- Expose classes for direct usage if needed
Library.ThemeManager = ThemeManager

return Library
