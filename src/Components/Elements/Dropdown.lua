-- Phantasm Dropdown
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Creator = require(script.Parent.Parent.Parent.Creator)
local Utility = require(script.Parent.Parent.Parent.Utils.Utility)
local ThemeManager = require(script.Parent.Parent.Parent.ThemeManager)

local Dropdown = {}
Dropdown.__index = Dropdown

function Dropdown.new(container, options, window)
    local self = setmetatable({}, Dropdown)
    
    self.Window = window
    self.Options = options
    self.Values = options.Values or {}
    self.Multi = options.Multi or false
    self.Value = options.Default
    self.Callback = options.Callback or function() end
    self.Flag = options.Flag
    
    if self.Multi then
        self.Value = self.Value or {}
    else
        self.Value = self.Value or (self.Values[1] or "")
    end
    
    if self.Flag and self.Window then
        self.Window.Flags[self.Flag] = self.Value
    end
    
    -- Main Button
    self.Frame = Creator.New("TextButton", {
        Parent = container,
        Size = UDim2.new(1, 0, 0, 44),
        BackgroundColor3 = "Surface", -- Background for element area
        BackgroundTransparency = 1,
        Text = "",
        AutoButtonColor = false
    })
    
    -- Title
    self.TitleLabel = Creator.New("TextLabel", {
        Parent = self.Frame,
        Size = UDim2.new(1, 0, 0, 20),
        BackgroundTransparency = 1,
        Text = options.Title or "Dropdown",
        Font = Enum.Font.GothamMedium,
        TextSize = 13,
        TextColor3 = "Text",
        TextXAlignment = Enum.TextXAlignment.Left,
        ThemeTag = {TextColor3 = "Text"}
    })
    
    -- Display Box
    self.Display = Creator.New("TextButton", {
        Parent = self.Frame,
        Size = UDim2.new(1, 0, 0, 32),
        Position = UDim2.new(0, 0, 0, 22),
        BackgroundColor3 = "Surface2",
        ThemeTag = {BackgroundColor3 = "Surface2"},
        Text = "",
        AutoButtonColor = false
    })
    Creator.AddCorner(self.Display, 6)
    
    self.DisplayLabel = Creator.New("TextLabel", {
        Parent = self.Display,
        Size = UDim2.new(1, -30, 1, 0),
        Position = UDim2.fromOffset(10, 0),
        BackgroundTransparency = 1,
        Text = self:GetText(),
        Font = Enum.Font.Gotham,
        TextSize = 13,
        TextColor3 = "SubText",
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        ThemeTag = {TextColor3 = "SubText"}
    })
    
    self.Icon = Creator.New("ImageLabel", {
        Parent = self.Display,
        Size = UDim2.fromOffset(16, 16),
        Position = UDim2.new(1, -26, 0.5, -8),
        BackgroundTransparency = 1,
        Image = Utility.GetIcon("chevron-down"),
        ImageColor3 = "SubText",
        ThemeTag = {ImageColor3 = "SubText"}
    })
    
    self.Frame.ManualSize = UDim2.new(1, 0, 0, 60)
    self.Frame.AutomaticSize = Enum.AutomaticSize.None
    self.Frame.Size = UDim2.new(1, 0, 0, 60)

    -- List Logic
    self.ListOpen = false
    self.ListFrame = nil
    
    self.Display.MouseButton1Click:Connect(function()
        self:Toggle()
    end)
    
    return self
end

function Dropdown:GetText()
    if self.Multi then
        local t = {}
        for k,v in pairs(self.Value) do
            if v then table.insert(t, k) end
        end
        return #t > 0 and table.concat(t, ", ") or "None"
    else
        return tostring(self.Value)
    end
end

function Dropdown:Toggle()
    if self.ListOpen then
        self:Close()
    else
        self:Open()
    end
end

function Dropdown:Open()
    if self.ListOpen then return end
    self.ListOpen = true
    
    -- Close others? Ideally yes, via a global event.
    
    Utility.Tween(self.Icon, TweenInfo.new(0.2), {Rotation = 180})
    
    -- Create List Frame in ScreenGui for ZIndex
    local gui = self.Window.Gui
    
    self.ListFrame = Creator.New("Frame", {
        Parent = gui,
        Size = UDim2.new(0, self.Display.AbsoluteSize.X, 0, 0),
        Position = UDim2.fromOffset(self.Display.AbsolutePosition.X, self.Display.AbsolutePosition.Y + self.Display.AbsoluteSize.Y + 5),
        BackgroundColor3 = "Surface2",
        ThemeTag = {BackgroundColor3 = "Surface2"},
        ClipsDescendants = true,
        ZIndex = 200
    })
    Creator.AddCorner(self.ListFrame, 6)
    Creator.AddStroke(self.ListFrame, {Color="Outline", ThemeTag={Color="Outline"}})
    
    local listLayout = Instance.new("UIListLayout")
    listLayout.Parent = self.ListFrame
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    
    -- Search
    local searchBox = Creator.New("TextBox", {
        Parent = self.ListFrame,
        Size = UDim2.new(1, -10, 0, 25),
        BackgroundTransparency = 1,
        PlaceholderText = "Search...",
        Text = "",
        TextColor3 = "Text",
        Font = Enum.Font.Gotham,
        TextSize = 13,
        ThemeTag = {TextColor3 = "Text", PlaceholderColor3 = "SubText"}
    })
    local pad = Instance.new("UIPadding")
    pad.PaddingLeft = UDim.new(0, 5)
    pad.PaddingTop = UDim.new(0, 5)
    pad.Parent = searchBox
    
    local scroll = Creator.New("ScrollingFrame", {
        Parent = self.ListFrame,
        Size = UDim2.new(1, 0, 1, -30),
        BackgroundTransparency = 1,
        CanvasSize = UDim2.new(0,0,0,0),
        ScrollBarThickness = 2
    })
    local uiList = Instance.new("UIListLayout")
    uiList.Parent = scroll
    
    -- Populate
    local function Populate(filter)
        for _, c in ipairs(scroll:GetChildren()) do if c:IsA("GuiObject") then c:Destroy() end end
        
        local count = 0
        for _, val in ipairs(self.Values) do
            if not filter or string.find(string.lower(val), string.lower(filter)) then
                local btn = Creator.New("TextButton", {
                    Parent = scroll,
                    Size = UDim2.new(1, 0, 0, 25),
                    BackgroundTransparency = 1,
                    Text = "   " .. val,
                    TextColor3 = "SubText",
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Font = Enum.Font.Gotham,
                    TextSize = 13,
                    ThemeTag = {TextColor3 = "SubText"}
                })
                
                -- Selected state
                local isSelected = false
                if self.Multi then isSelected = self.Value[val]
                else isSelected = (self.Value == val) end
                
                if isSelected then
                    btn.TextColor3 = ThemeManager:GetColor("Accent")
                    btn.Font = Enum.Font.GothamBold
                end
                
                btn.MouseButton1Click:Connect(function()
                    if self.Multi then
                        if self.Value[val] then self.Value[val] = nil else self.Value[val] = true end
                    else
                        self.Value = val
                        self:Close()
                    end
                    self:Update()
                end)
                count = count + 1
            end
        end
        scroll.CanvasSize = UDim2.new(0,0,0, count * 25)
    end
    
    Populate()
    
    searchBox:GetPropertyChangedSignal("Text"):Connect(function()
        Populate(searchBox.Text)
    end)
    
    -- Animate Open
    local targetHeight = math.min(#self.Values * 25 + 35, 200)
    Utility.Tween(self.ListFrame, TweenInfo.new(0.2), {Size = UDim2.new(0, self.Display.AbsoluteSize.X, 0, targetHeight)})
    
    -- Close on click outside (Maid needed ideally)
    -- Simplification: Just one open at a time logic if implemented in Library
end

function Dropdown:Close()
    if not self.ListOpen then return end
    self.ListOpen = false
    Utility.Tween(self.Icon, TweenInfo.new(0.2), {Rotation = 0})
    
    if self.ListFrame then
        Utility.Tween(self.ListFrame, TweenInfo.new(0.2), {Size = UDim2.new(0, self.Display.AbsoluteSize.X, 0, 0)}, function()
            self.ListFrame:Destroy()
            self.ListFrame = nil
        end)
    end
end

function Dropdown:Update()
    self.DisplayLabel.Text = self:GetText()
    
    if self.Flag and self.Window then
        self.Window.Flags[self.Flag] = self.Value
    end
    self.Callback(self.Value)
end

function Dropdown:Set(val)
    self.Value = val
    self:Update()
end

function Dropdown:Refresh(newVals)
    self.Values = newVals
    if not self.Multi then
        if not table.find(self.Values, self.Value) then
            self.Value = self.Values[1]
        end
    end
    self:Update()
end

return Dropdown
