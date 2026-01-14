-- Difulent Example (Executor)
-- This script uses the loadstring URL pointing to your repository.

local repo = "https://raw.githubusercontent.com/perfectusmim1/Difulent/main/dist/main.lua"
local Library = loadstring(game:HttpGet(repo))()

-- Notify if library failed to load
if not Library then
    return game.StarterGui:SetCore("SendNotification", {
        Title = "Error",
        Text = "Failed to load Difulent Library",
        Duration = 5
    })
end

-- Create Window
local Window = Library.CreateWindow({
    Title = "Difulent Hub",
    SubTitle = "Executor Demo",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Material = "Acrylic", -- Options: "Acrylic", "Solid", "Transparent"
    Resize = true,
    Folder = "DifulentSettings", -- Config folder name
    ToggleKey = Enum.KeyCode.RightShift
})

-- [[ Main Tab ]]
local MainTab = Window:AddTab({ Title = "Main", Icon = "home" })

MainTab:AddLabel({ Title = "Welcome User" })
MainTab:AddParagraph({ 
    Title = "Status Statement",
    Content = "Verified that the library successfully loads from the repository.\nFull interaction demo below." 
})

MainTab:AddButton({
    Title = "Test Notification",
    Callback = function()
        Window:Notify({
            Title = "Hello!",
            Content = "This is a notification from Difulent.",
            Duration = 3
        })
    end
})

MainTab:AddButton({
    Title = "Open Dialog",
    Callback = function()
        Window:Dialog({
            Title = "Confirm Action",
            Content = "Do you want to continue?",
            Buttons = {
                {
                    Title = "Yes",
                    Primary = true,
                    Callback = function()
                        Window:Notify({ Title = "Dialog", Content = "Confirmed.", Duration = 2 })
                    end
                },
                { Title = "Cancel" }
            }
        })
    end
})

MainTab:AddButton({
    Title = "Open Popup",
    Callback = function()
        Window:Popup({
            Items = {
                { Title = "Copy Discord", Icon = "copy", Callback = function()
                    if setclipboard then setclipboard("https://discord.gg/example") end
                    Window:Notify({ Title = "Popup", Content = "Copied link.", Duration = 2 })
                end },
                { Separator = true },
                { Title = "Toggle Option", Toggle = true, Checked = true, KeepOpen = true, Callback = function(state)
                    Window:Notify({ Title = "Popup", Content = "Toggle: " .. tostring(state), Duration = 2 })
                end }
            }
        })
    end
})

MainTab:AddToggle({
    Title = "Auto Farm",
    Default = false,
    Flag = "AutoFarm",
    Callback = function(val)
        print("Auto Farm set to:", val)
    end
})

MainTab:AddSlider({
    Title = "WalkSpeed",
    Min = 16,
    Max = 200,
    Default = 16,
    Step = 1,
    Flag = "WalkSpeed",
    Callback = function(val)
        pcall(function()
            game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = val
        end)
    end
})

-- [[ Features Tab ]]
local FeaturesTab = Window:AddTab({ Title = "Features", Icon = "layers" })

FeaturesTab:AddDropdown({
    Title = "Select Weapon",
    Values = {"Sword", "Bow", "Magic Staff", "Dagger"},
    Default = "Sword",
    Multi = false,
    Flag = "WeaponSelect",
    Callback = function(val)
        print("Selected Weapon:", val)
    end
})

FeaturesTab:AddDropdown({
    Title = "Multi Select",
    Values = {"Option A", "Option B", "Option C", "Option D"},
    Default = {},
    Multi = true,
    Flag = "MultiOptions",
    Callback = function(val)
        -- val is a table { ["Option A"] = true, ... }
        print("Multi selection changed")
    end
})

FeaturesTab:AddColorPicker({
    Title = "ESP Color",
    Default = Color3.fromRGB(255, 0, 0),
    Flag = "EspColor",
    Callback = function(color)
        print("Color changed:", color)
    end
})

FeaturesTab:AddInput({
    Title = "Custom Status",
    Default = "",
    Placeholder = "Enter text here...",
    Flag = "CustomStatus",
    Callback = function(text)
        print("Input:", text)
    end
})

-- [[ Settings Tab ]]
local SettingsTab = Window:AddTab({ Title = "Settings", Icon = "settings" })

-- Config UI (Save/Load/Export/Import)
Window:CreateConfigUI(SettingsTab, {
    SectionTitle = "Config Manager",
    Collapsible = true,
    Opened = true
})

SettingsTab:AddKeybind({
    Title = "Toggle UI Key",
    Default = Enum.KeyCode.RightShift,
    Flag = "ToggleKey",
    Callback = function()
        -- This is just the keybind element callback
        print("Keybind pressed")
    end
})

-- Theme Section
local ThemeSection = SettingsTab:AddSection({ Title = "Themes" })

ThemeSection:AddButton({ Title = "Dark Theme", Callback = function() Library:SetTheme("Dark") end })
ThemeSection:AddButton({ Title = "Midnight Theme", Callback = function() Library:SetTheme("Midnight") end })
ThemeSection:AddButton({ Title = "Ocean Theme", Callback = function() Library:SetTheme("Ocean") end })

-- Completion
Window:Notify({
    Title = "Loaded",
    Content = "Difulent Library script executed successfully.",
    Duration = 5
})
