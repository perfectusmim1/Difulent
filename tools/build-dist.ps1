$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$distPath = Join-Path $repoRoot "dist/main.lua"

$moduleList = @(
  @{ Name = "Signal"; Path = "src/Utils/Signal.lua" }
  @{ Name = "Maid"; Path = "src/Utils/Maid.lua" }
  @{ Name = "Utility"; Path = "src/Utils/Utility.lua" }
  @{ Name = "ThemeManager"; Path = "src/ThemeManager.lua" }
  @{ Name = "Creator"; Path = "src/Creator.lua" }
  @{ Name = "ConfigManager"; Path = "src/ConfigManager.lua" }

  @{ Name = "Button"; Path = "src/Components/Elements/Button.lua" }
  @{ Name = "Toggle"; Path = "src/Components/Elements/Toggle.lua" }
  @{ Name = "Slider"; Path = "src/Components/Elements/Slider.lua" }
  @{ Name = "Dropdown"; Path = "src/Components/Elements/Dropdown.lua" }
  @{ Name = "Input"; Path = "src/Components/Elements/Input.lua" }
  @{ Name = "Keybind"; Path = "src/Components/Elements/Keybind.lua" }
  @{ Name = "ColorPicker"; Path = "src/Components/Elements/ColorPicker.lua" }
  @{ Name = "Label"; Path = "src/Components/Elements/Label.lua" }
  @{ Name = "Paragraph"; Path = "src/Components/Elements/Paragraph.lua" }
  @{ Name = "Section"; Path = "src/Components/Elements/Section.lua" }
  @{ Name = "Divider"; Path = "src/Components/Elements/Divider.lua" }
  @{ Name = "Spacer"; Path = "src/Components/Elements/Spacer.lua" }
  @{ Name = "Code"; Path = "src/Components/Elements/Code.lua" }
  @{ Name = "Progress"; Path = "src/Components/Elements/Progress.lua" }
  @{ Name = "Group"; Path = "src/Components/Elements/Group.lua" }

  @{ Name = "Tab"; Path = "src/Components/Tab.lua" }
  @{ Name = "Window"; Path = "src/Components/Window.lua" }
  @{ Name = "init"; Path = "src/init.luau" }
)

$replacements = @{
  "require(script.Parent.Utils.Signal)" = 'requireModule("Signal")'
  "require(script.Parent.ThemeManager)" = 'requireModule("ThemeManager")'
  "require(script.Parent.Parent.Utils.Maid)" = 'requireModule("Maid")'
  "require(script.Parent.Parent.Creator)" = 'requireModule("Creator")'
  "require(script.Parent.Parent.ThemeManager)" = 'requireModule("ThemeManager")'
  "require(script.Parent.Parent.Utils.Utility)" = 'requireModule("Utility")'
  "require(script.Parent.Parent.Utils.Signal)" = 'requireModule("Signal")'
  "require(script.Parent.Parent.ConfigManager)" = 'requireModule("ConfigManager")'
  "require(script.Parent.Tab)" = 'requireModule("Tab")'

  "require(script.Components.Window)" = 'requireModule("Window")'
  "require(script.ThemeManager)" = 'requireModule("ThemeManager")'

  "require(script.Parent.Parent.Parent.Creator)" = 'requireModule("Creator")'
  "require(script.Parent.Parent.Parent.ThemeManager)" = 'requireModule("ThemeManager")'
  "require(script.Parent.Parent.Parent.Utils.Utility)" = 'requireModule("Utility")'
  "require(script.Parent.Parent.Parent.Utils.Maid)" = 'requireModule("Maid")'

  "require(script.Parent.Elements.Button)" = 'requireModule("Button")'
  "require(script.Parent.Elements.Toggle)" = 'requireModule("Toggle")'
  "require(script.Parent.Elements.Slider)" = 'requireModule("Slider")'
  "require(script.Parent.Elements.Dropdown)" = 'requireModule("Dropdown")'
  "require(script.Parent.Elements.Input)" = 'requireModule("Input")'
  "require(script.Parent.Elements.Keybind)" = 'requireModule("Keybind")'
  "require(script.Parent.Elements.ColorPicker)" = 'requireModule("ColorPicker")'
  "require(script.Parent.Elements.Label)" = 'requireModule("Label")'
  "require(script.Parent.Elements.Paragraph)" = 'requireModule("Paragraph")'
  "require(script.Parent.Elements.Section)" = 'requireModule("Section")'
  "require(script.Parent.Elements.Divider)" = 'requireModule("Divider")'
  "require(script.Parent.Elements.Spacer)" = 'requireModule("Spacer")'
  "require(script.Parent.Elements.Code)" = 'requireModule("Code")'
  "require(script.Parent.Elements.Progress)" = 'requireModule("Progress")'
  "require(script.Parent.Elements.Group)" = 'requireModule("Group")'

  "require(script.Parent.Button)" = 'requireModule("Button")'
  "require(script.Parent.Toggle)" = 'requireModule("Toggle")'
  "require(script.Parent.Slider)" = 'requireModule("Slider")'
  "require(script.Parent.Dropdown)" = 'requireModule("Dropdown")'
  "require(script.Parent.Input)" = 'requireModule("Input")'
  "require(script.Parent.Keybind)" = 'requireModule("Keybind")'
  "require(script.Parent.ColorPicker)" = 'requireModule("ColorPicker")'
  "require(script.Parent.Label)" = 'requireModule("Label")'
  "require(script.Parent.Paragraph)" = 'requireModule("Paragraph")'
  "require(script.Parent.Divider)" = 'requireModule("Divider")'
  "require(script.Parent.Spacer)" = 'requireModule("Spacer")'
  "require(script.Parent.Code)" = 'requireModule("Code")'
  "require(script.Parent.Progress)" = 'requireModule("Progress")'
  "require(script.Parent.Group)" = 'requireModule("Group")'
}

$sb = New-Object System.Text.StringBuilder

$null = $sb.AppendLine("-- Phantasm UI Library [Bundled]")
$null = $sb.AppendLine("-- https://github.com/perfectusmim1/Difulent")
$null = $sb.AppendLine("-- This file is generated from src/. Edit src/ instead.")
$null = $sb.AppendLine("")
$null = $sb.AppendLine("local modules = {}")
$null = $sb.AppendLine("local cache = {}")
$null = $sb.AppendLine("")
$null = $sb.AppendLine("local function requireModule(name)")
$null = $sb.AppendLine("    local cached = cache[name]")
$null = $sb.AppendLine("    if cached ~= nil then")
$null = $sb.AppendLine("        return cached")
$null = $sb.AppendLine("    end")
$null = $sb.AppendLine("    local loader = modules[name]")
$null = $sb.AppendLine("    if not loader then")
$null = $sb.AppendLine('        error(("Phantasm: missing module ''%s''"):format(tostring(name)))')
$null = $sb.AppendLine("    end")
$null = $sb.AppendLine("    local value = loader()")
$null = $sb.AppendLine("    cache[name] = value")
$null = $sb.AppendLine("    return value")
$null = $sb.AppendLine("end")
$null = $sb.AppendLine("")

foreach ($module in $moduleList) {
  $srcPath = Join-Path $repoRoot $module.Path
  if (-not (Test-Path $srcPath)) {
    throw "Missing source file: $($module.Path)"
  }

  $content = Get-Content -Raw $srcPath
  foreach ($kvp in $replacements.GetEnumerator()) {
    $content = $content.Replace($kvp.Key, $kvp.Value)
  }

  $null = $sb.AppendLine(("-- [[ Module: {0} ]] --" -f $module.Name))
  $null = $sb.AppendLine(('modules["{0}"] = function()' -f $module.Name))
  $null = $sb.AppendLine($content.TrimEnd())
  $null = $sb.AppendLine("end")
  $null = $sb.AppendLine("")
}

$null = $sb.AppendLine('return requireModule("init")')

$distDir = Split-Path -Parent $distPath
if (-not (Test-Path $distDir)) {
  New-Item -ItemType Directory -Path $distDir | Out-Null
}

$sb.ToString() | Set-Content -Path $distPath -Encoding utf8
Write-Host "Wrote $distPath"
