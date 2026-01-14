-- Phantasm UI Library [Bundled]
-- https://github.com/perfectusmim1/Difulent
-- Generated Bundle

local modules = {}

-- [[ Module: Signal ]] --
modules["Signal"] = function()
    local Signal = {}
    Signal.__index = Signal
    function Signal.new()
        local self = setmetatable({}, Signal)
        self._bindable = Instance.new("BindableEvent")
        self._argMap = {}
        return self
    end
    function Signal:Connect(handler)
        if not (type(handler) == "function") then error("connect expects a function") end
        return self._bindable.Event:Connect(function(key)
            local args = self._argMap[key]
            if args then handler(table.unpack(args, 1, args.n)) end
        end)
    end
    function Signal:Fire(...)
        local args = table.pack(...)
        local key = tostring(os.clock()) .. tostring(math.random())
        self._argMap[key] = args
        self._bindable:Fire(key)
        task.defer(function() self._argMap[key] = nil end)
    end
    function Signal:Wait()
        local key = self._bindable.Event:Wait()
        local args = self._argMap[key]
        if args then return table.unpack(args, 1, args.n) end
    end
    function Signal:Destroy()
        if self._bindable then self._bindable:Destroy() end
    end
    return Signal
end

-- [[ Module: Maid ]] --
modules["Maid"] = function()
    local Maid = {}
    Maid.__index = Maid
    function Maid.new() return setmetatable({_tasks = {}}, Maid) end
    function Maid:GiveTask(task)
        local taskId = #self._tasks + 1; self._tasks[taskId] = task; return taskId
    end
    function Maid:DoCleaning()
        for index, task in pairs(self._tasks) do
            if typeof(task) == "RBXScriptConnection" then task:Disconnect()
            elseif type(task) == "function" then task()
            elseif type(task) == "table" and type(task.Destroy) == "function" then task:Destroy()
            elseif typeof(task) == "Instance" then task:Destroy() end
            self._tasks[index] = nil
        end
    end
    function Maid:Destroy() self:DoCleaning() end
    return Maid
end

-- [[ Module: Utility ]] --
modules["Utility"] = function()
    local TweenService = game:GetService("TweenService")
    local UserInputService = game:GetService("UserInputService")
    local Utility = {}
    local Icons = {
        ["search"]="rbxassetid://18216666242", ["home"]="rbxassetid://18216666456",
        ["settings"]="rbxassetid://18216667519", ["user"]="rbxassetid://18216667743",
        ["info"]="rbxassetid://18216666699", ["x"]="rbxassetid://18216668787",
        ["check"]="rbxassetid://18216664972", ["chevron-down"]="rbxassetid://18216665097",
        ["chevron-right"]="rbxassetid://18216665241", ["copy"]="rbxassetid://18216665421",
        ["layers"]="rbxassetid://18216666804", ["edit"]="rbxassetid://18216665798",
        ["trash"]="rbxassetid://18216667520"
    }
    function Utility.GetIcon(name)
        if not name then return "" end
        if string.find(name, "rbxassetid://") then return name end
        return Icons[string.lower(name)] or Icons["info"]
    end
    function Utility.Tween(desc, info, goals, cb)
        local t = TweenService:Create(desc, info, goals); t:Play()
        if cb then t.Completed:Connect(cb) end; return t
    end
    function Utility.EnableDragging(frame)
        local dragHandle = frame
        local dragging, dragInput, dragStart, startPos
        local function update(input)
            local delta = input.Position - dragStart
            local newPos = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            TweenService:Create(frame, TweenInfo.new(0.1), {Position = newPos}):Play()
        end
        dragHandle.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true; dragStart = input.Position; startPos = frame.Position
                input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
            end
        end)
        dragHandle.InputChanged:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end end)
        UserInputService.InputChanged:Connect(function(input) if input == dragInput and dragging then update(input) end end)
    end
    function Utility.AddRipple(button)
        button.ClipsDescendants = true
        button.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                local x, y = input.Position.X - button.AbsolutePosition.X, input.Position.Y - button.AbsolutePosition.Y
                local size = math.max(button.AbsoluteSize.X, button.AbsoluteSize.Y) * 1.5
                local ripple = Instance.new("Frame"); ripple.BackgroundTransparency=0.8; ripple.BackgroundColor3=Color3.new(1,1,1); ripple.Parent=button
                ripple.Position=UDim2.new(0,x,0,y); ripple.AnchorPoint=Vector2.new(0.5,0.5); local c=Instance.new("UICorner",ripple); c.CornerRadius=UDim.new(1,0)
                TweenService:Create(ripple, TweenInfo.new(0.5), {Size=UDim2.new(0,size,0,size), BackgroundTransparency=1}):Play()
                task.delay(0.5, function() ripple:Destroy() end)
            end
        end)
    end
    return Utility
end

-- [[ Module: ThemeManager ]] --
modules["ThemeManager"] = function()
    local Signal = modules["Signal"]()
    local TM = {}
    TM.ThemeChanged = Signal.new()
    TM.BuiltInThemes = {
        Dark = { Accent=Color3.fromRGB(0,120,212), Background=Color3.fromRGB(32,32,32), Surface=Color3.fromRGB(45,45,45), Surface2=Color3.fromRGB(60,60,60), Outline=Color3.fromRGB(80,80,80), Text=Color3.fromRGB(255,255,255), SubText=Color3.fromRGB(180,180,180), Placeholder = Color3.fromRGB(120, 120, 120) },
        Midnight = { Accent=Color3.fromRGB(114,137,218), Background=Color3.fromRGB(15,15,20), Surface=Color3.fromRGB(25,25,35), Surface2=Color3.fromRGB(35,35,45), Outline=Color3.fromRGB(45,45,60), Text=Color3.fromRGB(240,240,255), SubText=Color3.fromRGB(160,160,180), Placeholder = Color3.fromRGB(100, 100, 120) },
        Ocean = { Accent=Color3.fromRGB(0,150,200), Background=Color3.fromRGB(10,25,35), Surface=Color3.fromRGB(18,40,55), Surface2=Color3.fromRGB(25,55,75), Outline=Color3.fromRGB(35,70,90), Text=Color3.fromRGB(220,240,255), SubText=Color3.fromRGB(140,180,200), Placeholder = Color3.fromRGB(100, 130, 150) }
    }
    TM.CurrentTheme = TM.BuiltInThemes.Dark
    function TM:SetTheme(name)
        if type(name)=="string" and self.BuiltInThemes[name] then self.CurrentTheme=self.BuiltInThemes[name] end
        self.ThemeChanged:Fire()
    end
    function TM:GetColor(token) return self.CurrentTheme[token] or Color3.new(1,0,1) end
    return TM
end

-- [[ Module: Creator ]] --
modules["Creator"] = function()
    local ThemeManager = modules["ThemeManager"]()
    local Creator = {}
    function Creator.New(className, props)
        local inst = Instance.new(className)
        for k, v in pairs(props or {}) do
            if k ~= "ThemeTag" and k ~= "Parent" then
                if type(v) == "string" and ThemeManager.BuiltInThemes.Dark[v] then
                    inst[k] = ThemeManager:GetColor(v)
                    ThemeManager.ThemeChanged:Connect(function() inst[k] = ThemeManager:GetColor(v) end)
                else inst[k] = v end
            end
        end
        if props and props.ThemeTag then
            for prop, token in pairs(props.ThemeTag) do
                inst[prop] = ThemeManager:GetColor(token)
                ThemeManager.ThemeChanged:Connect(function() inst[prop] = ThemeManager:GetColor(token) end)
            end
        end
        if props.Parent then inst.Parent = props.Parent end
        return inst
    end
    function Creator.AddCorner(inst, r) local c=Instance.new("UICorner", inst); c.CornerRadius=UDim.new(0,r or 6) end
    function Creator.AddStroke(inst, p)
        local s=Instance.new("UIStroke", inst); s.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
        for k,v in pairs(p) do if k~="ThemeTag" then s[k]=v end end
        if p.ThemeTag then for k,v in pairs(p.ThemeTag) do s[k]=ThemeManager:GetColor(v); ThemeManager.ThemeChanged:Connect(function() s[k]=ThemeManager:GetColor(v) end) end end
    end
    function Creator.AddPadding(inst, p) local pad=Instance.new("UIPadding", inst); pad.PaddingLeft=UDim.new(0,p); pad.PaddingRight=UDim.new(0,p); pad.PaddingTop=UDim.new(0,p); pad.PaddingBottom=UDim.new(0,p) end
    return Creator
end

-- [[ Module: Elements ]] --
modules["Elements"] = function()
    local Creator = modules["Creator"]()
    local Utility = modules["Utility"]()
    local ThemeManager = modules["ThemeManager"]()
    local Elements = {}

    -- Button
    Elements.Button = {}
    Elements.Button.__index = Elements.Button
    function Elements.Button.new(container, options)
        local self = setmetatable({}, Elements.Button)
        self.Frame = Creator.New("TextButton", {Parent=container, Size=UDim2.new(1,0,0,32), BackgroundColor3="Surface2", Text="", AutoButtonColor=false, ThemeTag={BackgroundColor3="Surface2"}})
        Creator.AddCorner(self.Frame, 6)
        Creator.New("TextLabel", {Parent=self.Frame, Size=UDim2.new(1,-20,1,0), Position=UDim2.new(0,10,0,0), BackgroundTransparency=1, Text=options.Title or "Button", Font=Enum.Font.GothamMedium, TextSize=13, TextColor3="Text", TextXAlignment=Enum.TextXAlignment.Left, ThemeTag={TextColor3="Text"}})
        Creator.New("ImageLabel", {Parent=self.Frame, Size=UDim2.fromOffset(16,16), Position=UDim2.new(1,-26,0.5,-8), BackgroundTransparency=1, Image=Utility.GetIcon("chevron-right"), ImageColor3="SubText", ThemeTag={ImageColor3="SubText"}})
        self.Frame.MouseButton1Click:Connect(function() Utility.AddRipple(self.Frame); if options.Callback then options.Callback() end end)
        return self
    end

    -- Toggle
    Elements.Toggle = {}
    Elements.Toggle.__index = Elements.Toggle
    function Elements.Toggle.new(container, options, window)
        local self = setmetatable({Value=options.Default or false}, Elements.Toggle)
        self.Window = window; self.Flag = options.Flag; self.Callback = options.Callback or function() end
        if self.Flag and window then window.Flags[self.Flag] = self.Value end
        self.Frame = Creator.New("TextButton", {Parent=container, Size=UDim2.new(1,0,0,32), BackgroundTransparency=1, Text="", AutoButtonColor=false})
        Creator.New("TextLabel", {Parent=self.Frame, Size=UDim2.new(1,-60,1,0), Position=UDim2.new(0,0,0,0), BackgroundTransparency=1, Text=options.Title or "Toggle", Font=Enum.Font.GothamMedium, TextSize=13, TextColor3="Text", TextXAlignment=Enum.TextXAlignment.Left, ThemeTag={TextColor3="Text"}})
        self.Switch = Creator.New("Frame", {Parent=self.Frame, Size=UDim2.fromOffset(40,20), Position=UDim2.new(1,-40,0.5,-10), BackgroundColor3="Surface2", ThemeTag={BackgroundColor3="Surface2"}}); Creator.AddCorner(self.Switch, 10)
        self.Knob = Creator.New("Frame", {Parent=self.Switch, Size=UDim2.fromOffset(16,16), Position=UDim2.new(0,2,0,2), BackgroundColor3="SubText", ThemeTag={BackgroundColor3="SubText"}}); Creator.AddCorner(self.Knob, 8)
        self.Frame.MouseButton1Click:Connect(function() self:Set(not self.Value) end)
        self:Set(self.Value)
        return self
    end
    function Elements.Toggle:Set(val)
        self.Value = val
        if self.Flag and self.Window then self.Window.Flags[self.Flag] = self.Value end
        local pos = self.Value and UDim2.new(0,22,0,2) or UDim2.new(0,2,0,2)
        local color = self.Value and ThemeManager:GetColor("Accent") or ThemeManager:GetColor("Surface2")
        Utility.Tween(self.Knob, TweenInfo.new(0.2), {Position=pos, BackgroundColor3=ThemeManager:GetColor("Text")})
        Utility.Tween(self.Switch, TweenInfo.new(0.2), {BackgroundColor3=color})
        self.Callback(val)
    end
    
    -- Slider
    Elements.Slider = {}
    Elements.Slider.__index = Elements.Slider
    function Elements.Slider.new(container, options, window)
        local self = setmetatable({Min=options.Min or 0, Max=options.Max or 100, Step=options.Step or 1, Value=options.Default or 0}, Elements.Slider)
        self.Container = Creator.New("Frame", {Parent=container, Size=UDim2.new(1,0,0,50), BackgroundTransparency=1})
        Creator.New("TextLabel", {Parent=self.Container, Size=UDim2.new(1,0,0,20), Text=options.Title or "Slider", TextSize=13, Font=Enum.Font.GothamMedium, BackgroundTransparency=1, TextColor3="Text", TextXAlignment=Enum.TextXAlignment.Left, ThemeTag={TextColor3="Text"}})
        local btn = Creator.New("TextButton", {Parent=self.Container, Size=UDim2.new(1,0,0,6), Position=UDim2.new(0,0,1,-10), BackgroundColor3="Surface2", Text="", ThemeTag={BackgroundColor3="Surface2"}}); Creator.AddCorner(btn, 4)
        local fill = Creator.New("Frame", {Parent=btn, Size=UDim2.new(0,0,1,0), BackgroundColor3="Accent", ThemeTag={BackgroundColor3="Accent"}}); Creator.AddCorner(fill, 4)
        local dragging = false
        local function Update(input)
            local pct = math.clamp((input.Position.X - btn.AbsolutePosition.X) / btn.AbsoluteSize.X, 0, 1)
            local val = math.floor((self.Min + (self.Max-self.Min)*pct)/self.Step + 0.5)*self.Step
            fill.Size = UDim2.new(pct, 0, 1, 0)
            if options.Callback then options.Callback(val) end
        end
        btn.MouseButton1Down:Connect(function() dragging=true; Update(game:GetService("UserInputService"):GetMouse()) end)
        game:GetService("UserInputService").InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end end)
        game:GetService("UserInputService").InputChanged:Connect(function(i) if dragging and i.UserInputType==Enum.UserInputType.MouseMovement then Update(i) end end)
        return self
    end

    -- Label
    Elements.Label = {}
    Elements.Label.__index = Elements.Label
    function Elements.Label.new(container, options)
        local self = setmetatable({}, Elements.Label)
        Creator.New("TextLabel", {Parent=container, Size=UDim2.new(1,0,0,26), BackgroundTransparency=1, Text=options.Title or "Label", Font=Enum.Font.Gotham, TextSize=13, TextColor3="Text", TextXAlignment=Enum.TextXAlignment.Left, ThemeTag={TextColor3="Text"}})
        return self
    end

    -- Paragraph
    Elements.Paragraph = {}
    Elements.Paragraph.__index = Elements.Paragraph
    function Elements.Paragraph.new(container, options)
        local self = setmetatable({}, Elements.Paragraph)
        local f = Creator.New("Frame", {Parent=container, Size=UDim2.new(1,0,0,0), BackgroundTransparency=1, AutomaticSize=Enum.AutomaticSize.Y})
        Creator.New("TextLabel", {Parent=f, Size=UDim2.new(1,0,0,20), BackgroundTransparency=1, Text=options.Title or "Paragraph", Font=Enum.Font.GothamMedium, TextSize=14, TextColor3="Text", TextXAlignment=Enum.TextXAlignment.Left, ThemeTag={TextColor3="Text"}})
        Creator.New("TextLabel", {Parent=f, Size=UDim2.new(1,0,0,0), Position=UDim2.fromOffset(0,25), BackgroundTransparency=1, Text=options.Content or "", Font=Enum.Font.Gotham, TextSize=13, TextColor3="SubText", TextXAlignment=Enum.TextXAlignment.Left, TextWrapped=true, AutomaticSize=Enum.AutomaticSize.Y, ThemeTag={TextColor3="SubText"}})
        Creator.AddPadding(f, 10)
        return self
    end

    -- Input
    Elements.Input = {}
    Elements.Input.__index = Elements.Input
    function Elements.Input.new(container, options, window)
        local self = setmetatable({Value=options.Default or ""}, Elements.Input)
        if options.Flag and window then window.Flags[options.Flag] = self.Value end
        local f = Creator.New("Frame", {Parent=container, Size=UDim2.new(1,0,0,50), BackgroundTransparency=1})
        Creator.New("TextLabel", {Parent=f, Size=UDim2.new(1,0,0,20), BackgroundTransparency=1, Text=options.Title or "Input", Font=Enum.Font.GothamMedium, TextSize=13, TextColor3="Text", TextXAlignment=Enum.TextXAlignment.Left, ThemeTag={TextColor3="Text"}})
        local b = Creator.New("Frame", {Parent=f, Size=UDim2.new(1,0,0,30), Position=UDim2.new(0,0,0,20), BackgroundColor3="Surface2", ThemeTag={BackgroundColor3="Surface2"}}); Creator.AddCorner(b, 6)
        local box = Creator.New("TextBox", {Parent=b, Size=UDim2.new(1,-20,1,0), Position=UDim2.new(0,10,0,0), BackgroundTransparency=1, Text=self.Value, PlaceholderText=options.Placeholder or "Enter...", Font=Enum.Font.Gotham, TextSize=13, TextColor3="Text", PlaceholderColor3="SubText", TextXAlignment=Enum.TextXAlignment.Left, ThemeTag={TextColor3="Text", PlaceholderColor3="SubText"}})
        box.FocusLost:Connect(function() 
            if options.Callback then options.Callback(box.Text) end 
            if options.Flag and window then window.Flags[options.Flag] = box.Text end
        end)
        return self
    end

    -- Dropdown
    Elements.Dropdown = {}
    Elements.Dropdown.__index = Elements.Dropdown
    function Elements.Dropdown.new(container, options, window)
        local self = setmetatable({Value=options.Default, Options=options, Window=window}, Elements.Dropdown)
        if not self.Value and #options.Values>0 then self.Value = options.Values[1] end
        if options.Flag and window then window.Flags[options.Flag] = self.Value end
        
        local f = Creator.New("TextButton", {Parent=container, Size=UDim2.new(1,0,0,60), BackgroundTransparency=1, Text="", AutoButtonColor=false})
        Creator.New("TextLabel", {Parent=f, Size=UDim2.new(1,0,0,20), BackgroundTransparency=1, Text=options.Title or "Dropdown", Font=Enum.Font.GothamMedium, TextSize=13, TextColor3="Text", TextXAlignment=Enum.TextXAlignment.Left, ThemeTag={TextColor3="Text"}})
        local disp = Creator.New("TextButton", {Parent=f, Size=UDim2.new(1,0,0,32), Position=UDim2.new(0,0,0,22), BackgroundColor3="Surface2", ThemeTag={BackgroundColor3="Surface2"}, Text="", AutoButtonColor=false}); Creator.AddCorner(disp, 6)
        local lbl = Creator.New("TextLabel", {Parent=disp, Size=UDim2.new(1,-30,1,0), Position=UDim2.fromOffset(10,0), BackgroundTransparency=1, Text=tostring(self.Value), Font=Enum.Font.Gotham, TextSize=13, TextColor3="SubText", TextXAlignment=Enum.TextXAlignment.Left, ThemeTag={TextColor3="SubText"}})
        Creator.New("ImageLabel", {Parent=disp, Size=UDim2.fromOffset(16,16), Position=UDim2.new(1,-26,0.5,-8), BackgroundTransparency=1, Image=Utility.GetIcon("chevron-down"), ImageColor3="SubText", ThemeTag={ImageColor3="SubText"}})
        
        local open = false
        local listFrame
        
        disp.MouseButton1Click:Connect(function()
            open = not open
            if open then
                listFrame = Creator.New("Frame", {Parent=window.Gui, Size=UDim2.new(0, f.AbsoluteSize.X, 0, math.min(#options.Values*25, 200)), Position=UDim2.fromOffset(disp.AbsolutePosition.X, disp.AbsolutePosition.Y+35), BackgroundColor3="Surface2", ZIndex=200, ClibDescendants=true}); Creator.AddCorner(listFrame, 6)
                local sc = Creator.New("ScrollingFrame", {Parent=listFrame, Size=UDim2.new(1,0,1,0), BackgroundTransparency=1, CanvasSize=UDim2.new(0,0,0,#options.Values*25)}); Instance.new("UIListLayout", sc)
                for _, v in ipairs(options.Values) do
                    local b = Creator.New("TextButton", {Parent=sc, Size=UDim2.new(1,0,0,25), BackgroundTransparency=1, Text="   "..v, TextXAlignment=Enum.TextXAlignment.Left, TextColor3="SubText", Font=Enum.Font.Gotham, TextSize=13, ThemeTag={TextColor3="SubText"}})
                    b.MouseButton1Click:Connect(function()
                        self.Value = v; lbl.Text = v; open = false; listFrame:Destroy(); 
                        if options.Callback then options.Callback(v) end
                        if options.Flag and window then window.Flags[options.Flag] = v end
                    end)
                end
            elseif listFrame then listFrame:Destroy() end
        end)
        return self
    end

    -- Keybind
    Elements.Keybind = {}
    Elements.Keybind.__index = Elements.Keybind
    function Elements.Keybind.new(container, options, window)
        local self = setmetatable({Value=options.Default}, Elements.Keybind)
        if options.Flag and window then window.Flags[options.Flag] = self.Value end
        local f = Creator.New("Frame", {Parent=container, Size=UDim2.new(1,0,0,32), BackgroundTransparency=1})
        Creator.New("TextLabel", {Parent=f, Size=UDim2.new(1,-80,1,0), BackgroundTransparency=1, Text=options.Title, Font=Enum.Font.GothamMedium, TextSize=13, TextColor3="Text", TextXAlignment=Enum.TextXAlignment.Left, ThemeTag={TextColor3="Text"}})
        local b = Creator.New("TextButton", {Parent=f, Size=UDim2.new(0,80,0,24), Position=UDim2.new(1,-80,0,4), BackgroundColor3="Surface2", ThemeTag={BackgroundColor3="Surface2"}, Text="", AutoButtonColor=false}); Creator.AddCorner(b, 4)
        local lbl = Creator.New("TextLabel", {Parent=b, Size=UDim2.new(1,0,1,0), BackgroundTransparency=1, Text=self.Value and self.Value.Name or "None", Font=Enum.Font.Gotham, TextSize=12, TextColor3="SubText", ThemeTag={TextColor3="SubText"}})
        b.MouseButton1Click:Connect(function()
            lbl.Text = "..."
            local conn; conn = game:GetService("UserInputService").InputBegan:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.Keyboard then
                    self.Value = i.KeyCode; lbl.Text = i.KeyCode.Name; conn:Disconnect()
                    if options.Callback then options.Callback(i.KeyCode) end
                    if options.Flag and window then window.Flags[options.Flag] = i.KeyCode end
                end
            end)
        end)
        return self
    end

    -- ColorPicker
    Elements.ColorPicker = {}
    Elements.ColorPicker.__index = Elements.ColorPicker
    function Elements.ColorPicker.new(container, options, window)
        local self = setmetatable({Value=options.Default or Color3.new(1,1,1)}, Elements.ColorPicker)
        local f = Creator.New("TextButton", {Parent=container, Size=UDim2.new(1,0,0,40), BackgroundTransparency=1, Text="", AutoButtonColor=false})
        Creator.New("TextLabel", {Parent=f, Size=UDim2.new(1,-60,1,0), BackgroundTransparency=1, Text=options.Title, Font=Enum.Font.GothamMedium, TextSize=13, TextColor3="Text", TextXAlignment=Enum.TextXAlignment.Left, ThemeTag={TextColor3="Text"}})
        local ind = Creator.New("Frame", {Parent=f, Size=UDim2.fromOffset(40,20), Position=UDim2.new(1,-40,0.5,-10), BackgroundColor3=self.Value}); Creator.AddCorner(ind, 4)
        f.MouseButton1Click:Connect(function() 
            -- Simplified color picker for bundled dist - usually complex
            -- Just randomizing for demo if clicked or would need full RGB sliders
            if options.Callback then options.Callback(self.Value) end
        end)
        return self
    end

    -- Section
    Elements.Section = {}
    Elements.Section.__index = Elements.Section
    function Elements.Section.new(container, options)
        local self = setmetatable({}, Elements.Section)
        local f = Creator.New("Frame", {Parent=container, Size=UDim2.new(1,0,0,0), BackgroundColor3="Surface", AutomaticSize=Enum.AutomaticSize.Y, ThemeTag={BackgroundColor3="Surface"}}); Creator.AddCorner(f, 6)
        Creator.New("TextLabel", {Parent=f, Size=UDim2.new(1,-10,0,25), Position=UDim2.fromOffset(10,0), BackgroundTransparency=1, Text=options.Title, Font=Enum.Font.GothamBold, TextSize=13, TextColor3="Text", TextXAlignment=Enum.TextXAlignment.Left, ThemeTag={TextColor3="Text"}})
        self.Content = Creator.New("Frame", {Parent=f, Size=UDim2.new(1,-20,0,0), Position=UDim2.fromOffset(10,25), BackgroundTransparency=1, AutomaticSize=Enum.AutomaticSize.Y})
        Instance.new("UIListLayout", self.Content).Padding = UDim.new(0,8)
        Creator.AddPadding(self.Content, 4)
        return self
    end
    -- Proxy methods for Section to act like a container
    function Elements.Section:AddButton(o) return Elements.Button.new(self.Content, o) end
    function Elements.Section:AddToggle(o) return Elements.Toggle.new(self.Content, o) end 
    -- ... etc, simplified for now
    
    return Elements
end

-- [[ Module: ConfigManager ]] --
modules["ConfigManager"] = function() 
    local CM = {}
    CM.__index = CM
    function CM.new(folder, flags) return setmetatable({Folder=folder, Flags=flags}, CM) end
    function CM:Save(name) 
        if writefile then writefile(self.Folder.."/"..name..".json", game:GetService("HttpService"):JSONEncode(self.Flags)) end 
    end
    function CM:Load(name)
        if readfile and isfile(self.Folder.."/"..name..".json") then 
            local s,d = pcall(function() return game:GetService("HttpService"):JSONDecode(readfile(self.Folder.."/"..name..".json")) end)
            if s then for k,v in pairs(d) do self.Flags[k]=v end end
        end
    end
    return CM
end

-- [[ Module: Tab ]] --
modules["Tab"] = function()
    local Creator = modules["Creator"]()
    local ThemeManager = modules["ThemeManager"]()
    local Utility = modules["Utility"]()
    local Elements = modules["Elements"]()
    local Tab = {}
    Tab.__index = Tab
    function Tab.new(window, options)
        local self = setmetatable({Window=window, Title=options.Title}, Tab)
        self.Button = Creator.New("TextButton", {Parent=window.SidebarList, Size=UDim2.new(1,0,0,32), BackgroundTransparency=1, Text=""})
        Creator.New("TextLabel", {Parent=self.Button, Size=UDim2.new(1,-10,1,0), Position=UDim2.new(0,10,0,0), Text=self.Title, BackgroundTransparency=1, TextColor3="SubText", Font=Enum.Font.GothamMedium, TextSize=14, TextXAlignment=Enum.TextXAlignment.Left, ThemeTag={TextColor3="SubText"}})
        self.Container = Creator.New("ScrollingFrame", {Parent=window.Content, Size=UDim2.new(1,0,1,0), BackgroundTransparency=1, Visible=false, CanvasSize=UDim2.new(0,0,0,0), ScrollBarThickness=2})
        Creator.AddPadding(self.Container, 15)
        local list = Instance.new("UIListLayout", self.Container); list.Padding=UDim.new(0,10); list.SortOrder=Enum.SortOrder.LayoutOrder
        list:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() self.Container.CanvasSize = UDim2.new(0,0,0,list.AbsoluteContentSize.Y+30) end)
        self.Button.MouseButton1Click:Connect(function() self:Select() end)
        return self
    end
    function Tab:Select()
        for _, t in ipairs(self.Window.Tabs) do 
            t.Container.Visible=false 
            t.Button.BackgroundTransparency=1
            -- Simplified theme update logic for dist
        end
        self.Container.Visible = true
        self.Button.BackgroundTransparency=0
        self.Button.BackgroundColor3=ThemeManager:GetColor("Surface2")
    end
    function Tab:AddButton(opt) return Elements.Button.new(self.Container, opt) end
    function Tab:AddToggle(opt) return Elements.Toggle.new(self.Container, opt, self.Window) end
    function Tab:AddSlider(opt) return Elements.Slider.new(self.Container, opt, self.Window) end
    function Tab:AddLabel(opt) return Elements.Label.new(self.Container, opt) end
    function Tab:AddParagraph(opt) return Elements.Paragraph.new(self.Container, opt) end
    function Tab:AddInput(opt) return Elements.Input.new(self.Container, opt, self.Window) end
    function Tab:AddDropdown(opt) return Elements.Dropdown.new(self.Container, opt, self.Window) end
    function Tab:AddKeybind(opt) return Elements.Keybind.new(self.Container, opt, self.Window) end
    function Tab:AddColorPicker(opt) return Elements.ColorPicker.new(self.Container, opt, self.Window) end
    function Tab:AddSection(opt) return Elements.Section.new(self.Container, opt) end
    
    return Tab
end

-- [[ Module: Window ]] --
modules["Window"] = function()
    local Creator = modules["Creator"]()
    local Utility = modules["Utility"]()
    local ConfigManager = modules["ConfigManager"]()
    local Tab = modules["Tab"]()
    local ThemeManager = modules["ThemeManager"]()
    
    local Window = {}
    Window.__index = Window
    function Window.new(options)
        local self = setmetatable({Tabs={}, Flags={}}, Window)
        self.ConfigManager = ConfigManager.new(options.Folder, self.Flags)
        
        local target = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
        pcall(function() if gethui then target = gethui() end end)
        self.Gui = Instance.new("ScreenGui", target); self.Gui.Name="Difulent"
        
        self.Main = Creator.New("Frame", {Parent=self.Gui, Size=options.Size or UDim2.fromOffset(580,460), Position=UDim2.fromScale(0.5,0.5), AnchorPoint=Vector2.new(0.5,0.5), BackgroundColor3="Background", ThemeTag={BackgroundColor3="Background"}})
        Creator.AddCorner(self.Main, 10)
        Utility.EnableDragging(self.Main)
        
        self.Sidebar = Creator.New("Frame", {Parent=self.Main, Size=UDim2.new(0,200,1,0), BackgroundColor3="Surface", ThemeTag={BackgroundColor3="Surface"}})
        Creator.AddCorner(self.Sidebar, 10)
        
        self.SidebarList = Creator.New("ScrollingFrame", {Parent=self.Sidebar, Size=UDim2.new(1,0,1,-50), Position=UDim2.new(0,0,0,50), BackgroundTransparency=1, CanvasSize=UDim2.new(0,0,0,0)})
        Instance.new("UIListLayout", self.SidebarList).Padding = UDim.new(0,5)
        Creator.AddPadding(self.SidebarList, 10)
        
        Creator.New("TextLabel", {Parent=self.Sidebar, Size=UDim2.new(1,-20,0,40), Position=UDim2.new(0,10,0,5), Text=options.Title, TextSize=18, Font=Enum.Font.GothamBold, BackgroundTransparency=1, TextColor3="Text", TextXAlignment=Enum.TextXAlignment.Left, ThemeTag={TextColor3="Text"}})
        self.Content = Creator.New("Frame", {Parent=self.Main, Size=UDim2.new(1,-200,1,0), Position=UDim2.new(0,200,0,0), BackgroundTransparency=1})
        
        -- Notification Holder
        self.NotifHolder = Instance.new("Frame", self.Gui)
        self.NotifHolder.Size = UDim2.new(1,-20,1,-20); self.NotifHolder.Position=UDim2.new(0,10,0,10); self.NotifHolder.BackgroundTransparency=1; self.NotifHolder.ZIndex=100
        local nl = Instance.new("UIListLayout", self.NotifHolder); nl.VerticalAlignment=Enum.VerticalAlignment.Bottom; nl.HorizontalAlignment=Enum.HorizontalAlignment.Right; nl.Padding=UDim.new(0,5)
        
        return self
    end
    function Window:AddTab(opt)
        local t = Tab.new(self, opt)
        table.insert(self.Tabs, t)
        if #self.Tabs==1 then t:Select() end
        return t
    end
    function Window:Notify(opt)
        local f = Creator.New("Frame", {Parent=self.NotifHolder, Size=UDim2.new(0,250,0,60), BackgroundColor3="Surface", ThemeTag={BackgroundColor3="Surface"}}); Creator.AddCorner(f,8)
        Creator.New("TextLabel", {Parent=f, Size=UDim2.new(1,-10,0,20), Position=UDim2.fromOffset(10,5), Text=opt.Title, Font=Enum.Font.GothamBold, TextSize=14, TextColor3="Text", BackgroundTransparency=1, TextXAlignment=Enum.TextXAlignment.Left, ThemeTag={TextColor3="Text"}})
        Creator.New("TextLabel", {Parent=f, Size=UDim2.new(1,-10,0,30), Position=UDim2.fromOffset(10,25), Text=opt.Content, Font=Enum.Font.Gotham, TextSize=12, TextColor3="SubText", BackgroundTransparency=1, TextXAlignment=Enum.TextXAlignment.Left, TextWrapped=true, ThemeTag={TextColor3="SubText"}})
        task.delay(opt.Duration or 3, function() f:Destroy() end)
    end
    return Window
end

-- [[ Main ]] --
local Library = modules["Window"]()
local TM = modules["ThemeManager"]()

local Interface = {}
function Interface.CreateWindow(options) return Library.new(options) end
function Interface:SetTheme(t) TM:SetTheme(t) end

return Interface
