

# Freecam Photo

Premium freecam script for FiveM — hold V to activate, take cinematic screenshots.

## Features

- Hold V (200ms) to toggle freecam on/off
- Fully transparent NUI overlay with keybind display
- Camera roll with Q/E keys
- Configurable max distance — auto-closes when exceeded
- Player frozen, radar hidden during freecam
- N key to toggle UI visibility
- Turkish / English locale support
- Clean toast notifications (no game HUD spam)
- Smooth camera transitions

## Controls

| Key        | Function                    |
|------------|-----------------------------|
| W A S D    | Move forward / back / left / right |
| R / F      | Move up / down              |
| Q / E      | Tilt camera (roll)          |
| Mouse      | Look around                 |
| Scroll     | Adjust movement speed       |
| Shift      | 3x speed multiplier         |
| V (hold)   | Toggle freecam on/off       |
| N          | Toggle UI visibility        |

## Installation

1. Copy `freecam-photo` to your server's `resources` folder
2. Add to `server.cfg`:

```
ensure freecam-photo
```

## Configuration

Edit `config.lua`:

```lua
Config.Locale            = 'tr'        -- 'tr' or 'en'
Config.MaxDistance       = 50.0        -- Auto-close distance
Config.MovementSpeed     = 0.3         -- Horizontal movement speed
Config.VerticalSpeed     = 0.15        -- Vertical (R/F) movement speed
Config.MouseSensitivity  = 5.0         -- Look sensitivity
Config.HoldTime          = 200         -- V hold time (ms)
Config.CameraTransition  = 500         -- Camera fade time (ms)
```

## Files

```
freecam-photo/
├── fxmanifest.lua
├── config.lua
├── client.lua
├── README.md
└── html/
    ├── index.html
    ├── style.css
    └── script.js
```
