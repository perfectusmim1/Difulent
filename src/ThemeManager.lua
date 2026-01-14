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
        Icon = Color3.fromRGB(180, 180, 180),
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
        Icon = Color3.fromRGB(160, 160, 180),
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
        Icon = Color3.fromRGB(150, 150, 150),
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
        Icon = Color3.fromRGB(140, 180, 200),
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
        Icon = Color3.fromRGB(150, 180, 150),
        Success = Color3.fromRGB(46, 204, 113),
        Warning = Color3.fromRGB(241, 196, 15),
        Danger = Color3.fromRGB(231, 76, 60),
        Shadow = Color3.fromRGB(0, 0, 0)
    }
}

ThemeManager.CurrentTheme = ThemeManager.BuiltInThemes.Dark
ThemeManager.CurrentThemeName = "Dark"

ThemeManager._bindings = setmetatable({}, { __mode = "k" })
ThemeManager._tokenSet = {}
for token in pairs(ThemeManager.BuiltInThemes.Dark) do
	ThemeManager._tokenSet[token] = true
end

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
	self:ApplyAll()
    self.ThemeChanged:Fire(self.CurrentThemeName)
end

function ThemeManager:AddTheme(themeTable)
	if type(themeTable) ~= "table" then
		return false, "Theme must be a table"
	end
	local name = themeTable.Name or themeTable.name
	if type(name) ~= "string" or name == "" then
		return false, "Theme must include Name"
	end

	self.BuiltInThemes[name] = themeTable
	for token in pairs(themeTable) do
		self._tokenSet[token] = true
	end

	return true
end

function ThemeManager:GetThemes()
	local names = {}
	for name in pairs(self.BuiltInThemes) do
		table.insert(names, name)
	end
	table.sort(names)
	return names
end

function ThemeManager:GetTheme()
	return self.CurrentTheme
end

function ThemeManager:GetThemeName()
	return self.CurrentThemeName
end

function ThemeManager:GetColor(token)
    return self.CurrentTheme[token] or Color3.new(1,0,1)
end

function ThemeManager:IsToken(token)
	if type(token) ~= "string" then
		return false
	end
	return self._tokenSet[token] == true or self.CurrentTheme[token] ~= nil
end

function ThemeManager:_resolveToken(tokenOrFn)
	if type(tokenOrFn) == "function" then
		return tokenOrFn(self.CurrentTheme)
	end
	return self:GetColor(tokenOrFn)
end

function ThemeManager:_applyToInstance(instance, mapping)
	for prop, tokenOrFn in pairs(mapping) do
		local ok, value = pcall(function()
			return self:_resolveToken(tokenOrFn)
		end)
		if ok then
			pcall(function()
				instance[prop] = value
			end)
		end
	end
end

function ThemeManager:Bind(instance, mapping)
	if not instance or type(mapping) ~= "table" then
		return
	end
	local existing = self._bindings[instance]
	if not existing then
		existing = {}
		self._bindings[instance] = existing
	end
	for prop, tokenOrFn in pairs(mapping) do
		existing[prop] = tokenOrFn
	end
	self:_applyToInstance(instance, existing)
end

function ThemeManager:Unbind(instance)
	self._bindings[instance] = nil
end

function ThemeManager:ApplyAll()
	for instance, mapping in pairs(self._bindings) do
		self:_applyToInstance(instance, mapping)
	end
end

return ThemeManager
