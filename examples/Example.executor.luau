-- Executor example for Phantasm/Difulent
local URL = "https://raw.githubusercontent.com/perfectusmim1/Difulent/refs/heads/main/dist/main.lua"

local function httpGet(url)
	if game and game.HttpGet then
		return game:HttpGet(url)
	end
	if syn and syn.request then
		local res = syn.request({ Url = url, Method = "GET" })
		if res and res.Body then
			return res.Body
		end
	end
	if http_request then
		local res = http_request({ Url = url, Method = "GET" })
		if res and res.Body then
			return res.Body
		end
	end
	if request then
		local res = request({ Url = url, Method = "GET" })
		if res and res.Body then
			return res.Body
		end
	end
	error("Difulent: HTTP request not available in this executor.")
end

local function loadLibrary(source)
	if type(source) ~= "string" then
		error("Difulent: invalid response body.")
	end
	if source:sub(1, 3) == string.char(239, 187, 191) then
		source = source:sub(4)
	end
	local loader = loadstring or load
	if not loader then
		error("Difulent: loadstring is not available in this executor.")
	end
	local chunk, err = loader(source)
	if not chunk then
		error(err or "Difulent: failed to load library.")
	end
	return chunk()
end

local Library = loadLibrary(httpGet(URL))

Library:AddTheme({
	Name = "Graphite",
	Accent = Color3.fromRGB(99, 164, 255),
	Background = Color3.fromRGB(24, 24, 28),
	Surface = Color3.fromRGB(34, 34, 40),
	Surface2 = Color3.fromRGB(46, 46, 54),
	Outline = Color3.fromRGB(66, 66, 76),
	Text = Color3.fromRGB(244, 244, 248),
	SubText = Color3.fromRGB(170, 170, 180),
	Placeholder = Color3.fromRGB(120, 120, 130),
	Icon = Color3.fromRGB(170, 170, 180),
	Success = Color3.fromRGB(90, 220, 140),
	Warning = Color3.fromRGB(255, 210, 110),
	Danger = Color3.fromRGB(255, 96, 96),
	Shadow = Color3.fromRGB(0, 0, 0),
})

local Window = Library.CreateWindow({
	Title = "Difulent",
	SubTitle = "Executor Demo",
	Icon = "layers",
	Folder = "DifulentDemo",
	Size = UDim2.fromOffset(760, 520),
	MinSize = UDim2.fromOffset(560, 380),
	MaxSize = UDim2.fromOffset(980, 720),
	Material = "Acrylic",
	Theme = "Midnight",
	Resizable = true,
	SideBarWidth = 230,
	HideSearchBar = false,
	ScrollBarEnabled = true,
	ToggleKey = Enum.KeyCode.RightShift,
	Configs = {
		Enabled = true,
		AutoSave = true,
		Name = "autosave",
		DebounceSeconds = 1.2,
	},
})

Library:Notify({
	Title = "Phantasm",
	Content = "Loaded UI. Press RightShift to toggle.",
	Duration = 3,
})

local Main = Window:AddTab({ Title = "Main", Icon = "home" })
local Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
local About = Window:AddTab({ Title = "About", Icon = "info" })

local headerLabel = Main:AddLabel({ Title = "Difulent UI Showcase" })
local intro = Main:AddParagraph({
	Title = "Overview",
	Content = "This demo covers all current elements, themes, dialogs, popups, and config tools.",
})

local actionSection = Main:AddSection({ Title = "Core Elements", Collapsible = true, Opened = true })

actionSection:AddButton({
	Title = "Send Notification",
	Callback = function()
		Library:Notify({
			Title = "Notification",
			Content = "This is a queued toast.",
			Duration = 2,
		})
	end,
})

actionSection:AddButton({
	Title = "Open Dialog",
	Callback = function()
		Library:Dialog({
			Title = "Confirm Action",
			Content = "Type an optional note and confirm.",
			Input = {
				Placeholder = "Optional note",
			},
			Buttons = {
				{
					Title = "Confirm",
					Primary = true,
					Callback = function(text)
						Library:Notify({
							Title = "Dialog",
							Content = "Confirmed: " .. tostring(text or ""),
							Duration = 2,
						})
					end,
				},
				{ Title = "Cancel" },
			},
		})
	end,
})

local popupButton
popupButton = actionSection:AddButton({
	Title = "Open Popup Menu",
	Callback = function()
		Window:Popup({
			Target = popupButton.Frame,
			Items = {
				{
					Title = "Quick Save Config",
					Icon = "file-text",
					Callback = function()
						local ok, msg = Window:SaveConfig("quick")
						Library:Notify({
							Title = ok and "Config" or "Config Error",
							Content = ok and "Saved as quick" or (msg or "Save failed"),
							Duration = 2,
						})
					end,
				},
				{
					Title = "Lock All (2s)",
					Icon = "lock",
					Callback = function()
						Window:LockAllElements()
						task.delay(2, function()
							Window:UnlockAllElements()
						end)
					end,
				},
				{ Separator = true },
				{
					Title = "Theme: Emerald",
					Icon = "sun",
					Toggle = true,
					Checked = false,
					Callback = function(checked)
						Library:SetTheme(checked and "Emerald" or "Midnight")
					end,
				},
				{
					Title = "Copy Export",
					Icon = "copy",
					Callback = function()
						local json = Window:ExportConfig()
						local copied = false
						if type(setclipboard) == "function" then
							pcall(function()
								setclipboard(json)
								copied = true
							end)
						end
						Library:Notify({
							Title = "Config",
							Content = copied and "Export copied." or "Clipboard not available.",
							Duration = 2,
						})
					end,
				},
			},
		})
	end,
})

local featureToggle = actionSection:AddToggle({
	Title = "Enable Feature",
	Default = true,
	Flag = "feature_enabled",
	Callback = function(value)
		headerLabel:SetTitle(value and "Feature Enabled" or "Feature Disabled")
	end,
})

local volumeSlider = actionSection:AddSlider({
	Title = "Volume",
	Min = 0,
	Max = 100,
	Step = 5,
	Default = 50,
	Suffix = "%",
	Flag = "volume",
	Callback = function(value)
		intro:Set({
			Content = "Volume set to " .. tostring(value) .. "%.",
		})
	end,
})

actionSection:AddButton({
	Title = "Set Volume to 75",
	Callback = function()
		volumeSlider:Set(75)
	end,
})

local modeDropdown = actionSection:AddDropdown({
	Title = "Mode",
	Values = { "Standard", "Pro", "Ultra" },
	Default = "Standard",
	Flag = "mode",
	Callback = function(value)
		Library:Notify({
			Title = "Mode",
			Content = "Selected: " .. tostring(value),
			Duration = 2,
		})
	end,
})

local modulesDropdown = actionSection:AddDropdown({
	Title = "Modules (Multi)",
	Values = { "ESP", "Tracer", "NoClip", "Fly", "Aimbot" },
	Multi = true,
	Default = { ESP = true, Tracer = true },
	Flag = "modules",
	Callback = function(values)
		local count = 0
		for _, enabled in pairs(values) do
			if enabled then
				count = count + 1
			end
		end
		Library:Notify({
			Title = "Modules",
			Content = "Selected: " .. tostring(count),
			Duration = 2,
		})
	end,
})

actionSection:AddButton({
	Title = "Refresh Mode List",
	Callback = function()
		modeDropdown:Refresh({ "Standard", "Pro", "Ultra", "Extreme" })
		modeDropdown:Set("Extreme")
	end,
})

local nameInput = actionSection:AddInput({
	Title = "Profile Name",
	Default = "Guest",
	Placeholder = "Type a name",
	Flag = "profile_name",
	Callback = function(text)
		headerLabel:SetTitle("Hello, " .. tostring(text))
	end,
})

local speedInput = actionSection:AddInput({
	Title = "WalkSpeed (Numeric)",
	Default = 16,
	Numeric = true,
	Flag = "walk_speed",
	Callback = function(value)
		Library:Notify({
			Title = "Speed",
			Content = "WalkSpeed set to " .. tostring(value),
			Duration = 2,
		})
	end,
})

local colorPicker = actionSection:AddColorPicker({
	Title = "Accent Sample",
	Default = Color3.fromRGB(80, 160, 255),
	Flag = "accent_sample",
	Callback = function(color)
		local r = math.floor(color.R * 255 + 0.5)
		local g = math.floor(color.G * 255 + 0.5)
		local b = math.floor(color.B * 255 + 0.5)
		intro:Set({
			Content = "Accent sample: rgb(" .. r .. ", " .. g .. ", " .. b .. ").",
		})
	end,
})

local quickToggleBind = actionSection:AddKeybind({
	Title = "Quick Toggle",
	Default = Enum.KeyCode.F6,
	Flag = "quick_toggle",
	Callback = function()
		Window:Toggle()
	end,
})

actionSection:AddButton({
	Title = "Set Quick Toggle to LeftAlt",
	Callback = function()
		quickToggleBind:Set(Enum.KeyCode.LeftAlt)
		Library:Notify({
			Title = "Keybind",
			Content = "Quick Toggle set to LeftAlt.",
			Duration = 2,
		})
	end,
})

actionSection:AddButton({
	Title = "Reset Demo Values",
	Callback = function()
		featureToggle:Set(true)
		volumeSlider:Set(50)
		modeDropdown:Set("Standard")
		modulesDropdown:Set({ ESP = true, Tracer = true })
		nameInput:Set("Guest")
		speedInput:Set(16)
		colorPicker:Set(Color3.fromRGB(80, 160, 255))
	end,
})

local themeSection = Settings:AddSection({ Title = "Themes", Collapsible = true, Opened = true })
local themeDropdown = themeSection:AddDropdown({
	Title = "Active Theme",
	Values = Library:GetThemes(),
	Default = Library:GetThemeName(),
	Callback = function(theme)
		Library:SetTheme(theme)
	end,
})

themeSection:AddButton({
	Title = "Use Graphite Theme",
	Callback = function()
		Library:SetTheme("Graphite")
	end,
})

themeSection:AddButton({
	Title = "Refresh Theme List",
	Callback = function()
		themeDropdown:Refresh(Library:GetThemes())
	end,
})

themeSection:AddButton({
	Title = "Set Toggle Key to LeftControl",
	Callback = function()
		Window:SetToggleKey(Enum.KeyCode.LeftControl)
		Library:Notify({
			Title = "Window",
			Content = "Toggle key set to LeftControl.",
			Duration = 2,
		})
	end,
})

themeSection:AddButton({
	Title = "Compact Size",
	Callback = function()
		Window:SetSize(UDim2.fromOffset(600, 420))
	end,
})

themeSection:AddButton({
	Title = "Default Size",
	Callback = function()
		Window:SetSize(UDim2.fromOffset(760, 520))
	end,
})

local stateSection = Settings:AddSection({ Title = "State Controls", Collapsible = true, Opened = true })
stateSection:AddToggle({
	Title = "Enable Volume Slider",
	Default = true,
	Callback = function(value)
		volumeSlider:SetEnabled(value)
	end,
})

stateSection:AddToggle({
	Title = "Lock Mode Dropdown",
	Default = false,
	Callback = function(value)
		modeDropdown:SetLocked(value)
	end,
})

stateSection:AddToggle({
	Title = "Enable Window Resize",
	Default = true,
	Callback = function(value)
		Window:SetResizable(value)
	end,
})

stateSection:AddButton({
	Title = "Lock All for 2 Seconds",
	Callback = function()
		Window:LockAllElements()
		task.delay(2, function()
			Window:UnlockAllElements()
		end)
	end,
})

stateSection:AddButton({
	Title = "Count Locked Elements",
	Callback = function()
		local locked = Window:GetLockedElements()
		Library:Notify({
			Title = "State",
			Content = "Locked elements: " .. tostring(#locked),
			Duration = 2,
		})
	end,
})

Window:CreateConfigUI(Settings, {
	SectionTitle = "Configs",
	Opened = true,
})

About:AddParagraph({
	Title = "About",
	Content = "Executor-only demo. Use the Configs section to save/load and export/import JSON.",
})

About:AddButton({
	Title = "Copy Raw Dist Link",
	Callback = function()
		local url = "https://raw.githubusercontent.com/perfectusmim1/Difulent/refs/heads/main/dist/main.lua"
		if type(setclipboard) == "function" then
			pcall(function()
				setclipboard(url)
			end)
			Library:Notify({
				Title = "Link",
				Content = "Raw link copied to clipboard.",
				Duration = 2,
			})
		else
			Library:Dialog({
				Title = "Raw Link",
				Content = url,
				Buttons = {
					{ Title = "Close", Primary = true },
				},
			})
		end
	end,
})
