-- Phantasm ThemeManager
local Signal = require(script.Parent.Utils.Signal)

local ThemeManager = {}
ThemeManager.ThemeChanged = Signal.new()

ThemeManager.BuiltInThemes = {
    Dark = {
        Accent = Color3.fromRGB(0, 120, 212),       -- Windows Blue
        Background = Color3.fromRGB(32, 32, 32),    -- Dark Gray
        Surface = Color3.fromRGB(45, 45, 45),       -- Slightly lighter
        Surface2 = Color3.fromRGB(60, 60, 60),      -- Hover state
        Outline = Color3.fromRGB(80, 80, 80),       -- Borders
        Text = Color3.fromRGB(255, 255, 255),       -- White
        SubText = Color3.fromRGB(180, 180, 180),    -- Light Gray
        Placeholder = Color3.fromRGB(120, 120, 120),
        Success = Color3.fromRGB(108, 203, 95),
        Warning = Color3.fromRGB(255, 212, 59),
        Danger = Color3.fromRGB(255, 75, 75),
        Shadow = Color3.fromRGB(0, 0, 0)
    },
    Midnight = {
        Accent = Color3.fromRGB(114, 137, 218),     -- Blurpleish
        Background = Color3.fromRGB(15, 15, 20),    -- Deep Blue/Black
        Surface = Color3.fromRGB(25, 25, 35),
        Surface2 = Color3.fromRGB(35, 35, 45),
        Outline = Color3.fromRGB(45, 45, 60),
        Text = Color3.fromRGB(240, 240, 255),
        SubText = Color3.fromRGB(160, 160, 180),
        Placeholder = Color3.fromRGB(100, 100, 120),
        Success = Color3.fromRGB(80, 200, 120),
        Warning = Color3.fromRGB(255, 200, 80),
        Danger = Color3.fromRGB(255, 80, 80),
        Shadow = Color3.fromRGB(0, 0, 0)
    },
    OLED = {
        Accent = Color3.fromRGB(255, 255, 255),     -- High Contrast White
        Background = Color3.fromRGB(0, 0, 0),       -- Pure Black
        Surface = Color3.fromRGB(15, 15, 15),
        Surface2 = Color3.fromRGB(30, 30, 30),
        Outline = Color3.fromRGB(40, 40, 40),
        Text = Color3.fromRGB(255, 255, 255),
        SubText = Color3.fromRGB(150, 150, 150),
        Placeholder = Color3.fromRGB(80, 80, 80),
        Success = Color3.fromRGB(0, 255, 0),
        Warning = Color3.fromRGB(255, 255, 0),
        Danger = Color3.fromRGB(255, 0, 0),
        Shadow = Color3.fromRGB(0, 0, 0)
    },
    Ocean = {
        Accent = Color3.fromRGB(0, 150, 200),
        Background = Color3.fromRGB(10, 25, 35),
        Surface = Color3.fromRGB(18, 40, 55),
        Surface2 = Color3.fromRGB(25, 55, 75),
        Outline = Color3.fromRGB(35, 70, 90),
        Text = Color3.fromRGB(220, 240, 255),
        SubText = Color3.fromRGB(140, 180, 200),
        Placeholder = Color3.fromRGB(100, 130, 150),
        Success = Color3.fromRGB(50, 220, 150),
        Warning = Color3.fromRGB(255, 220, 100),
        Danger = Color3.fromRGB(255, 80, 80),
        Shadow = Color3.fromRGB(0, 5, 10)
    },
    Emerald = {
        Accent = Color3.fromRGB(46, 204, 113),
        Background = Color3.fromRGB(20, 25, 20),
        Surface = Color3.fromRGB(30, 40, 30),
        Surface2 = Color3.fromRGB(40, 55, 40),
        Outline = Color3.fromRGB(50, 70, 50),
        Text = Color3.fromRGB(230, 255, 230),
        SubText = Color3.fromRGB(150, 180, 150),
        Placeholder = Color3.fromRGB(100, 120, 100),
        Success = Color3.fromRGB(46, 204, 113),
        Warning = Color3.fromRGB(241, 196, 15),
        Danger = Color3.fromRGB(231, 76, 60),
        Shadow = Color3.fromRGB(0, 0, 0)
    }
}

ThemeManager.CurrentTheme = ThemeManager.BuiltInThemes.Dark
ThemeManager.CurrentThemeName = "Dark"

function ThemeManager:SetTheme(nameOrTable)
    if type(nameOrTable) == "string" then
        if self.BuiltInThemes[nameOrTable] then
            self.CurrentTheme = self.BuiltInThemes[nameOrTable]
            self.CurrentThemeName = nameOrTable
        else
            warn("Phantasm: Theme '" .. nameOrTable .. "' not found. Defaulting to Dark.")
            self.CurrentTheme = self.BuiltInThemes.Dark
            self.CurrentThemeName = "Dark"
        end
    elseif type(nameOrTable) == "table" then
        -- Custom theme table
        self.CurrentTheme = nameOrTable
        self.CurrentThemeName = "Custom"
    end
    self.ThemeChanged:Fire()
end

function ThemeManager:GetColor(token)
    return self.CurrentTheme[token] or Color3.new(1,0,1)
end

function ThemeManager:Apply(instance, property, token)
    if not instance then return end
    instance[property] = self:GetColor(token)
    
    -- Store connection to update on change
    -- Realistically, this requires a Maid or cleanup mechanism passed in.
    -- For now, we assume the Component handles listening to ThemeChanged.
end

return ThemeManager
