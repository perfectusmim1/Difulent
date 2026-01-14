local WindUI = require("./src/Init")

-- [ Localization Setup ]
local Localization = WindUI:Localization({
    Enabled = true,
    Prefix = "loc:",
    DefaultLanguage = "en",
    Translations = {
        ["en"] = {
            ["WINDOW_TITLE"] = "Difulent Hub | Premium Edition",
            ["WELCOME_MSG"] = "Welcome back, Operator.",
            ["TAB_MAIN"] = "Main",
            ["TAB_FEATURES"] = "Combat",
            ["TAB_VISUALS"] = "Visuals",
            ["TAB_MISC"] = "Automation",
            ["TAB_SETTINGS"] = "Settings",
            ["SECTION_GENERAL"] = "General Configuration",
            ["SECTION_APPEARANCE"] = "Aesthetics",
            ["SECTION_AUTHENTICATION"] = "Security",
            ["STATUS_CONNECTED"] = "Status: Connected",
            ["VERSION_INFO"] = "Build v1.6.64 [Stable]"
        }
    }
})

-- [ Styling ]
WindUI:SetTheme("Dark")
WindUI.TransparencyValue = 0.15

-- [ Window Creation ]
local Window = WindUI:CreateWindow({
    Title = "loc:WINDOW_TITLE",
    Icon = "lucide:shield-check",
    Author = "loc:WELCOME_MSG",
    Folder = "DifulentData",
    Size = UDim2.fromOffset(620, 520),
    Theme = "Dark",
    Acrylic = true,
    Transparent = true,
    HideSearchBar = false,
    User = {
        Enabled = true,
        Anonymous = false, -- Shows player avatar if false
    },
    OpenButton = {
        Title = "Open Difulent",
        Enabled = true,
        Draggable = true,
        Color = ColorSequence.new(
            Color3.fromHex("#1e1e2e"),
            Color3.fromHex("#313244")
        )
    }
})

-- [ Main Tab ]
do
    local MainTab = Window:Tab({
        Title = "loc:TAB_MAIN",
        Icon = "lucide:home",
    })

    local InfoSection = MainTab:Section({
        Title = "Information",
    })

    InfoSection:Paragraph({
        Title = "System Status",
        Content = "loc:STATUS_CONNECTED\nloc:VERSION_INFO"
    })

    MainTab:Button({
        Title = "Establish Secure Connection",
        Desc = "Refreshes the internal communication link.",
        Icon = "lucide:refresh-cw",
        Callback = function()
            WindUI:Notify({
                Title = "System Update",
                Content = "Connection re-established successfully.",
                Duration = 3
            })
        end
    })

    MainTab:Space()

    local AuthSection = MainTab:Section({
        Title = "loc:SECTION_AUTHENTICATION",
    })

    AuthSection:Input({
        Title = "Activation Key",
        Desc = "Enter your license key here.",
        Placeholder = "XXXX-XXXX-XXXX-XXXX",
        Callback = function(text)
            print("Key input: ", text)
        end
    })
end

-- [ Combat Tab ]
do
    local CombatTab = Window:Tab({
        Title = "loc:TAB_FEATURES",
        Icon = "lucide:swords",
    })

    local AimbotSection = CombatTab:Section({
        Title = "Targeting System",
    })

    AimbotSection:Toggle({
        Title = "Aimbot",
        Desc = "Automatically aligns your trajectory with targets.",
        Value = false,
        Callback = function(state)
            print("Aimbot: ", state)
        end
    })

    AimbotSection:Slider({
        Title = "Field of View",
        Desc = "Adjust the targeting radius.",
        Step = 1,
        Value = {
            Min = 0,
            Max = 360,
            Default = 90
        },
        Callback = function(val)
            print("FOV: ", val)
        end
    })

    AimbotSection:Dropdown({
        Title = "Target Origin",
        Values = {"Head", "Torso", "Random"},
        Default = "Head",
        Callback = function(val)
            print("Target: ", val)
        end
    })
end

-- [ Visuals Tab ]
do
    local VisualsTab = Window:Tab({
        Title = "loc:TAB_VISUALS",
        Icon = "lucide:eye",
    })

    local EspSection = VisualsTab:Section({
        Title = "Enhanced Perception",
    })

    EspSection:Toggle({
        Title = "Player Outlines",
        Desc = "Highlights entities through geometric obstructions.",
        Value = true,
        Callback = function(state)
            print("ESP: ", state)
        end
    })

    EspSection:Colorpicker({
        Title = "Overlay Color",
        Default = Color3.fromHex("#cba6f7"),
        Callback = function(color)
            print("ESP Color: ", color)
        end
    })
end

-- [ Settings Tab ]
do
    local SettingsTab = Window:Tab({
        Title = "loc:TAB_SETTINGS",
        Icon = "lucide:settings",
    })

    local AppearanceSection = SettingsTab:Section({
        Title = "loc:SECTION_APPEARANCE",
    })

    AppearanceSection:Toggle({
        Title = "Acrylic Blur",
        Desc = "Toggle the high-quality background blur effect.",
        Value = true,
        Callback = function(state)
            WindUI:ToggleAcrylic(state)
        end
    })

    AppearanceSection:Slider({
        Title = "Interface Scale",
        Desc = "Resize the overall UI components.",
        Step = 0.1,
        Value = {
            Min = 0.5,
            Max = 1.5,
            Default = 1.0
        },
        Callback = function(val)
            -- Window:SetUIScale(val) -- If method exists
        end
    })

    SettingsTab:Button({
        Title = "Unload Interface",
        Desc = "Safely closes and cleans up all UI resources.",
        Icon = "lucide:log-out",
        Color = Color3.fromHex("#f38ba8"),
        Callback = function()
            Window:Destroy()
        end
    })
end

print("Difulent Hub initialized with WindUI Framework.")
return WindUI
