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
