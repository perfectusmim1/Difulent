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
