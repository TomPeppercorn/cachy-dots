-- ╭──────────────────────────────────────────────────────────────╮
-- │  cachy-dots · Hyprland (Lua config, Hyprland 0.55+)           │
-- │                                                              │
-- │  Each piece lives in its own file under ./cachy/ so an error  │
-- │  in one (say, a typo in look.lua) can't stop your binds from  │
-- │  loading.                                                    │
-- │                                                              │
-- │  Load order — later files win:                               │
-- │    cachy/*         the defaults                              │
-- │    cachy/theme     colors, written by cachy-theme            │
-- │    cachy/gpu       GPU settings, written by the installer    │
-- │    cachy/tablet    tablet mode, if you picked it             │
-- │    hyprland-gui    HyprMod's saved changes (Super+,)         │
-- │    user            YOUR tweaks — never overwritten           │
-- ╰──────────────────────────────────────────────────────────────╯

require("cachy/binds")     -- first, so you always have working keys
require("cachy/env")
require("cachy/look")
require("cachy/rules")
require("cachy/autostart")
pcall(require, "cachy/theme")
pcall(require, "cachy/gpu")
pcall(require, "cachy/tablet")   -- only there if you picked tablet mode (experimental)

-- HyprMod managed settings
require("hyprland-gui")

pcall(require, "user")
