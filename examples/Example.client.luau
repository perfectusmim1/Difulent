-- Phantasm Example (Client / Studio)
local Library = loadstring(game:HttpGet(https://raw.githubusercontent.com/perfectusmim1/Difulent/main/dist/main.lua))()

local Window = Library.CreateWindow({
    Title = "Phantasm Example",
    SubTitle = "by Antigravity",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Material = "Acrylic", -- If supported
    Resize = true
})

Window:AddTab({ Title = "Main", Icon = "home" })
local MainTab = Window.Tabs[1] -- Access enabled

MainTab:AddLabel({ Title = "Welcome to Phantasm" })
MainTab:AddParagraph({ Title = "Information", Content = "This is a robust UI library built for production." })

MainTab:AddButton({
    Title = "Click Me",
    Callback = function()
        print("Button clicked!")
        Library:Notify({Title = "Success", Content = "Button was clicked", Duration = 2})
    end
})

MainTab:AddToggle({
    Title = "Enable Logic",
    Default = false,
    Flag = "LogicToggle",
    Callback = function(val)
        print("Logic is now:", val)
    end
})

MainTab:AddSlider({
    Title = "WalkSpeed",
    Min = 16,
    Max = 100,
    Default = 16,
    Flag = "WalkSpeed",
    Callback = function(val)
        -- game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = val
        print("Speed:", val)
    end
})

local SettingsTab = Window:AddTab({ Title = "Settings", Icon = "settings" })

SettingsTab:AddButton({
    Title = "Dark Theme",
    Callback = function() Library:SetTheme("Dark") end
})

SettingsTab:AddButton({
    Title = "Midnight Theme",
    Callback = function() Library:SetTheme("Midnight") end
})

-- Handle Window destruction
Window.OnClose:Connect(function()
    print("Window closed")
end)
