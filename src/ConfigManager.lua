-- Phantasm ConfigManager
local HttpService = game:GetService("HttpService")

local ConfigManager = {}
ConfigManager.__index = ConfigManager

local function isCallable(func)
    return type(func) == "function" or (type(func) == "table" and getmetatable(func) and getmetatable(func).__call)
end

function ConfigManager.new(folderPath, flagsTable)
    local self = setmetatable({}, ConfigManager)
    self.Folder = folderPath or "PhantasmSettings"
    self.Flags = flagsTable or {}
    
    -- Detect executor capabilities
    self.CanSave = isCallable(writefile) and isCallable(readfile) and isCallable(isfolder) and isCallable(makefolder)
    
    if self.CanSave then
        if not isfolder(self.Folder) then
            makefolder(self.Folder)
        end
    end
    
    return self
end

function ConfigManager:Save(name)
    if not name then return false, "No name provided" end
    
    local data = {}
    for flag, value in pairs(self.Flags) do
        -- Check if value is a table (like Color3 or Enum that needs serialization)
        if typeof(value) == "Color3" then
            data[flag] = {__type = "Color3", r = value.R, g = value.G, b = value.B}
        elseif typeof(value) == "EnumItem" then
             data[flag] = {__type = "Enum", name = tostring(value)}
        else
            data[flag] = value
        end
    end
    
    local json = HttpService:JSONEncode(data)
    
    if self.CanSave then
        writefile(self.Folder .. "/" .. name .. ".json", json)
        return true
    else
        return false, "File saving not supported"
    end
end

function ConfigManager:Load(name)
    if not name then return false, "No name provided" end
    
    local content = nil
    if self.CanSave then
        local path = self.Folder .. "/" .. name .. ".json"
        if isfile(path) then
            content = readfile(path)
        else
            return false, "File not found"
        end
    else
        return false, "File loading not supported"
    end
    
    if content then
        local success, decoded = pcall(function() return HttpService:JSONDecode(content) end)
        if not success then return false, "JSON Decode failed" end
        
        -- Apply flags
        for flag, value in pairs(decoded) do
            if type(value) == "table" and value.__type == "Color3" then
                self.Flags[flag] = Color3.new(value.r, value.g, value.b)
            elseif type(value) == "table" and value.__type == "Enum" then
                 -- Simplistic enum restore if needed, usually we just ignore or specialized handling
                 -- For now, generic decoding
            else
                self.Flags[flag] = value
            end
            
            -- Notify listeners? 
            -- Elements typically listen to Flags[key] changes or we need a Set() method.
            -- This manager assumes the Elements check Flags or the Library has a way to update them.
            -- A comprehensive library would call Element:Set(val) here.
            -- We will address this in the Window/Element logic: Elements should likely register themselves to ConfigManager to be updated.
        end 
        return true
    end
    return false
end

function ConfigManager:GetConfigs()
    if not self.CanSave then return {} end
    if not isfolder(self.Folder) then makefolder(self.Folder) end
    
    local files = listfiles(self.Folder)
    local configs = {}
    for _, file in ipairs(files) do
        if file:sub(-5) == ".json" then
            -- extract filename
            local name = file:match("([^/\\]+)%.json$")
            table.insert(configs, name)
        end
    end
    return configs
end

return ConfigManager
