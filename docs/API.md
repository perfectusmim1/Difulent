# Phantasm API Reference

## Library

### `Library.CreateWindow(options)`
Creates a new UI Window.
- `options`: Table
  - `Title`: string
  - `SubTitle`: string (optional)
  - `Size`: UDim2 (default 580x460)
  - `Material`: "Acrylic" | "Solid" | "Transparent"
  - `Folder`: string (for config saving)
  - `ToggleKey`: Enum.KeyCode

### `Library:SetTheme(themeName)`
Sets the global theme.
- `themeName`: "Dark" | "Midnight" | "Ocean" | "OLED" | "Emerald"

### `Library:AddTheme(themeTable)`
Adds a custom theme (`themeTable.Name` required).

### `Library:GetThemes()`
Returns a list of available theme names.

### `Library:GetTheme()`
Returns the current theme table.

### `Library:GetThemeName()`
Returns the current theme name.

### `Library:Notify(payload)`
Global notification (routes to last created Window).

### `Library:Dialog(payload)`
Global modal dialog (routes to last created Window).

### `Library:Popup(payload)`
Global context popup (routes to last created Window).

### `Library:Destroy()`
Destroys all windows.

## Window

### `Window:AddTab(options)`
- `options`: {Title="Name", Icon="rbxassetid://..." or "lucide-name"}
- Returns: `Tab` object

### `Window:Toggle()`
Toggles visibility.

### `Window:Open()` / `Window:Close()`
Shows or hides the window.

### `Window:SetTheme(nameOrTable)`
Applies a theme to the UI.

### `Window:SetToggleKey(keyCode)`
Updates the toggle key at runtime.

### `Window:SetSize(UDim2)`
Resizes the window.

### `Window:SetResizable(bool)`
Enables/disables resizing at runtime.

### `Window:Notify(payload)`
Shows a notification (per-window).

### `Window:Dialog(payload)`
Shows a modal dialog. Supports optional input field.

### `Window:Popup(payload)`
Shows a context popup menu (items/separators/toggles).

### `Window:SaveConfig(name)` / `Window:LoadConfig(name, silent?)`
Save/load configuration (silent defaults to true for Load).

### `Window:ExportConfig()` / `Window:ImportConfig(json, silent?)`
Export/import JSON configuration.

### `Window:CreateConfigUI(container, options?)`
Creates a config manager UI block inside a Tab or Section.

### `Window:LockAllElements()` / `Window:UnlockAllElements()`
Locks/unlocks all elements (if supported).

### `Window:GetAllElements()`
Returns registered elements.

### `Window:GetLockedElements()` / `Window:GetUnlockedElements()`
Returns element subsets by lock state.

### `Window:Destroy()`
Cleans up the UI.

## Tab

### `Tab:AddButton({Title, Callback})`
### `Tab:AddToggle({Title, Default, Flag, Callback})`
### `Tab:AddSlider({Title, Min, Max, Default, Step, Flag, Callback})`
### `Tab:AddInput({Title, Default, Placeholder, Numeric, Flag, Callback})`
### `Tab:AddDropdown({Title, Values, Default, Multi, Flag, Callback})`
### `Tab:AddColorPicker({Title, Default, Flag, Callback})`
### `Tab:AddKeybind({Title, Default, Flag, Callback})`
### `Tab:AddLabel({Title})`
### `Tab:AddParagraph({Title, Content})`
### `Tab:AddSection({Title})` -> Returns Section object (same methods as Tab)

## Elements Common Options
- `Title`: Text to display
- `Flag`: Unique string for config saving
- `Callback`: Function(value) triggers on change
- Common methods (where supported):
  - `Set(value, silent?)`
  - `Get()`
  - `SetEnabled(bool)`
  - `SetLocked(bool)`
  - `Destroy()`

## ConfigManager (Internal)
Automatically handles saving if `Folder` is provided in Window options and executor supports `writefile`.
