# Phantasm UI Library

A premium, production-grade UI library for Roblox, inspired by Fluent and Rayfield.
Designed for **Executors** (loadstring-friendly).

## Features

- **Fluent Design**: Modern aesthetics with acrylic effects, smooth animations, and shadows.
- **Modular**: Built with clean, separate modules in `src/`.
- **Single-File Dist**: Run everything with one `loadstring` in `dist/main.lua`.
- **Robust**: Maid-based cleanup, Signal-based events, strict error handling.
- **Theming**: Built-in Dark, Midnight, Ocean themes with full custom support.
- **Dialogs & Popups**: Global dialogs and context menus for UX workflows.
- **Config UI**: Built-in save/load/export/import panel helper.

## Quick Start (Executor)

```lua
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/perfectusmim1/Difulent/main/dist/main.lua"))()

local Window = Library.CreateWindow({
    Title = "Phantasm Hub",
    Size = UDim2.fromOffset(550, 400)
})

local Tab = Window:AddTab({ Title = "Main", Icon = "home" })

Tab:AddButton({
    Title = "Execute",
    Callback = function() print("Hello") end
})
```

## Project Structure

- `src/`: Core source modules (Window, Components, Utils).
- `dist/`: Bundled `main.lua` for single-file distribution.
- `examples/`: Reference scripts.
- `docs/`: Full API documentation.

## Themes

- `Dark` (Default)
- `Midnight`
- `Ocean`
- `OLED`
- `Emerald`
