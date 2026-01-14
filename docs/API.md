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

## Window

### `Window:AddTab(options)`
- `options`: {Title="Name", Icon="rbxassetid://..." or "lucide-name"}
- Returns: `Tab` object

### `Window:Toggle()`
Toggles visibility.

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

## ConfigManager (Internal)
Automatically handles saving if `Folder` is provided in Window options and executor supports `writefile`.
