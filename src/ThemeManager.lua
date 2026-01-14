-- Phantasm ThemeManager
local Signal = require(script.Parent.Utils.Signal)

local ThemeManager = {}
ThemeManager.ThemeChanged = Signal.new()

ThemeManager.BuiltInThemes = {
    Dark = {
        Accent = Color3.fromRGB(93, 142, 255),
        Background = Color3.fromRGB(15, 17, 23),
        Surface = Color3.fromRGB(22, 24, 31),
        Surface2 = Color3.fromRGB(30, 33, 42),
        Outline = Color3.fromRGB(44, 48, 60),
        Text = Color3.fromRGB(230, 233, 240),
        SubText = Color3.fromRGB(165, 172, 185),
        Placeholder = Color3.fromRGB(110, 118, 130),
        Icon = Color3.fromRGB(165, 172, 185),
        Success = Color3.fromRGB(92, 214, 141),
        Warning = Color3.fromRGB(250, 200, 110),
        Danger = Color3.fromRGB(255, 100, 100),
        Shadow = Color3.fromRGB(0, 0, 0)
    },
    Midnight = {
        Accent = Color3.fromRGB(114, 137, 218),
        Background = Color3.fromRGB(12, 14, 20),
        Surface = Color3.fromRGB(18, 21, 30),
        Surface2 = Color3.fromRGB(26, 30, 42),
        Outline = Color3.fromRGB(38, 44, 60),
        Text = Color3.fromRGB(232, 236, 246),
        SubText = Color3.fromRGB(155, 165, 185),
        Placeholder = Color3.fromRGB(100, 110, 130),
        Icon = Color3.fromRGB(155, 165, 185),
        Success = Color3.fromRGB(88, 206, 132),
        Warning = Color3.fromRGB(248, 198, 105),
        Danger = Color3.fromRGB(255, 96, 96),
        Shadow = Color3.fromRGB(0, 0, 0)
    },
    OLED = {
        Accent = Color3.fromRGB(240, 244, 255),
        Background = Color3.fromRGB(0, 0, 0),
        Surface = Color3.fromRGB(12, 12, 12),
        Surface2 = Color3.fromRGB(22, 22, 22),
        Outline = Color3.fromRGB(32, 32, 32),
        Text = Color3.fromRGB(245, 245, 245),
        SubText = Color3.fromRGB(150, 150, 150),
        Placeholder = Color3.fromRGB(90, 90, 90),
        Icon = Color3.fromRGB(150, 150, 150),
        Success = Color3.fromRGB(120, 230, 140),
        Warning = Color3.fromRGB(240, 210, 120),
        Danger = Color3.fromRGB(255, 90, 90),
        Shadow = Color3.fromRGB(0, 0, 0)
    },
    Ocean = {
        Accent = Color3.fromRGB(64, 180, 210),
        Background = Color3.fromRGB(8, 20, 28),
        Surface = Color3.fromRGB(14, 32, 44),
        Surface2 = Color3.fromRGB(22, 46, 64),
        Outline = Color3.fromRGB(32, 60, 78),
        Text = Color3.fromRGB(224, 240, 250),
        SubText = Color3.fromRGB(140, 176, 195),
        Placeholder = Color3.fromRGB(100, 126, 144),
        Icon = Color3.fromRGB(140, 176, 195),
        Success = Color3.fromRGB(70, 216, 160),
        Warning = Color3.fromRGB(248, 208, 110),
        Danger = Color3.fromRGB(255, 90, 90),
        Shadow = Color3.fromRGB(0, 5, 10)
    },
    Emerald = {
        Accent = Color3.fromRGB(70, 210, 140),
        Background = Color3.fromRGB(14, 20, 16),
        Surface = Color3.fromRGB(22, 32, 24),
        Surface2 = Color3.fromRGB(30, 44, 32),
        Outline = Color3.fromRGB(44, 60, 46),
        Text = Color3.fromRGB(226, 248, 232),
        SubText = Color3.fromRGB(150, 178, 156),
        Placeholder = Color3.fromRGB(100, 120, 106),
        Icon = Color3.fromRGB(150, 178, 156),
        Success = Color3.fromRGB(70, 210, 140),
        Warning = Color3.fromRGB(236, 196, 110),
        Danger = Color3.fromRGB(230, 92, 92),
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
