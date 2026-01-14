-- Phantasm Example (Studio / PlayerGui)
-- Place the repo's `src/` folder under `ReplicatedStorage/Phantasm/src`
-- Then put this LocalScript in StarterPlayerScripts (or anywhere client-side).

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local root = ReplicatedStorage:FindFirstChild("Phantasm") or ReplicatedStorage:FindFirstChild("Difulent")
assert(root, "Missing ReplicatedStorage.Phantasm (or Difulent) folder containing src/")

local src = root:FindFirstChild("src")
assert(src, "Missing folder: " .. root:GetFullName() .. ".src")

local Library = require(src:WaitForChild("init"))

local Window = Library.CreateWindow({
	Title = "Phantasm UI",
	SubTitle = "Studio Demo",
	Icon = "layers",
	TabWidth = 220,
	Size = UDim2.fromOffset(640, 460),
	Material = "Acrylic",
	Resize = true,
	Folder = "PhantasmStudio",
	ToggleKey = Enum.KeyCode.RightShift,
})

local Main = Window:AddTab({ Title = "Main", Icon = "home" })
Main:AddParagraph({
	Title = "Welcome",
	Content = "This is a real, runnable Studio example.\nRightShift toggles the UI.",
})
Main:AddButton({
	Title = "Test Notification",
	Callback = function()
		Window:Notify({ Title = "Hello", Content = "Notification works.", Duration = 3 })
	end,
})

local Features = Window:AddTab({ Title = "Features", Icon = "layers" })
Features:AddToggle({
	Title = "Enable Something",
	Default = false,
	Flag = "EnableSomething",
	Callback = function(v)
		print("Toggle:", v)
	end,
})
Features:AddSlider({
	Title = "Volume",
	Min = 0,
	Max = 100,
	Default = 50,
	Step = 1,
	Suffix = "%",
	Flag = "Volume",
	Callback = function(v)
		print("Slider:", v)
	end,
})
Features:AddDropdown({
	Title = "Single Select",
	Values = { "One", "Two", "Three" },
	Default = "Two",
	Flag = "SingleSelect",
	Callback = function(v)
		print("Dropdown:", v)
	end,
})
Features:AddDropdown({
	Title = "Multi Select",
	Values = { "A", "B", "C", "D" },
	Default = { A = true, C = true },
	Multi = true,
	Flag = "MultiSelect",
	Callback = function(v)
		print("Multi:", v)
	end,
})
Features:AddColorPicker({
	Title = "Accent Override",
	Default = Color3.fromRGB(0, 170, 255),
	Flag = "AccentOverride",
	Callback = function(c)
		print("Color:", c)
	end,
})
Features:AddInput({
	Title = "Nickname",
	Placeholder = "Type here...",
	Default = "",
	Flag = "Nickname",
	Callback = function(text)
		print("Input:", text)
	end,
})

local Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
Settings:AddKeybind({
	Title = "Toggle UI (End)",
	Default = Enum.KeyCode.End,
	Callback = function()
		Window:Toggle()
	end,
})

local ThemeSection = Settings:AddSection({ Title = "Themes", Collapsible = true, Opened = true })
ThemeSection:AddButton({ Title = "Dark", Callback = function() Library:SetTheme("Dark") end })
ThemeSection:AddButton({ Title = "Midnight", Callback = function() Library:SetTheme("Midnight") end })
ThemeSection:AddButton({ Title = "Ocean", Callback = function() Library:SetTheme("Ocean") end })
ThemeSection:AddButton({ Title = "OLED", Callback = function() Library:SetTheme("OLED") end })
ThemeSection:AddButton({ Title = "Emerald", Callback = function() Library:SetTheme("Emerald") end })

Settings:AddButton({
	Title = "Save Config (Studio fallback)",
	Callback = function()
		local ok, msg = Window.ConfigManager:Save("MyConfig")
		Window:Notify({
			Title = ok and "Config" or "Config (Unavailable)",
			Content = ok and "Saved MyConfig.json" or (msg or "Not supported here"),
			Duration = 3,
		})
	end,
})

