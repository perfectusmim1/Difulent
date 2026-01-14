-- Phantasm UI Library [Bundled]
-- https://github.com/perfectusmim1/Difulent
-- This file is generated from src/. Edit src/ instead.

local modules = {}
local cache = {}

local function requireModule(name)
    local cached = cache[name]
    if cached ~= nil then
        return cached
    end
    local loader = modules[name]
    if not loader then
        error(("Phantasm: missing module '%s'"):format(tostring(name)))
    end
    local value = loader()
    cache[name] = value
    return value
end

-- [[ Module: Signal ]] --
modules["Signal"] = function()
-- Phantasm Signal Implementation
local Signal = {}
Signal.__index = Signal

function Signal.new()
    local self = setmetatable({}, Signal)
    self._bindable = Instance.new("BindableEvent")
    self._argMap = {}
    self._source = ""
    return self
end

function Signal:Connect(handler)
    if not (type(handler) == "function") then
        error("connect expects a function")
    end
    
    return self._bindable.Event:Connect(function(key)
        local args = self._argMap[key]
        if args then
            handler(table.unpack(args, 1, args.n))
        end
    end)
end

function Signal:Fire(...)
    local args = table.pack(...)
    local key = tostring(os.clock()) .. tostring(math.random())
    self._argMap[key] = args
    self._bindable:Fire(key)
    -- Cleanup args after a short delay or immediately if synchronous?
    -- Bindable events are somewhat synchronous in some contexts, but let's be safe.
    task.defer(function()
        self._argMap[key] = nil
    end)
end

function Signal:Wait()
    local key = self._bindable.Event:Wait()
    local args = self._argMap[key]
    if args then
        return table.unpack(args, 1, args.n)
    end
    return
end

function Signal:Destroy()
    if self._bindable then
        self._bindable:Destroy()
        self._bindable = nil
    end
    self._argMap = nil
end

return Signal
end

-- [[ Module: Maid ]] --
modules["Maid"] = function()
-- Phantasm Maid Implementation
local Maid = {}
Maid.__index = Maid

function Maid.new()
	return setmetatable({
		_tasks = {}
	}, Maid)
end

function Maid:GiveTask(task)
	if not task then return end
	local taskId = #self._tasks + 1
	self._tasks[taskId] = task
	return taskId
end

function Maid:DoCleaning()
	for index, task in pairs(self._tasks) do
		if typeof(task) == "RBXScriptConnection" then
			task:Disconnect()
		elseif type(task) == "function" then
			task()
		elseif type(task) == "table" and type(task.Destroy) == "function" then
			task:Destroy()
		elseif typeof(task) == "Instance" then
			task:Destroy()
		end
		self._tasks[index] = nil
	end
end

function Maid:Destroy()
	self:DoCleaning()
end

return Maid
end

-- [[ Module: Utility ]] --
modules["Utility"] = function()
-- Phantasm Utility Module
local TweenService = game:GetService("TweenService")
local TextService = game:GetService("TextService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

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

function Utility.Join(t1, t2)
    local t = {}
    for k,v in pairs(t1) do t[k] = v end
    for k,v in pairs(t2) do t[k] = v end
    return t
end

return Utility
end

-- [[ Module: ThemeManager ]] --
modules["ThemeManager"] = function()
-- Phantasm ThemeManager
local Signal = requireModule("Signal")

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
end

-- [[ Module: Creator ]] --
modules["Creator"] = function()
-- Phantasm Creator
local ThemeManager = requireModule("ThemeManager")

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
end

-- [[ Module: ConfigManager ]] --
modules["ConfigManager"] = function()
-- Phantasm ConfigManager
local HttpService = game:GetService("HttpService")

local ConfigManager = {}
ConfigManager.__index = ConfigManager

local function isCallable(func)
    return type(func) == "function" or (type(func) == "table" and getmetatable(func) and getmetatable(func).__call)
end

local function encodeValue(value)
    if typeof(value) == "Color3" then
        return { __type = "Color3", r = value.R, g = value.G, b = value.B }
    end
    if typeof(value) == "EnumItem" then
        return { __type = "Enum", name = tostring(value) }
    end
    return value
end

local function decodeEnum(name)
    if type(name) ~= "string" then
        return nil
    end
    local parts = string.split(name, ".")
    if #parts ~= 3 then
        return nil
    end
    local enumType = Enum[parts[2]]
    if not enumType then
        return nil
    end
    return enumType[parts[3]]
end

local function decodeValue(value)
    if type(value) == "table" and value.__type == "Color3" then
        return Color3.new(value.r or 0, value.g or 0, value.b or 0)
    end
    if type(value) == "table" and value.__type == "Enum" then
        return decodeEnum(value.name) or value
    end
    return value
end

function ConfigManager.new(folderPath, flagsTable)
    local self = setmetatable({}, ConfigManager)
    self.Folder = folderPath or "PhantasmSettings"
    self.Flags = flagsTable or {}
    self.Elements = {}
    self.MemoryStore = {}

    self.CanSave = isCallable(writefile)
        and isCallable(readfile)
        and isCallable(isfile)
        and isCallable(isfolder)
        and isCallable(makefolder)

    if self.CanSave then
        if not isfolder(self.Folder) then
            makefolder(self.Folder)
        end
    end

    return self
end

function ConfigManager:Register(flag, element)
    if not flag or not element then
        return false
    end
    self.Elements[flag] = element
    return true
end

function ConfigManager:_serialize()
    local data = {}
    for flag, value in pairs(self.Flags) do
        data[flag] = encodeValue(value)
    end
    return data
end

function ConfigManager:_apply(data, silent)
    for flag, value in pairs(data) do
        local decoded = decodeValue(value)
        self.Flags[flag] = decoded

        local element = self.Elements[flag]
        if element and type(element.Set) == "function" then
            pcall(function()
                element:Set(decoded, silent)
            end)
        end
    end
end

function ConfigManager:Export()
    return HttpService:JSONEncode(self:_serialize())
end

function ConfigManager:Import(json, silent)
    local ok, decoded = pcall(function()
        return HttpService:JSONDecode(json)
    end)
    if not ok then
        return false, "JSON Decode failed"
    end

    if silent == nil then
        silent = true
    end

    self:_apply(decoded, silent)
    return true
end

function ConfigManager:Save(name)
    if not name then
        return false, "No name provided"
    end

    local json = self:Export()

    if self.CanSave then
        writefile(self.Folder .. "/" .. name .. ".json", json)
        return true
    end

    self.MemoryStore[name] = json
    return true, "Saved to memory"
end

function ConfigManager:Load(name, silent)
    if not name then
        return false, "No name provided"
    end

    if silent == nil then
        silent = true
    end

    if self.CanSave then
        local path = self.Folder .. "/" .. name .. ".json"
        if not isfile(path) then
            return false, "File not found"
        end
        local content = readfile(path)
        return self:Import(content, silent)
    end

    local content = self.MemoryStore[name]
    if not content then
        return false, "No saved config in memory"
    end
    return self:Import(content, silent)
end

function ConfigManager:GetConfigs()
    if not (self.CanSave and isCallable(listfiles)) then
        return {}
    end
    if not isfolder(self.Folder) then
        makefolder(self.Folder)
    end

    local files = listfiles(self.Folder)
    local configs = {}
    for _, file in ipairs(files) do
        if file:sub(-5) == ".json" then
            local name = file:match("([^/\\]+)%.json$")
            table.insert(configs, name)
        end
    end
    return configs
end

return ConfigManager
end

-- [[ Module: Button ]] --
modules["Button"] = function()
-- Phantasm Button (UI-first remake)
local Creator = requireModule("Creator")
local Utility = requireModule("Utility")
local ThemeManager = requireModule("ThemeManager")
local Maid = requireModule("Maid")

local Button = {}
Button.__index = Button

function Button.new(container, options)
	local self = setmetatable({}, Button)

	options = options or {}
	self.Maid = Maid.new()
	self.Options = options
	self.Callback = options.Callback or function() end
	self.Disabled = false
	self.Locked = false
	self._baseTransparency = 0.25

	self.Frame = Creator.New("TextButton", {
		Parent = container,
		Size = UDim2.new(1, 0, 0, 42),
		BackgroundColor3 = "Surface2",
		BackgroundTransparency = self._baseTransparency,
		Text = "",
		AutoButtonColor = false,
		ThemeTag = { BackgroundColor3 = "Surface2" },
	})
	Creator.AddCorner(self.Frame, 12)
	Creator.AddStroke(self.Frame, {
		Color = "Outline",
		Thickness = 1,
		Transparency = 0.8,
		ThemeTag = { Color = "Outline" },
	})
	self.Maid:GiveTask(self.Frame)

	local rippleConn = Utility.AddRipple(self.Frame, ThemeManager:GetColor("Text"))
	self.Maid:GiveTask(rippleConn)

	self.TitleLabel = Creator.New("TextLabel", {
		Parent = self.Frame,
		Size = UDim2.new(1, -52, 1, 0),
		Position = UDim2.fromOffset(14, 0),
		BackgroundTransparency = 1,
		Text = options.Title or "Button",
		Font = Enum.Font.GothamMedium,
		TextSize = 13,
		TextColor3 = "Text",
		TextXAlignment = Enum.TextXAlignment.Left,
		ThemeTag = { TextColor3 = "Text" },
	})

	self.Icon = Creator.New("ImageLabel", {
		Parent = self.Frame,
		Size = UDim2.fromOffset(16, 16),
		Position = UDim2.new(1, -28, 0.5, -8),
		BackgroundTransparency = 1,
		Image = Utility.GetIcon("chevron-right"),
		ImageColor3 = "Icon",
		ThemeTag = { ImageColor3 = "Icon" },
	})

	self.Maid:GiveTask(self.Frame.MouseEnter:Connect(function()
		if self.Disabled or self.Locked then
			return
		end
		Utility.Tween(self.Frame, TweenInfo.new(0.12, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
			BackgroundTransparency = 0.12,
		})
	end))
	self.Maid:GiveTask(self.Frame.MouseLeave:Connect(function()
		if self.Disabled or self.Locked then
			return
		end
		Utility.Tween(self.Frame, TweenInfo.new(0.12, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
			BackgroundTransparency = self._baseTransparency,
		})
	end))

	self.Maid:GiveTask(self.Frame.MouseButton1Click:Connect(function()
		if self.Disabled or self.Locked then
			return
		end
		self.Callback()
	end))

	self:_syncState()
	return self
end

function Button:_syncState()
	local blocked = self.Disabled or self.Locked
	self.Frame.Active = not blocked
	self.Frame.BackgroundTransparency = blocked and 0.6 or self._baseTransparency
	self.TitleLabel.TextTransparency = blocked and 0.4 or 0
	if self.Icon then
		self.Icon.ImageTransparency = blocked and 0.4 or 0
	end
end

function Button:SetTitle(text)
	self.TitleLabel.Text = text
end

function Button:SetCallback(fn)
	self.Callback = fn or function() end
end

function Button:SetEnabled(enabled)
	self.Disabled = not enabled
	self:_syncState()
end

function Button:SetLocked(locked)
	self.Locked = locked and true or false
	self:_syncState()
end

function Button:Destroy()
	self.Maid:DoCleaning()
end

return Button
end

-- [[ Module: Toggle ]] --
modules["Toggle"] = function()
-- Phantasm Toggle (UI-first remake)
local Creator = requireModule("Creator")
local Utility = requireModule("Utility")
local ThemeManager = requireModule("ThemeManager")
local Maid = requireModule("Maid")

local Toggle = {}
Toggle.__index = Toggle

local function tweenToToken(instance, prop, token)
	local start = instance[prop]
	ThemeManager:Bind(instance, { [prop] = token })
	instance[prop] = start
	Utility.Tween(instance, TweenInfo.new(0.16, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
		[prop] = ThemeManager:GetColor(token),
	})
end

function Toggle.new(container, options, window)
	local self = setmetatable({}, Toggle)

	options = options or {}
	self.Maid = Maid.new()
	self.Window = window
	self.Options = options
	self.Value = options.Default == true
	self.Callback = options.Callback or function() end
	self.Flag = options.Flag
	self.Disabled = false
	self.Locked = false
	self._baseTransparency = 0.25

	if self.Flag and self.Window then
		self.Window.Flags[self.Flag] = self.Value
	end

	self.Frame = Creator.New("TextButton", {
		Parent = container,
		Size = UDim2.new(1, 0, 0, 42),
		BackgroundColor3 = "Surface2",
		BackgroundTransparency = self._baseTransparency,
		Text = "",
		AutoButtonColor = false,
		ThemeTag = { BackgroundColor3 = "Surface2" },
	})
	Creator.AddCorner(self.Frame, 12)
	Creator.AddStroke(self.Frame, { Color = "Outline", Thickness = 1, Transparency = 0.8, ThemeTag = { Color = "Outline" } })
	self.Maid:GiveTask(self.Frame)

	self.TitleLabel = Creator.New("TextLabel", {
		Parent = self.Frame,
		Size = UDim2.new(1, -70, 1, 0),
		Position = UDim2.fromOffset(14, 0),
		BackgroundTransparency = 1,
		Text = options.Title or "Toggle",
		Font = Enum.Font.GothamMedium,
		TextSize = 13,
		TextColor3 = "Text",
		TextXAlignment = Enum.TextXAlignment.Left,
		ThemeTag = { TextColor3 = "Text" },
	})

	self.Switch = Creator.New("Frame", {
		Parent = self.Frame,
		Size = UDim2.fromOffset(46, 24),
		Position = UDim2.new(1, -14 - 46, 0.5, -12),
		BackgroundColor3 = self.Value and "Accent" or "Surface2",
		BackgroundTransparency = 0.05,
		BorderSizePixel = 0,
		ThemeTag = { BackgroundColor3 = self.Value and "Accent" or "Surface2" },
	})
	Creator.AddCorner(self.Switch, 12)
	Creator.AddStroke(self.Switch, { Color = "Outline", Thickness = 1, Transparency = 0.75, ThemeTag = { Color = "Outline" } })

	self.Knob = Creator.New("Frame", {
		Parent = self.Switch,
		Size = UDim2.fromOffset(18, 18),
		Position = self.Value and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9),
		BackgroundColor3 = "Text",
		BorderSizePixel = 0,
		ThemeTag = { BackgroundColor3 = "Text" },
	})
	Creator.AddCorner(self.Knob, 9)

	self.Maid:GiveTask(self.Frame.MouseEnter:Connect(function()
		if self.Disabled or self.Locked then
			return
		end
		Utility.Tween(self.Frame, TweenInfo.new(0.12, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { BackgroundTransparency = 0.12 })
	end))
	self.Maid:GiveTask(self.Frame.MouseLeave:Connect(function()
		if self.Disabled or self.Locked then
			return
		end
		Utility.Tween(self.Frame, TweenInfo.new(0.12, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { BackgroundTransparency = self._baseTransparency })
	end))

	self.Maid:GiveTask(self.Frame.MouseButton1Click:Connect(function()
		if self.Disabled or self.Locked then
			return
		end
		self:Set(not self.Value)
	end))

	self:_syncState()
	return self
end

function Toggle:UpdateDisplay()
	local targetPos = self.Value and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)
	Utility.Tween(self.Knob, TweenInfo.new(0.16, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { Position = targetPos })

	tweenToToken(self.Switch, "BackgroundColor3", self.Value and "Accent" or "Surface2")
end

function Toggle:Set(val, silent)
	self.Value = val and true or false

	if self.Flag and self.Window then
		self.Window.Flags[self.Flag] = self.Value
	end

	self:UpdateDisplay()
	if not silent then
		if self.Flag and self.Window and type(self.Window._flagChanged) == "function" then
			self.Window:_flagChanged(self.Flag)
		end
		self.Callback(self.Value)
	end
end

function Toggle:Get()
	return self.Value
end

function Toggle:SetTitle(text)
	self.TitleLabel.Text = text
end

function Toggle:SetEnabled(enabled)
	self.Disabled = not enabled
	self:_syncState()
end

function Toggle:SetLocked(locked)
	self.Locked = locked and true or false
	self:_syncState()
end

function Toggle:_syncState()
	local blocked = self.Disabled or self.Locked
	self.Frame.Active = not blocked
	self.Frame.BackgroundTransparency = blocked and 0.6 or self._baseTransparency
	self.TitleLabel.TextTransparency = blocked and 0.4 or 0
	self.Switch.BackgroundTransparency = blocked and 0.4 or 0.05
end

function Toggle:Destroy()
	self.Maid:DoCleaning()
end

return Toggle
end

-- [[ Module: Slider ]] --
modules["Slider"] = function()
-- Phantasm Slider (UI-first remake)
local UserInputService = game:GetService("UserInputService")

local Creator = requireModule("Creator")
local Utility = requireModule("Utility")
local ThemeManager = requireModule("ThemeManager")
local Maid = requireModule("Maid")

local Slider = {}
Slider.__index = Slider

function Slider.new(container, options, window)
	local self = setmetatable({}, Slider)

	options = options or {}
	self.Maid = Maid.new()
	self.Window = window
	self.Options = options

	self.Min = tonumber(options.Min) or 0
	self.Max = tonumber(options.Max) or 100
	self.Step = tonumber(options.Step) or 1
	if self.Step <= 0 then
		self.Step = 1
	end

	self.Value = tonumber(options.Default) or self.Min
	self.Callback = options.Callback or function() end
	self.Flag = options.Flag
	self.Disabled = false
	self.Locked = false
	self._baseTransparency = 0.25

	if self.Flag and self.Window then
		self.Window.Flags[self.Flag] = self.Value
	end

	self.Frame = Creator.New("Frame", {
		Parent = container,
		Size = UDim2.new(1, 0, 0, 56),
		BackgroundColor3 = "Surface2",
		BackgroundTransparency = self._baseTransparency,
		BorderSizePixel = 0,
		ThemeTag = { BackgroundColor3 = "Surface2" },
	})
	Creator.AddCorner(self.Frame, 12)
	Creator.AddStroke(self.Frame, { Color = "Outline", Thickness = 1, Transparency = 0.8, ThemeTag = { Color = "Outline" } })
	Creator.AddPadding(self.Frame, 14)
	self.Maid:GiveTask(self.Frame)

	self.TitleLabel = Creator.New("TextLabel", {
		Parent = self.Frame,
		Size = UDim2.new(1, -70, 0, 18),
		BackgroundTransparency = 1,
		Text = options.Title or "Slider",
		Font = Enum.Font.GothamMedium,
		TextSize = 13,
		TextColor3 = "Text",
		TextXAlignment = Enum.TextXAlignment.Left,
		ThemeTag = { TextColor3 = "Text" },
	})

	self.ValueLabel = Creator.New("TextLabel", {
		Parent = self.Frame,
		Size = UDim2.new(0, 70, 0, 18),
		Position = UDim2.new(1, -70, 0, 0),
		BackgroundTransparency = 1,
		Text = "",
		Font = Enum.Font.Gotham,
		TextSize = 13,
		TextColor3 = "SubText",
		TextXAlignment = Enum.TextXAlignment.Right,
		ThemeTag = { TextColor3 = "SubText" },
	})

	self.Bar = Creator.New("TextButton", {
		Parent = self.Frame,
		Size = UDim2.new(1, 0, 0, 8),
		Position = UDim2.new(0, 0, 0, 30),
		BackgroundColor3 = "Surface",
		BackgroundTransparency = 0.35,
		Text = "",
		AutoButtonColor = false,
		BorderSizePixel = 0,
		ThemeTag = { BackgroundColor3 = "Surface" },
	})
	Creator.AddCorner(self.Bar, 8)

	self.Fill = Creator.New("Frame", {
		Parent = self.Bar,
		Size = UDim2.new(0, 0, 1, 0),
		BackgroundColor3 = "Accent",
		BorderSizePixel = 0,
		ThemeTag = { BackgroundColor3 = "Accent" },
	})
	Creator.AddCorner(self.Fill, 8)

	self.Knob = Creator.New("Frame", {
		Parent = self.Bar,
		Size = UDim2.fromOffset(14, 14),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0, 0, 0.5, 0),
		BackgroundColor3 = "Text",
		BorderSizePixel = 0,
		ThemeTag = { BackgroundColor3 = "Text" },
	})
	Creator.AddCorner(self.Knob, 7)

	local dragging = false

	local function setFromX(x)
		if self.Disabled or self.Locked then
			return
		end
		local barX = self.Bar.AbsolutePosition.X
		local barW = self.Bar.AbsoluteSize.X
		if barW <= 1 then
			return
		end
		local alpha = math.clamp((x - barX) / barW, 0, 1)
		local raw = self.Min + ((self.Max - self.Min) * alpha)
		local stepped = math.floor((raw / self.Step) + 0.5) * self.Step
		self:Set(stepped)
	end

	self.Maid:GiveTask(self.Bar.InputBegan:Connect(function(input)
		if self.Disabled or self.Locked then
			return
		end
		if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then
			return
		end
		dragging = true
		setFromX(input.Position.X)
	end))

	self.Maid:GiveTask(UserInputService.InputChanged:Connect(function(input)
		if self.Disabled or self.Locked then
			return
		end
		if not dragging then
			return
		end
		if input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch then
			return
		end
		setFromX(input.Position.X)
	end))

	self.Maid:GiveTask(UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end))

	self:Set(self.Value)
	self:_syncState()
	return self
end

function Slider:Set(value, silent)
	value = tonumber(value) or self.Min
	value = math.clamp(value, self.Min, self.Max)

	self.Value = value

	local range = (self.Max - self.Min)
	local alpha = 0
	if range ~= 0 then
		alpha = (self.Value - self.Min) / range
	end

	Utility.Tween(self.Fill, TweenInfo.new(0.12, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
		Size = UDim2.new(alpha, 0, 1, 0),
	})
	Utility.Tween(self.Knob, TweenInfo.new(0.12, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
		Position = UDim2.new(alpha, 0, 0.5, 0),
	})

	local prefix = self.Options.Prefix or ""
	local suffix = self.Options.Suffix or ""
	self.ValueLabel.Text = prefix .. tostring(self.Value) .. suffix

	if self.Flag and self.Window then
		self.Window.Flags[self.Flag] = self.Value
	end
	if not silent then
		if self.Flag and self.Window and type(self.Window._flagChanged) == "function" then
			self.Window:_flagChanged(self.Flag)
		end
		self.Callback(self.Value)
	end
end

function Slider:Get()
	return self.Value
end

function Slider:SetEnabled(enabled)
	self.Disabled = not enabled
	self:_syncState()
end

function Slider:SetLocked(locked)
	self.Locked = locked and true or false
	self:_syncState()
end

function Slider:_syncState()
	local blocked = self.Disabled or self.Locked
	self.Frame.BackgroundTransparency = blocked and 0.6 or self._baseTransparency
	self.TitleLabel.TextTransparency = blocked and 0.4 or 0
	self.ValueLabel.TextTransparency = blocked and 0.5 or 0
	self.Bar.Active = not blocked
end

function Slider:Destroy()
	self.Maid:DoCleaning()
end

return Slider
end

-- [[ Module: Dropdown ]] --
modules["Dropdown"] = function()
-- Phantasm Dropdown (UI-first remake)
local Creator = requireModule("Creator")
local Utility = requireModule("Utility")
local ThemeManager = requireModule("ThemeManager")
local Maid = requireModule("Maid")

local Dropdown = {}
Dropdown.__index = Dropdown

local function orderedMultiText(values, map)
	local out = {}
	for _, v in ipairs(values) do
		if map[v] then
			table.insert(out, v)
		end
	end
	return #out > 0 and table.concat(out, ", ") or "None"
end

function Dropdown.new(container, options, window)
	local self = setmetatable({}, Dropdown)

	options = options or {}
	self.Maid = Maid.new()
	self.Window = window
	self.Options = options

	self.Values = options.Values or {}
	self.Multi = options.Multi == true
	self.AllowNone = options.AllowNone == true
	self.Callback = options.Callback or function() end
	self.Flag = options.Flag
	self.Disabled = false
	self.Locked = false
	self._baseTransparency = 0.25

	if self.Multi then
		self.Value = options.Default or {}
	else
		self.Value = options.Default or (self.Values[1] or "")
	end

	if self.Flag and self.Window then
		self.Window.Flags[self.Flag] = self.Value
	end

	self.Frame = Creator.New("Frame", {
		Parent = container,
		Size = UDim2.new(1, 0, 0, 70),
		BackgroundColor3 = "Surface2",
		BackgroundTransparency = self._baseTransparency,
		BorderSizePixel = 0,
		ThemeTag = { BackgroundColor3 = "Surface2" },
	})
	Creator.AddCorner(self.Frame, 12)
	Creator.AddStroke(self.Frame, { Color = "Outline", Thickness = 1, Transparency = 0.8, ThemeTag = { Color = "Outline" } })
	Creator.AddPadding(self.Frame, 14)
	self.Maid:GiveTask(self.Frame)

	self.TitleLabel = Creator.New("TextLabel", {
		Parent = self.Frame,
		Size = UDim2.new(1, 0, 0, 18),
		BackgroundTransparency = 1,
		Text = options.Title or "Dropdown",
		Font = Enum.Font.GothamMedium,
		TextSize = 13,
		TextColor3 = "Text",
		TextXAlignment = Enum.TextXAlignment.Left,
		ThemeTag = { TextColor3 = "Text" },
	})

	self.Display = Creator.New("TextButton", {
		Parent = self.Frame,
		Size = UDim2.new(1, 0, 0, 34),
		Position = UDim2.new(0, 0, 0, 26),
		BackgroundColor3 = "Surface",
		BackgroundTransparency = 0.25,
		Text = "",
		AutoButtonColor = false,
		BorderSizePixel = 0,
		ThemeTag = { BackgroundColor3 = "Surface" },
	})
	Creator.AddCorner(self.Display, 10)
	Creator.AddStroke(self.Display, { Color = "Outline", Thickness = 1, Transparency = 0.85, ThemeTag = { Color = "Outline" } })

	self.DisplayLabel = Creator.New("TextLabel", {
		Parent = self.Display,
		Size = UDim2.new(1, -34, 1, 0),
		Position = UDim2.fromOffset(12, 0),
		BackgroundTransparency = 1,
		Text = "",
		Font = Enum.Font.Gotham,
		TextSize = 13,
		TextColor3 = "SubText",
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
		ThemeTag = { TextColor3 = "SubText" },
	})

	self.Chevron = Creator.New("ImageLabel", {
		Parent = self.Display,
		Size = UDim2.fromOffset(16, 16),
		Position = UDim2.new(1, -24, 0.5, -8),
		BackgroundTransparency = 1,
		Image = Utility.GetIcon("chevron-down"),
		ImageColor3 = "Icon",
		ThemeTag = { ImageColor3 = "Icon" },
	})

	self.Opened = false
	self.Overlay = nil
	self.ListFrame = nil
	self.SearchBox = nil
	self.Scroll = nil
	self.PopupMaid = nil

	self.Maid:GiveTask(self.Display.MouseButton1Click:Connect(function()
		if self.Disabled or self.Locked then
			return
		end
		self:Toggle()
	end))

	if self.Window and self.Window.OnClose then
		self.Maid:GiveTask(self.Window.OnClose:Connect(function()
			self:Close()
		end))
	end

	self:UpdateDisplay(true)
	self:_syncState()
	return self
end

function Dropdown:GetText()
	if self.Multi then
		return orderedMultiText(self.Values, self.Value)
	end
	return tostring(self.Value)
end

function Dropdown:UpdateDisplay(silent)
	self.DisplayLabel.Text = self:GetText()
	if self.Flag and self.Window then
		self.Window.Flags[self.Flag] = self.Value
		if not silent and type(self.Window._flagChanged) == "function" then
			self.Window:_flagChanged(self.Flag)
		end
	end
end

function Dropdown:Toggle()
	if self.Opened then
		self:Close()
	else
		self:Open()
	end
end

function Dropdown:_buildList(filterText)
	if not self.Scroll then
		return
	end

	for _, child in ipairs(self.Scroll:GetChildren()) do
		if child:IsA("GuiObject") then
			child:Destroy()
		end
	end

	local function matches(value)
		if not filterText or filterText == "" then
			return true
		end
		return string.find(string.lower(value), string.lower(filterText), 1, true) ~= nil
	end

	for _, value in ipairs(self.Values) do
		if matches(value) then
			local row = Creator.New("TextButton", {
				Parent = self.Scroll,
				Size = UDim2.new(1, 0, 0, 32),
				BackgroundColor3 = "Surface2",
				BackgroundTransparency = 1,
				Text = "",
				AutoButtonColor = false,
				BorderSizePixel = 0,
				ThemeTag = { BackgroundColor3 = "Surface2" },
			})
			Creator.AddCorner(row, 10)

			local label = Creator.New("TextLabel", {
				Parent = row,
				Size = UDim2.new(1, -44, 1, 0),
				Position = UDim2.fromOffset(12, 0),
				BackgroundTransparency = 1,
				Text = value,
				Font = Enum.Font.Gotham,
				TextSize = 13,
				TextColor3 = "SubText",
				TextXAlignment = Enum.TextXAlignment.Left,
				TextTruncate = Enum.TextTruncate.AtEnd,
				ThemeTag = { TextColor3 = "SubText" },
			})

			local check = Creator.New("ImageLabel", {
				Parent = row,
				Size = UDim2.fromOffset(16, 16),
				Position = UDim2.new(1, -24, 0.5, -8),
				BackgroundTransparency = 1,
				Image = Utility.GetIcon("check"),
				ImageColor3 = "Accent",
				Visible = false,
				ThemeTag = { ImageColor3 = "Accent" },
			})

			local selected = false
			if self.Multi then
				selected = self.Value[value] == true
			else
				selected = self.Value == value
			end
			if selected then
				label.TextColor3 = ThemeManager:GetColor("Text")
				ThemeManager:Bind(label, { TextColor3 = "Text" })
				check.Visible = true
			end

			row.MouseEnter:Connect(function()
				Utility.Tween(row, TweenInfo.new(0.12, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { BackgroundTransparency = 0.6 })
			end)
			row.MouseLeave:Connect(function()
				Utility.Tween(row, TweenInfo.new(0.12, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { BackgroundTransparency = 1 })
			end)

			row.MouseButton1Click:Connect(function()
				if self.Multi then
					if self.Value[value] then
						self.Value[value] = nil
					else
						self.Value[value] = true
					end
					self.Callback(self.Value)
					self:UpdateDisplay()
					self:_buildList(self.SearchBox and self.SearchBox.Text or "")
				else
					self.Value = value
					self.Callback(self.Value)
					self:UpdateDisplay()
					self:Close()
				end
			end)
		end
	end
end

function Dropdown:Open()
	if self.Disabled or self.Locked then
		return
	end
	if self.Opened then
		return
	end
	self.Opened = true

	if self.PopupMaid then
		self.PopupMaid:DoCleaning()
	end
	self.PopupMaid = Maid.new()

	Utility.Tween(self.Chevron, TweenInfo.new(0.12, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { Rotation = 180 })

	local main = self.Window and self.Window.Main or self.Display

	self.Overlay = Instance.new("TextButton")
	self.Overlay.Name = "DropdownOverlay"
	self.Overlay.BackgroundTransparency = 1
	self.Overlay.Text = ""
	self.Overlay.AutoButtonColor = false
	self.Overlay.Size = UDim2.fromScale(1, 1)
	self.Overlay.ZIndex = 90
	self.Overlay.Parent = main

	self.PopupMaid:GiveTask(self.Overlay.MouseButton1Click:Connect(function()
		self:Close()
	end))

	self.ListFrame = Creator.New("Frame", {
		Parent = main,
		Size = UDim2.fromOffset(self.Display.AbsoluteSize.X, 0),
		BackgroundColor3 = "Surface",
		BackgroundTransparency = 0.08,
		BorderSizePixel = 0,
		ZIndex = 100,
		ThemeTag = { BackgroundColor3 = "Surface" },
	})
	Creator.AddCorner(self.ListFrame, 12)
	Creator.AddStroke(self.ListFrame, { Color = "Outline", Thickness = 1, Transparency = 0.7, ThemeTag = { Color = "Outline" } })

	local mainAbs = main.AbsolutePosition
	local dispAbs = self.Display.AbsolutePosition
	local relX = dispAbs.X - mainAbs.X
	local relY = dispAbs.Y - mainAbs.Y + self.Display.AbsoluteSize.Y + 8

	local maxHeight = 240
	local desired = (math.min(#self.Values, 8) * 32) + 40
	local targetHeight = math.min(desired, maxHeight)

	-- Flip upward if needed (keep list inside window bounds)
	if relY + targetHeight > main.AbsoluteSize.Y - 10 then
		relY = (dispAbs.Y - mainAbs.Y) - targetHeight - 8
	end

	self.ListFrame.Position = UDim2.fromOffset(relX, relY)

	self.SearchBox = Creator.New("TextBox", {
		Parent = self.ListFrame,
		Size = UDim2.new(1, -20, 0, 30),
		Position = UDim2.fromOffset(10, 10),
		BackgroundColor3 = "Surface2",
		BackgroundTransparency = 0.25,
		Text = "",
		PlaceholderText = "Search",
		Font = Enum.Font.Gotham,
		TextSize = 13,
		TextColor3 = "Text",
		PlaceholderColor3 = "Placeholder",
		ClearTextOnFocus = false,
		BorderSizePixel = 0,
		ZIndex = 101,
		ThemeTag = { BackgroundColor3 = "Surface2", TextColor3 = "Text", PlaceholderColor3 = "Placeholder" },
	})
	Creator.AddCorner(self.SearchBox, 10)

	self.Scroll = Creator.New("ScrollingFrame", {
		Parent = self.ListFrame,
		Size = UDim2.new(1, -20, 1, -50),
		Position = UDim2.fromOffset(10, 44),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 3,
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		CanvasSize = UDim2.new(0, 0, 0, 0),
		ZIndex = 101,
	})

	local layout = Instance.new("UIListLayout")
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Padding = UDim.new(0, 6)
	layout.Parent = self.Scroll

	self.PopupMaid:GiveTask(self.SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
		self:_buildList(self.SearchBox.Text)
	end))

	self:_buildList("")

	Utility.Tween(self.ListFrame, TweenInfo.new(0.16, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
		Size = UDim2.fromOffset(self.Display.AbsoluteSize.X, targetHeight),
	})
end

function Dropdown:Close()
	if not self.Opened then
		return
	end
	self.Opened = false

	if self.PopupMaid then
		self.PopupMaid:DoCleaning()
		self.PopupMaid = nil
	end

	Utility.Tween(self.Chevron, TweenInfo.new(0.12, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { Rotation = 0 })

	if self.Overlay then
		self.Overlay:Destroy()
		self.Overlay = nil
	end

	if self.ListFrame then
		local frame = self.ListFrame
		self.ListFrame = nil
		self.SearchBox = nil
		self.Scroll = nil
		Utility.Tween(frame, TweenInfo.new(0.14, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
			Size = UDim2.fromOffset(frame.AbsoluteSize.X, 0),
		}, function()
			if frame then
				frame:Destroy()
			end
		end)
	end
end

function Dropdown:Set(val, silent)
	if self.Multi then
		self.Value = val or {}
	else
		self.Value = val
	end
	self:UpdateDisplay(silent)
	if not silent then
		self.Callback(self.Value)
	end
end

function Dropdown:Get()
	return self.Value
end

function Dropdown:Refresh(newVals)
	self.Values = newVals or {}
	if not self.Multi then
		if not table.find(self.Values, self.Value) then
			self.Value = self.Values[1] or ""
		end
	end
	self:UpdateDisplay()
	if self.Opened then
		self:_buildList(self.SearchBox and self.SearchBox.Text or "")
	end
end

function Dropdown:SetEnabled(enabled)
	self.Disabled = not enabled
	self:_syncState()
	if self.Disabled then
		self:Close()
	end
end

function Dropdown:SetLocked(locked)
	self.Locked = locked and true or false
	self:_syncState()
	if self.Locked then
		self:Close()
	end
end

function Dropdown:_syncState()
	local blocked = self.Disabled or self.Locked
	self.Frame.BackgroundTransparency = blocked and 0.6 or self._baseTransparency
	self.Display.BackgroundTransparency = blocked and 0.5 or 0.25
	self.TitleLabel.TextTransparency = blocked and 0.4 or 0
	self.DisplayLabel.TextTransparency = blocked and 0.35 or 0
	if self.Chevron then
		self.Chevron.ImageTransparency = blocked and 0.35 or 0
	end
	self.Display.Active = not blocked
end

function Dropdown:Destroy()
	self:Close()
	self.Maid:DoCleaning()
end

return Dropdown
end

-- [[ Module: Input ]] --
modules["Input"] = function()
-- Phantasm Input (UI-first remake)
local Creator = requireModule("Creator")
local Maid = requireModule("Maid")

local Input = {}
Input.__index = Input

function Input.new(container, options, window)
	local self = setmetatable({}, Input)

	options = options or {}
	self.Maid = Maid.new()
	self.Window = window
	self.Options = options

	self.Value = options.Default or ""
	self.Callback = options.Callback or function() end
	self.Flag = options.Flag
	self.Numeric = options.Numeric == true
	self.Disabled = false
	self.Locked = false
	self._baseTransparency = 0.25

	if self.Flag and self.Window then
		self.Window.Flags[self.Flag] = self.Value
	end

	self.Frame = Creator.New("Frame", {
		Parent = container,
		Size = UDim2.new(1, 0, 0, 70),
		BackgroundColor3 = "Surface2",
		BackgroundTransparency = self._baseTransparency,
		BorderSizePixel = 0,
		ThemeTag = { BackgroundColor3 = "Surface2" },
	})
	Creator.AddCorner(self.Frame, 12)
	Creator.AddStroke(self.Frame, { Color = "Outline", Thickness = 1, Transparency = 0.8, ThemeTag = { Color = "Outline" } })
	Creator.AddPadding(self.Frame, 14)
	self.Maid:GiveTask(self.Frame)

	self.TitleLabel = Creator.New("TextLabel", {
		Parent = self.Frame,
		Size = UDim2.new(1, 0, 0, 18),
		BackgroundTransparency = 1,
		Text = options.Title or "Input",
		Font = Enum.Font.GothamMedium,
		TextSize = 13,
		TextColor3 = "Text",
		TextXAlignment = Enum.TextXAlignment.Left,
		ThemeTag = { TextColor3 = "Text" },
	})

	self.BoxFrame = Creator.New("Frame", {
		Parent = self.Frame,
		Size = UDim2.new(1, 0, 0, 34),
		Position = UDim2.new(0, 0, 0, 26),
		BackgroundColor3 = "Surface",
		BackgroundTransparency = 0.25,
		BorderSizePixel = 0,
		ThemeTag = { BackgroundColor3 = "Surface" },
	})
	Creator.AddCorner(self.BoxFrame, 10)
	Creator.AddStroke(self.BoxFrame, { Color = "Outline", Thickness = 1, Transparency = 0.85, ThemeTag = { Color = "Outline" } })

	self.Box = Creator.New("TextBox", {
		Parent = self.BoxFrame,
		Size = UDim2.new(1, -22, 1, 0),
		Position = UDim2.fromOffset(12, 0),
		BackgroundTransparency = 1,
		Text = tostring(self.Value),
		PlaceholderText = options.Placeholder or "Enter text...",
		Font = Enum.Font.Gotham,
		TextSize = 13,
		TextColor3 = "Text",
		PlaceholderColor3 = "Placeholder",
		TextXAlignment = Enum.TextXAlignment.Left,
		ClearTextOnFocus = false,
		ThemeTag = { TextColor3 = "Text", PlaceholderColor3 = "Placeholder" },
	})

	self.Maid:GiveTask(self.Box.FocusLost:Connect(function(enterPressed)
		if self.Disabled or self.Locked then
			self.Box.Text = tostring(self.Value)
			return
		end
		local raw = self.Box.Text
		local val = raw

		if self.Numeric then
			local num = tonumber(raw)
			if num == nil then
				self.Box.Text = tostring(self.Value)
				return
			end
			val = num
		end

		self:Set(val)

		if type(options.Finished) == "function" and enterPressed then
			options.Finished(val)
		end
	end))

	self:_syncState()
	return self
end

function Input:Set(val, silent)
	self.Value = val
	self.Box.Text = tostring(val)

	if self.Flag and self.Window then
		self.Window.Flags[self.Flag] = self.Value
	end
	if not silent then
		if self.Flag and self.Window and type(self.Window._flagChanged) == "function" then
			self.Window:_flagChanged(self.Flag)
		end
		self.Callback(self.Value)
	end
end

function Input:Get()
	return self.Value
end

function Input:SetEnabled(enabled)
	self.Disabled = not enabled
	self:_syncState()
end

function Input:SetLocked(locked)
	self.Locked = locked and true or false
	self:_syncState()
end

function Input:_syncState()
	local blocked = self.Disabled or self.Locked
	self.Frame.BackgroundTransparency = blocked and 0.6 or self._baseTransparency
	self.TitleLabel.TextTransparency = blocked and 0.4 or 0
	self.Box.TextTransparency = blocked and 0.4 or 0
	self.Box.Active = not blocked
	pcall(function()
		self.Box.TextEditable = not blocked
	end)
end

function Input:Destroy()
	self.Maid:DoCleaning()
end

return Input
end

-- [[ Module: Keybind ]] --
modules["Keybind"] = function()
-- Phantasm Keybind (UI-first remake)
local UserInputService = game:GetService("UserInputService")

local Creator = requireModule("Creator")
local Utility = requireModule("Utility")
local Maid = requireModule("Maid")

local Keybind = {}
Keybind.__index = Keybind

function Keybind.new(container, options, window)
	local self = setmetatable({}, Keybind)

	options = options or {}
	self.Maid = Maid.new()
	self.Window = window
	self.Options = options

	self.Value = options.Default -- Enum.KeyCode?
	self.Callback = options.Callback or function() end
	self.Flag = options.Flag
	self.Binding = false
	self.Disabled = false
	self.Locked = false
	self._baseTransparency = 0.25

	if self.Flag and self.Window then
		self.Window.Flags[self.Flag] = self.Value
	end

	self.Frame = Creator.New("Frame", {
		Parent = container,
		Size = UDim2.new(1, 0, 0, 42),
		BackgroundColor3 = "Surface2",
		BackgroundTransparency = self._baseTransparency,
		BorderSizePixel = 0,
		ThemeTag = { BackgroundColor3 = "Surface2" },
	})
	Creator.AddCorner(self.Frame, 12)
	Creator.AddStroke(self.Frame, { Color = "Outline", Thickness = 1, Transparency = 0.8, ThemeTag = { Color = "Outline" } })
	self.Maid:GiveTask(self.Frame)

	self.TitleLabel = Creator.New("TextLabel", {
		Parent = self.Frame,
		Size = UDim2.new(1, -110, 1, 0),
		Position = UDim2.fromOffset(14, 0),
		BackgroundTransparency = 1,
		Text = options.Title or "Keybind",
		Font = Enum.Font.GothamMedium,
		TextSize = 13,
		TextColor3 = "Text",
		TextXAlignment = Enum.TextXAlignment.Left,
		ThemeTag = { TextColor3 = "Text" },
	})

	self.Button = Creator.New("TextButton", {
		Parent = self.Frame,
		Size = UDim2.fromOffset(92, 30),
		Position = UDim2.new(1, -14 - 92, 0.5, -15),
		BackgroundColor3 = "Surface",
		BackgroundTransparency = 0.25,
		Text = "",
		AutoButtonColor = false,
		BorderSizePixel = 0,
		ThemeTag = { BackgroundColor3 = "Surface" },
	})
	Creator.AddCorner(self.Button, 10)
	Creator.AddStroke(self.Button, { Color = "Outline", Thickness = 1, Transparency = 0.85, ThemeTag = { Color = "Outline" } })

	self.BindLabel = Creator.New("TextLabel", {
		Parent = self.Button,
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		Text = self.Value and self.Value.Name or "None",
		Font = Enum.Font.Gotham,
		TextSize = 12,
		TextColor3 = "SubText",
		TextTruncate = Enum.TextTruncate.AtEnd,
		ThemeTag = { TextColor3 = "SubText" },
	})

	self.Maid:GiveTask(self.Button.MouseButton1Click:Connect(function()
		if self.Disabled or self.Locked then
			return
		end
		self.Binding = true
		self.BindLabel.Text = "..."
	end))

	self.Maid:GiveTask(UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if self.Disabled or self.Locked then
			return
		end
		if gameProcessed then
			return
		end

		if self.Binding then
			if input.UserInputType == Enum.UserInputType.Keyboard then
				self.Binding = false
				if input.KeyCode == Enum.KeyCode.Escape then
					self:Set(nil)
				else
					self:Set(input.KeyCode)
				end
			elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
				self.Binding = false
				self:Set(nil)
			end
			return
		end

		if self.Value and input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == self.Value then
			self.Callback()
		end
	end))

	self.Maid:GiveTask(self.Frame.MouseEnter:Connect(function()
		if self.Disabled or self.Locked then
			return
		end
		Utility.Tween(self.Frame, TweenInfo.new(0.12, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { BackgroundTransparency = 0.12 })
	end))
	self.Maid:GiveTask(self.Frame.MouseLeave:Connect(function()
		if self.Disabled or self.Locked then
			return
		end
		Utility.Tween(self.Frame, TweenInfo.new(0.12, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { BackgroundTransparency = self._baseTransparency })
	end))

	self:_syncState()
	return self
end

function Keybind:Set(keyCode, silent)
	self.Value = keyCode
	self.BindLabel.Text = keyCode and keyCode.Name or "None"

	if self.Flag and self.Window then
		self.Window.Flags[self.Flag] = self.Value
		if not silent and type(self.Window._flagChanged) == "function" then
			self.Window:_flagChanged(self.Flag)
		end
	end
end

function Keybind:Get()
	return self.Value
end

function Keybind:SetEnabled(enabled)
	self.Disabled = not enabled
	self:_syncState()
end

function Keybind:SetLocked(locked)
	self.Locked = locked and true or false
	self:_syncState()
end

function Keybind:_syncState()
	local blocked = self.Disabled or self.Locked
	self.Frame.BackgroundTransparency = blocked and 0.6 or self._baseTransparency
	self.TitleLabel.TextTransparency = blocked and 0.4 or 0
	self.BindLabel.TextTransparency = blocked and 0.4 or 0
	self.Button.Active = not blocked
end

function Keybind:Destroy()
	self.Maid:DoCleaning()
end

return Keybind
end

-- [[ Module: ColorPicker ]] --
modules["ColorPicker"] = function()
-- Phantasm ColorPicker (UI-first remake)
local UserInputService = game:GetService("UserInputService")

local Creator = requireModule("Creator")
local Utility = requireModule("Utility")
local Maid = requireModule("Maid")

local ColorPicker = {}
ColorPicker.__index = ColorPicker

local function clamp01(x)
	return math.clamp(x, 0, 1)
end

function ColorPicker.new(container, options, window)
	local self = setmetatable({}, ColorPicker)

	options = options or {}
	self.Maid = Maid.new()
	self.PopupMaid = nil
	self.Window = window
	self.Options = options

	self.Value = options.Default or Color3.new(1, 1, 1)
	self.Callback = options.Callback or function() end
	self.Flag = options.Flag
	self.Disabled = false
	self.Locked = false
	self._baseTransparency = 0.25

	if self.Flag and self.Window then
		self.Window.Flags[self.Flag] = self.Value
	end

	self.Frame = Creator.New("TextButton", {
		Parent = container,
		Size = UDim2.new(1, 0, 0, 42),
		BackgroundColor3 = "Surface2",
		BackgroundTransparency = self._baseTransparency,
		Text = "",
		AutoButtonColor = false,
		BorderSizePixel = 0,
		ThemeTag = { BackgroundColor3 = "Surface2" },
	})
	Creator.AddCorner(self.Frame, 12)
	Creator.AddStroke(self.Frame, { Color = "Outline", Thickness = 1, Transparency = 0.8, ThemeTag = { Color = "Outline" } })
	self.Maid:GiveTask(self.Frame)

	self.TitleLabel = Creator.New("TextLabel", {
		Parent = self.Frame,
		Size = UDim2.new(1, -70, 1, 0),
		Position = UDim2.fromOffset(14, 0),
		BackgroundTransparency = 1,
		Text = options.Title or "ColorPicker",
		Font = Enum.Font.GothamMedium,
		TextSize = 13,
		TextColor3 = "Text",
		TextXAlignment = Enum.TextXAlignment.Left,
		ThemeTag = { TextColor3 = "Text" },
	})

	self.Indicator = Creator.New("Frame", {
		Parent = self.Frame,
		Size = UDim2.fromOffset(46, 24),
		Position = UDim2.new(1, -14 - 46, 0.5, -12),
		BackgroundColor3 = self.Value,
		BorderSizePixel = 0,
	})
	Creator.AddCorner(self.Indicator, 10)
	Creator.AddStroke(self.Indicator, { Color = "Outline", Thickness = 1, Transparency = 0.75, ThemeTag = { Color = "Outline" } })

	self.Maid:GiveTask(self.Frame.MouseButton1Click:Connect(function()
		if self.Disabled or self.Locked then
			return
		end
		self:Toggle()
	end))

	self.Maid:GiveTask(self.Frame.MouseEnter:Connect(function()
		if self.Disabled or self.Locked then
			return
		end
		Utility.Tween(self.Frame, TweenInfo.new(0.12, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { BackgroundTransparency = 0.12 })
	end))
	self.Maid:GiveTask(self.Frame.MouseLeave:Connect(function()
		if self.Disabled or self.Locked then
			return
		end
		Utility.Tween(self.Frame, TweenInfo.new(0.12, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { BackgroundTransparency = self._baseTransparency })
	end))

	if self.Window and self.Window.OnClose then
		self.Maid:GiveTask(self.Window.OnClose:Connect(function()
			self:Close()
		end))
	end

	self:_syncState()
	return self
end

function ColorPicker:_setChannel(channel, v01)
	v01 = clamp01(v01)
	local r, g, b = self.Value.R, self.Value.G, self.Value.B
	if channel == "R" then
		r = v01
	elseif channel == "G" then
		g = v01
	elseif channel == "B" then
		b = v01
	end
	self:Set(Color3.new(r, g, b))
end

function ColorPicker:_updatePopup()
	if not self.PopupFrame then
		return
	end
	self.Preview.BackgroundColor3 = self.Value

	if self.Sliders then
		self.Sliders.R.Fill.Size = UDim2.new(self.Value.R, 0, 1, 0)
		self.Sliders.G.Fill.Size = UDim2.new(self.Value.G, 0, 1, 0)
		self.Sliders.B.Fill.Size = UDim2.new(self.Value.B, 0, 1, 0)
		self.Sliders.R.Knob.Position = UDim2.new(self.Value.R, 0, 0.5, 0)
		self.Sliders.G.Knob.Position = UDim2.new(self.Value.G, 0, 0.5, 0)
		self.Sliders.B.Knob.Position = UDim2.new(self.Value.B, 0, 0.5, 0)
	end
end

function ColorPicker:Open()
	if self.Disabled or self.Locked then
		return
	end
	if self.PopupFrame then
		return
	end

	if self.PopupMaid then
		self.PopupMaid:DoCleaning()
	end
	self.PopupMaid = Maid.new()

	local main = self.Window and self.Window.Main or self.Frame

	local overlay = Instance.new("TextButton")
	overlay.Name = "ColorPickerOverlay"
	overlay.BackgroundTransparency = 1
	overlay.Text = ""
	overlay.AutoButtonColor = false
	overlay.Size = UDim2.fromScale(1, 1)
	overlay.ZIndex = 90
	overlay.Parent = main
	self.PopupMaid:GiveTask(overlay)

	self.PopupMaid:GiveTask(overlay.MouseButton1Click:Connect(function()
		self:Close()
	end))

	self.PopupFrame = Creator.New("Frame", {
		Parent = main,
		Size = UDim2.fromOffset(280, 190),
		BackgroundColor3 = "Surface",
		BackgroundTransparency = 0.08,
		BorderSizePixel = 0,
		ZIndex = 100,
		ThemeTag = { BackgroundColor3 = "Surface" },
	})
	Creator.AddCorner(self.PopupFrame, 12)
	Creator.AddStroke(self.PopupFrame, { Color = "Outline", Thickness = 1, Transparency = 0.7, ThemeTag = { Color = "Outline" } })
	Creator.AddPadding(self.PopupFrame, 12)

	local mainAbs = main.AbsolutePosition
	local frameAbs = self.Frame.AbsolutePosition
	local relX = frameAbs.X - mainAbs.X
	local relY = frameAbs.Y - mainAbs.Y + self.Frame.AbsoluteSize.Y + 8

	-- Keep popup inside window
	local maxX = main.AbsoluteSize.X - 10 - 280
	local maxY = main.AbsoluteSize.Y - 10 - 190
	relX = math.clamp(relX, 10, math.max(10, maxX))
	relY = math.clamp(relY, 10, math.max(10, maxY))

	self.PopupFrame.Position = UDim2.fromOffset(relX, relY)

	self.Preview = Instance.new("Frame")
	self.Preview.Name = "Preview"
	self.Preview.Size = UDim2.new(1, 0, 0, 34)
	self.Preview.BackgroundColor3 = self.Value
	self.Preview.BorderSizePixel = 0
	self.Preview.ZIndex = 101
	self.Preview.Parent = self.PopupFrame
	Creator.AddCorner(self.Preview, 10)
	Creator.AddStroke(self.Preview, { Color = "Outline", Thickness = 1, Transparency = 0.8, ThemeTag = { Color = "Outline" } })

	local layout = Instance.new("UIListLayout")
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Padding = UDim.new(0, 10)
	layout.Parent = self.PopupFrame

	local function makeChannel(channel, barColor)
		local row = Instance.new("Frame")
		row.BackgroundTransparency = 1
		row.Size = UDim2.new(1, 0, 0, 34)
		row.ZIndex = 101
		row.Parent = self.PopupFrame

		local label = Creator.New("TextLabel", {
			Parent = row,
			Size = UDim2.fromOffset(18, 18),
			Position = UDim2.new(0, 0, 0.5, -9),
			BackgroundTransparency = 1,
			Text = channel,
			Font = Enum.Font.GothamBold,
			TextSize = 12,
			TextColor3 = "SubText",
			TextXAlignment = Enum.TextXAlignment.Left,
			ZIndex = 102,
			ThemeTag = { TextColor3 = "SubText" },
		})

		local bar = Creator.New("TextButton", {
			Parent = row,
			Size = UDim2.new(1, -28, 0, 8),
			Position = UDim2.new(0, 24, 0.5, -4),
			BackgroundColor3 = "Surface2",
			BackgroundTransparency = 0.25,
			Text = "",
			AutoButtonColor = false,
			BorderSizePixel = 0,
			ZIndex = 102,
			ThemeTag = { BackgroundColor3 = "Surface2" },
		})
		Creator.AddCorner(bar, 8)

		local fill = Instance.new("Frame")
		fill.BackgroundColor3 = barColor
		fill.BorderSizePixel = 0
		fill.Size = UDim2.new(0, 0, 1, 0)
		fill.ZIndex = 103
		fill.Parent = bar
		Creator.AddCorner(fill, 8)

		local knob = Creator.New("Frame", {
			Parent = bar,
			Size = UDim2.fromOffset(14, 14),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0, 0, 0.5, 0),
			BackgroundColor3 = "Text",
			BorderSizePixel = 0,
			ZIndex = 104,
			ThemeTag = { BackgroundColor3 = "Text" },
		})
		Creator.AddCorner(knob, 7)

		return {
			Bar = bar,
			Fill = fill,
			Knob = knob,
			Channel = channel,
		}
	end

	self.Sliders = {
		R = makeChannel("R", Color3.fromRGB(255, 90, 90)),
		G = makeChannel("G", Color3.fromRGB(90, 255, 140)),
		B = makeChannel("B", Color3.fromRGB(90, 160, 255)),
	}

	local dragging = nil

	local function setFromInput(input)
		if not dragging then
			return
		end
		local bar = dragging.Bar
		local barX = bar.AbsolutePosition.X
		local barW = bar.AbsoluteSize.X
		if barW <= 1 then
			return
		end
		local alpha = clamp01((input.Position.X - barX) / barW)
		self:_setChannel(dragging.Channel, alpha)
	end

	for _, slider in pairs(self.Sliders) do
		self.PopupMaid:GiveTask(slider.Bar.InputBegan:Connect(function(input)
			if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then
				return
			end
			dragging = slider
			setFromInput(input)
		end))
	end

	self.PopupMaid:GiveTask(UserInputService.InputChanged:Connect(function(input)
		if not dragging then
			return
		end
		if input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch then
			return
		end
		setFromInput(input)
	end))

	self.PopupMaid:GiveTask(UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = nil
		end
	end))

	self:_updatePopup()
end

function ColorPicker:Close()
	if not self.PopupFrame then
		return
	end

	if self.PopupMaid then
		self.PopupMaid:DoCleaning()
		self.PopupMaid = nil
	end

	if self.PopupFrame then
		self.PopupFrame:Destroy()
		self.PopupFrame = nil
	end
	self.Preview = nil
	self.Sliders = nil
end

function ColorPicker:Toggle()
	if self.PopupFrame then
		self:Close()
	else
		self:Open()
	end
end

function ColorPicker:Set(color, silent)
	if typeof(color) ~= "Color3" then
		return
	end
	self.Value = color
	self.Indicator.BackgroundColor3 = color
	self:_updatePopup()

	if self.Flag and self.Window then
		self.Window.Flags[self.Flag] = self.Value
	end
	if not silent then
		if self.Flag and self.Window and type(self.Window._flagChanged) == "function" then
			self.Window:_flagChanged(self.Flag)
		end
		self.Callback(self.Value)
	end
end

function ColorPicker:Get()
	return self.Value
end

function ColorPicker:SetEnabled(enabled)
	self.Disabled = not enabled
	self:_syncState()
	if self.Disabled then
		self:Close()
	end
end

function ColorPicker:SetLocked(locked)
	self.Locked = locked and true or false
	self:_syncState()
	if self.Locked then
		self:Close()
	end
end

function ColorPicker:_syncState()
	local blocked = self.Disabled or self.Locked
	self.Frame.BackgroundTransparency = blocked and 0.6 or self._baseTransparency
	self.TitleLabel.TextTransparency = blocked and 0.4 or 0
	self.Indicator.BackgroundTransparency = blocked and 0.3 or 0
	self.Frame.Active = not blocked
end

function ColorPicker:Destroy()
	self:Close()
	self.Maid:DoCleaning()
end

return ColorPicker
end

-- [[ Module: Label ]] --
modules["Label"] = function()
-- Phantasm Label
local Creator = requireModule("Creator")

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

function Label:Destroy()
	if self.Frame then
		self.Frame:Destroy()
	end
end

return Label
end

-- [[ Module: Paragraph ]] --
modules["Paragraph"] = function()
-- Phantasm Paragraph
local Creator = requireModule("Creator")

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

function Paragraph:Destroy()
	if self.Frame then
		self.Frame:Destroy()
	end
end

return Paragraph
end

-- [[ Module: Section ]] --
modules["Section"] = function()
-- Phantasm Section (UI-first remake)
local Creator = requireModule("Creator")
local Utility = requireModule("Utility")
local Maid = requireModule("Maid")

local Section = {}
Section.__index = Section

function Section.new(parentContainer, options, window)
	local self = setmetatable({}, Section)

	options = options or {}
	self.Maid = Maid.new()
	self.Window = window
	self.Options = options
	self.Title = options.Title or "Section"
	self.Collapsible = options.Collapsible ~= false
	self.Opened = options.Opened ~= false

	self.Frame = Creator.New("Frame", {
		Parent = parentContainer,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundColor3 = "Surface",
		BackgroundTransparency = 0.12,
		BorderSizePixel = 0,
		ThemeTag = { BackgroundColor3 = "Surface" },
	})
	Creator.AddCorner(self.Frame, 14)
	Creator.AddStroke(self.Frame, { Color = "Outline", Thickness = 1, Transparency = 0.8, ThemeTag = { Color = "Outline" } })
	Creator.AddPadding(self.Frame, 12)
	self.Maid:GiveTask(self.Frame)

	self.Header = Creator.New("TextButton", {
		Parent = self.Frame,
		Size = UDim2.new(1, 0, 0, 30),
		BackgroundTransparency = 1,
		Text = "",
		AutoButtonColor = false,
	})

	self.Label = Creator.New("TextLabel", {
		Parent = self.Header,
		Size = UDim2.new(1, -34, 1, 0),
		Position = UDim2.fromOffset(0, 0),
		BackgroundTransparency = 1,
		Text = self.Title,
		Font = Enum.Font.GothamBold,
		TextSize = 13,
		TextColor3 = "Text",
		TextXAlignment = Enum.TextXAlignment.Left,
		ThemeTag = { TextColor3 = "Text" },
	})

	self.Chevron = Creator.New("ImageLabel", {
		Parent = self.Header,
		Size = UDim2.fromOffset(16, 16),
		Position = UDim2.new(1, -16, 0.5, -8),
		BackgroundTransparency = 1,
		Image = Utility.GetIcon("chevron-down"),
		ImageColor3 = "Icon",
		Visible = self.Collapsible,
		ThemeTag = { ImageColor3 = "Icon" },
	})

	self.Content = Creator.New("Frame", {
		Parent = self.Frame,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		Visible = self.Opened,
	})

	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 10)
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Parent = self.Content
	self.Maid:GiveTask(layout)

	if self.Collapsible then
		self.Maid:GiveTask(self.Header.MouseButton1Click:Connect(function()
			self:SetOpened(not self.Opened)
		end))
	end

	self:_syncChevron(false)
	return self
end

function Section:_syncChevron(animated)
	if not self.Chevron or not self.Collapsible then
		return
	end
	local rot = self.Opened and 0 or -90
	if animated then
		Utility.Tween(self.Chevron, TweenInfo.new(0.16, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { Rotation = rot })
	else
		self.Chevron.Rotation = rot
	end
end

function Section:SetTitle(title)
	self.Title = title
	self.Label.Text = title
end

function Section:SetOpened(opened)
	if not self.Collapsible then
		opened = true
	end
	self.Opened = opened and true or false
	self.Content.Visible = self.Opened
	self:_syncChevron(true)
end

function Section:Collapse()
	self:SetOpened(false)
end

function Section:Expand()
	self:SetOpened(true)
end

function Section:Destroy()
	self.Maid:DoCleaning()
end

-- Element helpers (same API as Tab)
function Section:_register(element)
	if self.Window and type(self.Window._registerElement) == "function" then
		return self.Window:_registerElement(element)
	end
	return element
end

function Section:AddButton(options) return self:_register(requireModule("Button").new(self.Content, options, self.Window)) end
function Section:AddToggle(options) return self:_register(requireModule("Toggle").new(self.Content, options, self.Window)) end
function Section:AddSlider(options) return self:_register(requireModule("Slider").new(self.Content, options, self.Window)) end
function Section:AddLabel(options) return self:_register(requireModule("Label").new(self.Content, options, self.Window)) end
function Section:AddParagraph(options) return self:_register(requireModule("Paragraph").new(self.Content, options, self.Window)) end
function Section:AddInput(options) return self:_register(requireModule("Input").new(self.Content, options, self.Window)) end
function Section:AddDropdown(options) return self:_register(requireModule("Dropdown").new(self.Content, options, self.Window)) end
function Section:AddKeybind(options) return self:_register(requireModule("Keybind").new(self.Content, options, self.Window)) end
function Section:AddColorPicker(options) return self:_register(requireModule("ColorPicker").new(self.Content, options, self.Window)) end
function Section:AddSection(options) return self:_register(Section.new(self.Content, options, self.Window)) end

return Section
end

-- [[ Module: Tab ]] --
modules["Tab"] = function()
-- Phantasm Tab (UI-first remake)
local Creator = requireModule("Creator")
local Utility = requireModule("Utility")
local ThemeManager = requireModule("ThemeManager")
local Maid = requireModule("Maid")

local Tab = {}
Tab.__index = Tab

local function tweenToToken(instance, prop, token)
	local start = instance[prop]
	ThemeManager:Bind(instance, { [prop] = token })
	instance[prop] = start
	Utility.Tween(instance, TweenInfo.new(0.16, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
		[prop] = ThemeManager:GetColor(token),
	})
end

function Tab.new(window, options)
	local self = setmetatable({}, Tab)

	self.Maid = Maid.new()
	self.Window = window
	self.Title = options.Title or "Tab"
	self.Icon = options.Icon

	-- Sidebar button
	self.Button = Creator.New("TextButton", {
		Parent = window.SidebarList,
		Size = UDim2.new(1, 0, 0, 36),
		BackgroundColor3 = "Surface2",
		BackgroundTransparency = 1,
		Text = "",
		AutoButtonColor = false,
		Name = self.Title,
		ZIndex = 12,
		ThemeTag = { BackgroundColor3 = "Surface2" },
	})
	Creator.AddCorner(self.Button, 10)

	self.Indicator = Creator.New("Frame", {
		Parent = self.Button,
		Size = UDim2.fromOffset(3, 18),
		Position = UDim2.new(0, 8, 0.5, -9),
		BackgroundColor3 = "Accent",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ZIndex = 13,
		ThemeTag = { BackgroundColor3 = "Accent" },
	})
	Creator.AddCorner(self.Indicator, 2)

	local leftPad = 12
	if self.Icon then
		self.IconImage = Creator.New("ImageLabel", {
			Parent = self.Button,
			Size = UDim2.fromOffset(18, 18),
			Position = UDim2.new(0, 16, 0.5, -9),
			BackgroundTransparency = 1,
			Image = Utility.GetIcon(self.Icon),
			ImageColor3 = "Icon",
			ZIndex = 13,
			ThemeTag = { ImageColor3 = "Icon" },
		})
		leftPad = 16 + 18 + 10
	end

	self.Label = Creator.New("TextLabel", {
		Parent = self.Button,
		Size = UDim2.new(1, -leftPad, 1, 0),
		Position = UDim2.fromOffset(leftPad, 0),
		BackgroundTransparency = 1,
		Text = self.Title,
		Font = Enum.Font.GothamMedium,
		TextSize = 13,
		TextColor3 = "SubText",
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Center,
		ZIndex = 13,
		ThemeTag = { TextColor3 = "SubText" },
	})

	-- Content container
	self.Container = Creator.New("ScrollingFrame", {
		Name = self.Title .. "Container",
		Parent = window.Content,
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = (window.Options.ScrollBarEnabled == false) and 0 or 3,
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		CanvasSize = UDim2.new(0, 0, 0, 0),
		Visible = false,
		ZIndex = 11,
	})
	Creator.AddPadding(self.Container, 16)

	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 10)
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Parent = self.Container
	self.Maid:GiveTask(layout)

	self.Maid:GiveTask(self.Button.MouseButton1Click:Connect(function()
		self:Select()
	end))

	-- Hover
	self.Maid:GiveTask(self.Button.MouseEnter:Connect(function()
		if self.Window.ActiveTab == self then
			return
		end
		Utility.Tween(self.Button, TweenInfo.new(0.12, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
			BackgroundTransparency = 0.6,
		})
	end))

	self.Maid:GiveTask(self.Button.MouseLeave:Connect(function()
		if self.Window.ActiveTab == self then
			return
		end
		Utility.Tween(self.Button, TweenInfo.new(0.12, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
			BackgroundTransparency = 1,
		})
	end))

	return self
end

function Tab:Select()
	self.Window.ActiveTab = self

	for _, t in ipairs(self.Window.Tabs) do
		t.Container.Visible = false

		if t.Indicator then
			Utility.Tween(t.Indicator, TweenInfo.new(0.12, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
				BackgroundTransparency = 1,
			})
		end

		if t.IconImage then
			tweenToToken(t.IconImage, "ImageColor3", "Icon")
		end
		if t.Label then
			tweenToToken(t.Label, "TextColor3", "SubText")
		end

		Utility.Tween(t.Button, TweenInfo.new(0.12, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
			BackgroundTransparency = 1,
		})
	end

	self.Container.Visible = true

	if self.Indicator then
		Utility.Tween(self.Indicator, TweenInfo.new(0.12, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
			BackgroundTransparency = 0,
		})
	end

	if self.IconImage then
		tweenToToken(self.IconImage, "ImageColor3", "Text")
	end
	tweenToToken(self.Label, "TextColor3", "Text")

	Utility.Tween(self.Button, TweenInfo.new(0.12, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
		BackgroundTransparency = 0.25,
	})
end

function Tab:Destroy()
	self.Maid:DoCleaning()
end

-- Proxy Methods for Elements
function Tab:_register(element)
	if self.Window and type(self.Window._registerElement) == "function" then
		return self.Window:_registerElement(element)
	end
	return element
end

function Tab:AddButton(options) return self:_register(requireModule("Button").new(self.Container, options, self.Window)) end
function Tab:AddToggle(options) return self:_register(requireModule("Toggle").new(self.Container, options, self.Window)) end
function Tab:AddSlider(options) return self:_register(requireModule("Slider").new(self.Container, options, self.Window)) end
function Tab:AddLabel(options) return self:_register(requireModule("Label").new(self.Container, options, self.Window)) end
function Tab:AddParagraph(options) return self:_register(requireModule("Paragraph").new(self.Container, options, self.Window)) end
function Tab:AddInput(options) return self:_register(requireModule("Input").new(self.Container, options, self.Window)) end
function Tab:AddDropdown(options) return self:_register(requireModule("Dropdown").new(self.Container, options, self.Window)) end
function Tab:AddKeybind(options) return self:_register(requireModule("Keybind").new(self.Container, options, self.Window)) end
function Tab:AddColorPicker(options) return self:_register(requireModule("ColorPicker").new(self.Container, options, self.Window)) end
function Tab:AddSection(options) return self:_register(requireModule("Section").new(self.Container, options, self.Window)) end

return Tab
end

-- [[ Module: Window ]] --
modules["Window"] = function()
-- Phantasm Window (UI-first remake)
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")

local Maid = requireModule("Maid")
local Creator = requireModule("Creator")
local ThemeManager = requireModule("ThemeManager")
local Utility = requireModule("Utility")
local Signal = requireModule("Signal")
local ConfigManager = requireModule("ConfigManager")
local Tab = requireModule("Tab")

local Window = {}
Window.__index = Window

local WINDOW_ID = 0
local function nextWindowId()
	WINDOW_ID = WINDOW_ID + 1
	return WINDOW_ID
end

local sharedBlur
local blurUsers = 0

local function tryGetHui()
	local ok, result = pcall(function()
		if typeof(gethui) == "function" then
			return gethui()
		end
		return nil
	end)
	if ok and typeof(result) == "Instance" then
		return result
	end
	return nil
end

local function getDefaultGuiParent()
	local hui = tryGetHui()
	if hui then
		return hui
	end
	local player = Players.LocalPlayer
	if player then
		return player:WaitForChild("PlayerGui")
	end
	return game:GetService("CoreGui")
end

local function getViewportSize()
	local camera = workspace.CurrentCamera
	if camera then
		return camera.ViewportSize
	end
	return Vector2.new(1920, 1080)
end

local function udim2ToOffset(size, fallback)
	if size.X.Scale ~= 0 or size.Y.Scale ~= 0 then
		return fallback
	end
	return Vector2.new(size.X.Offset, size.Y.Offset)
end

function Window.new(options)
	local self = setmetatable({}, Window)
	options = options or {}

	self.Id = nextWindowId()
	self.Maid = Maid.new()
	self.Options = options

	self.Title = options.Title or "Phantasm"
	self.SubTitle = options.SubTitle or options.Author or ""
	self.SidebarWidth = options.SideBarWidth or options.TabWidth or 210

	self.Size = options.Size or UDim2.fromOffset(640, 460)
	self.MinSize = options.MinSize or UDim2.fromOffset(520, 360)
	self.MaxSize = options.MaxSize or UDim2.fromOffset(1040, 760)

	self.Enabled = true
	self.Minimized = false
	self.Tabs = {}
	self.ActiveTab = nil
	self.Elements = {}
	self.Flags = {}
	self.ToggleKey = options.ToggleKey or Enum.KeyCode.RightShift

	self.ConfigOptions = options.Configs or {}
	self.ConfigsEnabled = options.Configs ~= nil and self.ConfigOptions.Enabled ~= false
	self.AutoSave = self.ConfigsEnabled and self.ConfigOptions.AutoSave == true
	self.AutoSaveName = self.ConfigOptions.Name or "autosave"
	self.AutoSaveDebounce = tonumber(self.ConfigOptions.DebounceSeconds) or 1.25
	self._autoSavePending = false

	self.ConfigManager = ConfigManager.new(options.Folder or ("Phantasm_" .. tostring(self.Id)), self.Flags)

	self.OnOpen = Signal.new()
	self.OnClose = Signal.new()
	self.OnDestroy = Signal.new()

	if options.Theme then
		ThemeManager:SetTheme(options.Theme)
	end

	self:_buildUI()
	self:_hookInput()

	return self
end

function Window:_registerElement(element)
	table.insert(self.Elements, element)
	if element and element.Flag and self.ConfigManager and type(self.ConfigManager.Register) == "function" then
		self.ConfigManager:Register(element.Flag, element)
	end
	return element
end

function Window:_queueAutoSave()
	if not (self.ConfigsEnabled and self.AutoSave) then
		return
	end
	if self._autoSavePending then
		return
	end
	self._autoSavePending = true
	task.delay(self.AutoSaveDebounce, function()
		self._autoSavePending = false
		self.ConfigManager:Save(self.AutoSaveName)
	end)
end

function Window:_flagChanged()
	self:_queueAutoSave()
end

function Window:_buildUI()
	local material = tostring(self.Options.Material or (self.Options.Transparent and "Transparent" or "Opaque"))
	material = string.lower(material)
	if material == "solid" then
		material = "opaque"
	end

	local baseTransparency = 0
	if material == "transparent" then
		baseTransparency = 0.18
	elseif material == "acrylic" then
		baseTransparency = 0.12
	end

	-- Global blur (Acrylic)
	if material == "acrylic" then
		blurUsers = blurUsers + 1
		if not sharedBlur then
			sharedBlur = Instance.new("BlurEffect")
			sharedBlur.Name = "PhantasmAcrylicBlur"
			sharedBlur.Size = 18
			sharedBlur.Parent = Lighting
		end
		self.Maid:GiveTask(function()
			blurUsers = blurUsers - 1
			if blurUsers <= 0 and sharedBlur then
				sharedBlur:Destroy()
				sharedBlur = nil
				blurUsers = 0
			end
		end)
	end

	local parent = getDefaultGuiParent()
	self.Gui = Instance.new("ScreenGui")
	self.Gui.Name = "Phantasm_" .. tostring(self.Id)
	self.Gui.IgnoreGuiInset = true
	self.Gui.ResetOnSpawn = false
	self.Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	self.Gui.Parent = parent
	self.Maid:GiveTask(self.Gui)

	-- Shadow (must not be clipped)
	self.Shadow = Instance.new("ImageLabel")
	self.Shadow.Name = "Shadow"
	self.Shadow.AnchorPoint = Vector2.new(0.5, 0.5)
	self.Shadow.Position = UDim2.fromScale(0.5, 0.5)
	self.Shadow.BackgroundTransparency = 1
	self.Shadow.Image = "rbxassetid://6015897843"
	self.Shadow.ImageTransparency = 0.55
	self.Shadow.ImageColor3 = Color3.new(0, 0, 0)
	self.Shadow.ScaleType = Enum.ScaleType.Slice
	self.Shadow.SliceCenter = Rect.new(49, 49, 450, 450)
	self.Shadow.SliceScale = 1
	self.Shadow.ZIndex = 1
	self.Shadow.Parent = self.Gui
	self.Maid:GiveTask(self.Shadow)

	-- Main frame
	self.Main = Creator.New("Frame", {
		Name = "Main",
		Parent = self.Gui,
		Size = self.Size,
		Position = UDim2.fromScale(0.5, 0.5),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = "Background",
		BackgroundTransparency = baseTransparency,
		ThemeTag = { BackgroundColor3 = "Background" },
		ClipsDescendants = true,
		ZIndex = 2,
	})
	Creator.AddCorner(self.Main, 12)
	Creator.AddStroke(self.Main, {
		Color = "Outline",
		Thickness = 1,
		Transparency = 0.7,
		ThemeTag = { Color = "Outline" },
	})

	-- Background image (optional)
	if type(self.Options.Background) == "string" and self.Options.Background ~= "" then
		local bg = Instance.new("ImageLabel")
		bg.Name = "Background"
		bg.BackgroundTransparency = 1
		bg.Size = UDim2.fromScale(1, 1)
		bg.Image = self.Options.Background
		bg.ImageTransparency = self.Options.BackgroundImageTransparency or 0.6
		bg.ScaleType = Enum.ScaleType.Crop
		bg.ZIndex = 2
		bg.Parent = self.Main
		self.Maid:GiveTask(bg)
	end

	-- Acrylic layering (noise + soft gradient)
	if material == "acrylic" then
		local tint = Instance.new("Frame")
		tint.Name = "AcrylicTint"
		tint.BackgroundColor3 = ThemeManager:GetColor("Surface")
		ThemeManager:Bind(tint, { BackgroundColor3 = "Surface" })
		tint.BackgroundTransparency = 0.35
		tint.BorderSizePixel = 0
		tint.Size = UDim2.fromScale(1, 1)
		tint.ZIndex = 3
		tint.Parent = self.Main
		self.Maid:GiveTask(tint)

		local grad = Instance.new("UIGradient")
		grad.Rotation = 90
		grad.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.05),
			NumberSequenceKeypoint.new(1, 0.35),
		})
		grad.Parent = tint
		self.Maid:GiveTask(grad)

		local noise = Instance.new("ImageLabel")
		noise.Name = "Noise"
		noise.BackgroundTransparency = 1
		noise.Size = UDim2.fromScale(1, 1)
		noise.Image = "rbxassetid://12975764033"
		noise.ImageTransparency = 0.92
		noise.ResampleMode = Enum.ResampleMode.Tile
		noise.ScaleType = Enum.ScaleType.Tile
		noise.TileSize = UDim2.fromOffset(128, 128)
		noise.ZIndex = 4
		noise.Parent = self.Main
		self.Maid:GiveTask(noise)
	end

	-- Topbar
	local TOPBAR_H = 46
	self.Topbar = Creator.New("Frame", {
		Name = "Topbar",
		Parent = self.Main,
		Size = UDim2.new(1, 0, 0, TOPBAR_H),
		BackgroundColor3 = "Surface",
		BackgroundTransparency = material == "opaque" and 0 or 0.15,
		BorderSizePixel = 0,
		ZIndex = 10,
		ThemeTag = { BackgroundColor3 = "Surface" },
	})

	local topSep = Creator.New("Frame", {
		Name = "TopbarSeparator",
		Parent = self.Topbar,
		Size = UDim2.new(1, 0, 0, 1),
		Position = UDim2.new(0, 0, 1, -1),
		BackgroundColor3 = "Outline",
		BackgroundTransparency = 0.7,
		BorderSizePixel = 0,
		ZIndex = 11,
		ThemeTag = { BackgroundColor3 = "Outline" },
	})

	local left = Instance.new("Frame")
	left.Name = "Left"
	left.BackgroundTransparency = 1
	left.Size = UDim2.new(1, -140, 1, 0)
	left.Position = UDim2.fromOffset(14, 0)
	left.ZIndex = 11
	left.Parent = self.Topbar
	self.Maid:GiveTask(left)

	if self.Options.Icon then
		local icon = Creator.New("ImageLabel", {
			Parent = left,
			Size = UDim2.fromOffset(18, 18),
			Position = UDim2.new(0, 0, 0.5, -9),
			BackgroundTransparency = 1,
			Image = Utility.GetIcon(self.Options.Icon),
			ImageColor3 = "Icon",
			ZIndex = 12,
			ThemeTag = { ImageColor3 = "Icon" },
		})
		self.TopbarIcon = icon
	end

	local titleX = self.Options.Icon and 26 or 0
	self.TopbarTitle = Creator.New("TextLabel", {
		Parent = left,
		Size = UDim2.new(1, 0, 0, 18),
		Position = UDim2.new(0, titleX, 0.5, self.SubTitle ~= "" and -14 or -9),
		BackgroundTransparency = 1,
		Text = self.Title,
		Font = Enum.Font.GothamBold,
		TextSize = 14,
		TextColor3 = "Text",
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Center,
		ZIndex = 12,
		ThemeTag = { TextColor3 = "Text" },
	})

	if self.SubTitle ~= "" then
		self.TopbarSubTitle = Creator.New("TextLabel", {
			Parent = left,
			Size = UDim2.new(1, 0, 0, 14),
			Position = UDim2.new(0, titleX, 0.5, 2),
			BackgroundTransparency = 1,
			Text = self.SubTitle,
			Font = Enum.Font.Gotham,
			TextSize = 12,
			TextColor3 = "SubText",
			TextTransparency = 0.1,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Center,
			ZIndex = 12,
			ThemeTag = { TextColor3 = "SubText" },
		})
	end

	local function makeIconButton(iconName)
		local btn = Creator.New("TextButton", {
			Parent = self.Topbar,
			Size = UDim2.fromOffset(30, 30),
			BackgroundColor3 = "Surface2",
			BackgroundTransparency = 1,
			Text = "",
			AutoButtonColor = false,
			ZIndex = 12,
			ThemeTag = { BackgroundColor3 = "Surface2" },
		})
		Creator.AddCorner(btn, 8)

		local img = Creator.New("ImageLabel", {
			Parent = btn,
			Size = UDim2.fromOffset(16, 16),
			Position = UDim2.new(0.5, -8, 0.5, -8),
			BackgroundTransparency = 1,
			Image = Utility.GetIcon(iconName),
			ImageColor3 = "Icon",
			ZIndex = 13,
			ThemeTag = { ImageColor3 = "Icon" },
		})

		self.Maid:GiveTask(btn.MouseEnter:Connect(function()
			Utility.Tween(btn, TweenInfo.new(0.12, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { BackgroundTransparency = 0.35 })
		end))
		self.Maid:GiveTask(btn.MouseLeave:Connect(function()
			Utility.Tween(btn, TweenInfo.new(0.12, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { BackgroundTransparency = 1 })
		end))

		return btn, img
	end

	local closeBtn = makeIconButton("x")
	closeBtn.Position = UDim2.new(1, -12 - 30, 0.5, -15)
	self.Maid:GiveTask(closeBtn.MouseButton1Click:Connect(function()
		self:Destroy()
	end))

	local minBtn = makeIconButton("minus")
	minBtn.Position = UDim2.new(1, -12 - 30 - 30 - 8, 0.5, -15)
	self.Maid:GiveTask(minBtn.MouseButton1Click:Connect(function()
		self:SetMinimized(not self.Minimized)
	end))

	-- Sidebar
	self.Sidebar = Creator.New("Frame", {
		Name = "Sidebar",
		Parent = self.Main,
		Size = UDim2.new(0, self.SidebarWidth, 1, -TOPBAR_H),
		Position = UDim2.fromOffset(0, TOPBAR_H),
		BackgroundColor3 = "Surface",
		BackgroundTransparency = material == "opaque" and 0 or 0.12,
		BorderSizePixel = 0,
		ZIndex = 10,
		ThemeTag = { BackgroundColor3 = "Surface" },
	})

	Creator.New("Frame", {
		Name = "SidebarSeparator",
		Parent = self.Sidebar,
		Size = UDim2.new(0, 1, 1, 0),
		Position = UDim2.new(1, -1, 0, 0),
		BackgroundColor3 = "Outline",
		BackgroundTransparency = 0.7,
		BorderSizePixel = 0,
		ZIndex = 11,
		ThemeTag = { BackgroundColor3 = "Outline" },
	})

	local sidebarTop = 12
	if not self.Options.HideSearchBar then
		self.SearchBoxFrame = Creator.New("Frame", {
			Name = "Search",
			Parent = self.Sidebar,
			Size = UDim2.new(1, -24, 0, 34),
			Position = UDim2.fromOffset(12, 12),
			BackgroundColor3 = "Surface2",
			BackgroundTransparency = 0.25,
			BorderSizePixel = 0,
			ZIndex = 12,
			ThemeTag = { BackgroundColor3 = "Surface2" },
		})
		Creator.AddCorner(self.SearchBoxFrame, 10)
		Creator.AddStroke(self.SearchBoxFrame, {
			Color = "Outline",
			Thickness = 1,
			Transparency = 0.75,
			ThemeTag = { Color = "Outline" },
		})

		local searchIcon = Creator.New("ImageLabel", {
			Parent = self.SearchBoxFrame,
			Size = UDim2.fromOffset(16, 16),
			Position = UDim2.fromOffset(10, 9),
			BackgroundTransparency = 1,
			Image = Utility.GetIcon("search"),
			ImageColor3 = "Icon",
			ZIndex = 13,
			ThemeTag = { ImageColor3 = "Icon" },
		})

		self.SearchBox = Creator.New("TextBox", {
			Parent = self.SearchBoxFrame,
			Size = UDim2.new(1, -36, 1, 0),
			Position = UDim2.fromOffset(30, 0),
			BackgroundTransparency = 1,
			Text = "",
			PlaceholderText = "Search",
			Font = Enum.Font.Gotham,
			TextSize = 13,
			TextColor3 = "Text",
			PlaceholderColor3 = "Placeholder",
			TextXAlignment = Enum.TextXAlignment.Left,
			ClearTextOnFocus = false,
			ZIndex = 13,
			ThemeTag = { TextColor3 = "Text", PlaceholderColor3 = "Placeholder" },
		})

		self.Maid:GiveTask(self.SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
			self:_applyTabFilter(self.SearchBox.Text)
		end))

		sidebarTop = 12 + 34 + 10
	end

	self.SidebarList = Creator.New("ScrollingFrame", {
		Name = "Tabs",
		Parent = self.Sidebar,
		Size = UDim2.new(1, 0, 1, -sidebarTop),
		Position = UDim2.fromOffset(0, sidebarTop),
		BackgroundTransparency = 1,
		ScrollBarThickness = (self.Options.ScrollBarEnabled == false) and 0 or 3,
		CanvasSize = UDim2.new(0, 0, 0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ZIndex = 11,
	})
	Creator.AddPadding(self.SidebarList, 10)

	local tabsLayout = Instance.new("UIListLayout")
	tabsLayout.SortOrder = Enum.SortOrder.LayoutOrder
	tabsLayout.Padding = UDim.new(0, 6)
	tabsLayout.Parent = self.SidebarList
	self.Maid:GiveTask(tabsLayout)

	-- Content
	self.Content = Creator.New("Frame", {
		Name = "Content",
		Parent = self.Main,
		Size = UDim2.new(1, -self.SidebarWidth, 1, -TOPBAR_H),
		Position = UDim2.fromOffset(self.SidebarWidth, TOPBAR_H),
		BackgroundTransparency = 1,
		ZIndex = 10,
	})

	-- Notifications container
	self.NotifyHolder = Instance.new("Frame")
	self.NotifyHolder.Name = "Notifications"
	self.NotifyHolder.BackgroundTransparency = 1
	self.NotifyHolder.Size = UDim2.new(0, 320, 1, -20)
	self.NotifyHolder.Position = UDim2.new(1, -340, 0, 10)
	self.NotifyHolder.ZIndex = 200
	self.NotifyHolder.Parent = self.Gui
	self.Maid:GiveTask(self.NotifyHolder)

	local notifyList = Instance.new("UIListLayout")
	notifyList.VerticalAlignment = Enum.VerticalAlignment.Bottom
	notifyList.HorizontalAlignment = Enum.HorizontalAlignment.Right
	notifyList.Padding = UDim.new(0, 8)
	notifyList.Parent = self.NotifyHolder
	self.Maid:GiveTask(notifyList)

	-- Resize grip
	local resizable = self.Options.Resize == true or self.Options.Resizable == true or self.Options.Resizeable == true
	if resizable then
		self:_enableResizeGrip()
	end

	self:_syncShadow()
	self.Maid:GiveTask(self.Main:GetPropertyChangedSignal("Size"):Connect(function()
		self:_syncShadow()
	end))
	self.Maid:GiveTask(self.Main:GetPropertyChangedSignal("Position"):Connect(function()
		self:_syncShadow()
	end))
end

function Window:_syncShadow()
	if not (self.Shadow and self.Main) then
		return
	end
	self.Shadow.Position = self.Main.Position

	local absSize = self.Main.AbsoluteSize
	self.Shadow.Size = UDim2.fromOffset(absSize.X + 70, absSize.Y + 70)
end

function Window:_hookInput()
	-- Dragging (topbar only)
	local dragging = false
	local dragStart = nil
	local startPos = nil

	self.Maid:GiveTask(self.Topbar.InputBegan:Connect(function(input)
		if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then
			return
		end
		dragging = true
		dragStart = input.Position
		startPos = self.Main.Position

		local conn
		conn = input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
				if conn then
					conn:Disconnect()
				end
			end
		end)
		self.Maid:GiveTask(conn)
	end))

	self.Maid:GiveTask(UserInputService.InputChanged:Connect(function(input)
		if not dragging then
			return
		end
		if input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch then
			return
		end
		if not dragStart or not startPos then
			return
		end

		local delta = input.Position - dragStart
		local viewport = getViewportSize()

		local scaleX = startPos.X.Scale
		local scaleY = startPos.Y.Scale
		local baseCenter = Vector2.new(viewport.X * scaleX, viewport.Y * scaleY)
		local center = baseCenter + Vector2.new(startPos.X.Offset + delta.X, startPos.Y.Offset + delta.Y)

		local half = self.Main.AbsoluteSize * 0.5
		center = Vector2.new(
			math.clamp(center.X, half.X, viewport.X - half.X),
			math.clamp(center.Y, half.Y, viewport.Y - half.Y)
		)

		local newOffset = center - baseCenter
		self.Main.Position = UDim2.new(scaleX, newOffset.X, scaleY, newOffset.Y)
	end))

	-- Toggle key
	self.Maid:GiveTask(UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then
			return
		end
		if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == self.ToggleKey then
			self:Toggle()
		end
	end))
end

function Window:_enableResizeGrip()
	if self.ResizeMaid then
		self.ResizeMaid:DoCleaning()
	end
	self.ResizeMaid = Maid.new()

	local grip = Instance.new("ImageButton")
	grip.Name = "ResizeGrip"
	grip.AnchorPoint = Vector2.new(1, 1)
	grip.Position = UDim2.new(1, -6, 1, -6)
	grip.Size = UDim2.fromOffset(18, 18)
	grip.BackgroundTransparency = 1
	grip.Image = Utility.GetIcon("maximize-2")
	grip.ImageTransparency = 0.6
	grip.ImageColor3 = ThemeManager:GetColor("Icon")
	ThemeManager:Bind(grip, { ImageColor3 = "Icon" })
	grip.ZIndex = 50
	grip.Parent = self.Main
	self.ResizeGrip = grip
	self.ResizeMaid:GiveTask(grip)

	local resizing = false
	local startMouse = nil
	local startSize = nil

	local min = udim2ToOffset(self.MinSize, Vector2.new(520, 360))
	local max = udim2ToOffset(self.MaxSize, Vector2.new(1040, 760))

	self.ResizeMaid:GiveTask(grip.InputBegan:Connect(function(input)
		if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then
			return
		end
		resizing = true
		startMouse = input.Position
		startSize = self.Main.AbsoluteSize

		local conn
		conn = input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				resizing = false
				if conn then
					conn:Disconnect()
				end
			end
		end)
		self.ResizeMaid:GiveTask(conn)
	end))

	self.ResizeMaid:GiveTask(UserInputService.InputChanged:Connect(function(input)
		if not resizing then
			return
		end
		if input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch then
			return
		end
		if not startMouse or not startSize then
			return
		end

		local delta = input.Position - startMouse
		local newW = math.clamp(startSize.X + delta.X, min.X, max.X)
		local newH = math.clamp(startSize.Y + delta.Y, min.Y, max.Y)
		self.Main.Size = UDim2.fromOffset(newW, newH)
	end))
end

function Window:_applyTabFilter(text)
	local query = string.lower(text or "")
	for _, tab in ipairs(self.Tabs) do
		local visible = (query == "") or (string.find(string.lower(tab.Title), query, 1, true) ~= nil)
		if tab.Button then
			tab.Button.Visible = visible
		end
	end
end

function Window:AddTab(options)
	local tab = Tab.new(self, options or {})
	table.insert(self.Tabs, tab)

	if self.SearchBox then
		self:_applyTabFilter(self.SearchBox.Text)
	end

	if #self.Tabs == 1 then
		tab:Select()
	end

	return tab
end

function Window:SetMinimized(minimized)
	minimized = minimized and true or false
	if self.Minimized == minimized then
		return
	end
	self.Minimized = minimized

	if minimized then
		self._preMinimizeSize = self.Main.AbsoluteSize
		self.Sidebar.Visible = false
		self.Content.Visible = false
		self.Main.ClipsDescendants = true
		self.Main.Size = UDim2.fromOffset(self._preMinimizeSize.X, 56)
	else
		local restore = self._preMinimizeSize or self.Main.AbsoluteSize
		self.Sidebar.Visible = true
		self.Content.Visible = true
		self.Main.Size = UDim2.fromOffset(restore.X, restore.Y)
	end
end

function Window:Open()
	self.Enabled = true
	self.Gui.Enabled = true
	self.OnOpen:Fire()
end

function Window:Close()
	self.Enabled = false
	self.Gui.Enabled = false
	self.OnClose:Fire()
end

function Window:Toggle()
	if self.Enabled then
		self:Close()
	else
		self:Open()
	end
end

function Window:SetTheme(nameOrTable)
	ThemeManager:SetTheme(nameOrTable)
end

function Window:SetToggleKey(keyCode)
	self.ToggleKey = keyCode or Enum.KeyCode.RightShift
end

function Window:SetSize(size)
	if typeof(size) == "UDim2" then
		self.Main.Size = size
	end
end

function Window:SetResizable(enabled)
	enabled = enabled and true or false
	if enabled and not self.ResizeGrip then
		self:_enableResizeGrip()
	elseif not enabled and self.ResizeGrip then
		if self.ResizeMaid then
			self.ResizeMaid:DoCleaning()
			self.ResizeMaid = nil
		end
		self.ResizeGrip = nil
	end
end

function Window:SaveConfig(name)
	return self.ConfigManager:Save(name or self.AutoSaveName)
end

function Window:LoadConfig(name, silent)
	return self.ConfigManager:Load(name or self.AutoSaveName, silent)
end

function Window:ExportConfig()
	return self.ConfigManager:Export()
end

function Window:ImportConfig(json, silent)
	return self.ConfigManager:Import(json, silent)
end

function Window:LockAllElements()
	for _, element in ipairs(self.Elements) do
		if type(element) == "table" and type(element.SetLocked) == "function" then
			element:SetLocked(true)
		end
	end
end

function Window:UnlockAllElements()
	for _, element in ipairs(self.Elements) do
		if type(element) == "table" and type(element.SetLocked) == "function" then
			element:SetLocked(false)
		end
	end
end

function Window:GetAllElements()
	return self.Elements
end

function Window:GetLockedElements()
	local locked = {}
	for _, element in ipairs(self.Elements) do
		if type(element) == "table" and element.Locked == true then
			table.insert(locked, element)
		end
	end
	return locked
end

function Window:GetUnlockedElements()
	local unlocked = {}
	for _, element in ipairs(self.Elements) do
		if type(element) == "table" and element.Locked ~= true then
			table.insert(unlocked, element)
		end
	end
	return unlocked
end

function Window:Notify(options)
	options = options or {}

	local toast = Creator.New("Frame", {
		Parent = self.NotifyHolder,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundColor3 = "Surface",
		BackgroundTransparency = 0.08,
		BorderSizePixel = 0,
		ZIndex = 201,
		ThemeTag = { BackgroundColor3 = "Surface" },
	})
	Creator.AddCorner(toast, 12)
	Creator.AddStroke(toast, { Color = "Outline", Thickness = 1, Transparency = 0.7, ThemeTag = { Color = "Outline" } })
	Creator.AddPadding(toast, 12)

	local title = Creator.New("TextLabel", {
		Parent = toast,
		Size = UDim2.new(1, 0, 0, 18),
		BackgroundTransparency = 1,
		Text = options.Title or "Notification",
		Font = Enum.Font.GothamBold,
		TextSize = 14,
		TextColor3 = "Text",
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 202,
		ThemeTag = { TextColor3 = "Text" },
	})

	local body = Creator.New("TextLabel", {
		Parent = toast,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		Text = options.Content or "",
		Font = Enum.Font.Gotham,
		TextSize = 12,
		TextColor3 = "SubText",
		TextTransparency = 0.05,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextWrapped = true,
		ZIndex = 202,
		ThemeTag = { TextColor3 = "SubText" },
	})

	local layout = Instance.new("UIListLayout")
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Padding = UDim.new(0, 6)
	layout.Parent = toast

	toast.BackgroundTransparency = 1
	title.TextTransparency = 1
	body.TextTransparency = 1

	Utility.Tween(toast, TweenInfo.new(0.18, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { BackgroundTransparency = 0.08 })
	Utility.Tween(title, TweenInfo.new(0.18, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { TextTransparency = 0 })
	Utility.Tween(body, TweenInfo.new(0.18, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { TextTransparency = 0.05 })

	task.delay(options.Duration or 3, function()
		if not toast.Parent then
			return
		end
		Utility.Tween(toast, TweenInfo.new(0.18, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { BackgroundTransparency = 1 })
		Utility.Tween(title, TweenInfo.new(0.18, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { TextTransparency = 1 })
		Utility.Tween(body, TweenInfo.new(0.18, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { TextTransparency = 1 }, function()
			if toast then
				toast:Destroy()
			end
		end)
	end)
end

function Window:Destroy()
	for _, element in ipairs(self.Elements) do
		if type(element) == "table" and type(element.Destroy) == "function" then
			pcall(function()
				element:Destroy()
			end)
		end
	end
	for _, tab in ipairs(self.Tabs) do
		if type(tab) == "table" and type(tab.Destroy) == "function" then
			pcall(function()
				tab:Destroy()
			end)
		end
	end

	if self.ResizeMaid then
		self.ResizeMaid:DoCleaning()
		self.ResizeMaid = nil
	end

	self.OnDestroy:Fire()
	self.OnOpen:Destroy()
	self.OnClose:Destroy()
	self.OnDestroy:Destroy()
	self.Maid:DoCleaning()
end

return Window
end

-- [[ Module: init ]] --
modules["init"] = function()
-- Phantasm Library
local Window = requireModule("Window")
local ThemeManager = requireModule("ThemeManager")

local Library = {}
Library.Version = "1.2.0"
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
end

return requireModule("init")

