package config

import _ "embed"

//go:embed embedded/hyprland.lua
var HyprlandConfig string

//go:embed embedded/hypr-colors.lua
var HyprColorsConfig string

//go:embed embedded/hypr-layout.lua
var HyprLayoutConfig string

//go:embed embedded/hypr-binds.lua
var HyprBindsConfig string

//go:embed embedded/hypr-outputs.lua
var HyprOutputsConfig string

//go:embed embedded/hypr-cursor.lua
var HyprCursorConfig string

//go:embed embedded/hypr-windowrules.lua
var HyprWindowrulesConfig string
