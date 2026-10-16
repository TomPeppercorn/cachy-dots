-- cachy-dots · monitors + environment
-- Managed by the installer; put your own tweaks in ~/.config/hypr/user.lua

------------------
---- MONITORS ----
------------------
-- Auto-detect everything. For a high-refresh monitor, replace with e.g.
-- hl.monitor({ output = "DP-1", mode = "2560x1440@165", position = "0x0", scale = 1 })
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = "auto" })

-------------------------------
---- ENVIRONMENT VARIABLES ----
-------------------------------
-- Programs launched by Hyprland (keybinds, the bar, autostart) need to find the cachy-* scripts.
-- A session started from SDDM doesn't include ~/.local/bin in PATH, so add it — once, even across reloads.
local home, path = os.getenv("HOME") or "", os.getenv("PATH") or "/usr/local/bin:/usr/bin"
if not path:find(home .. "/.local/bin", 1, true) then
    hl.env("PATH", home .. "/.local/bin:" .. path)
end

hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")
hl.env("ELECTRON_OZONE_PLATFORM_HINT", "auto") -- Vesktop / VSCodium on native Wayland
hl.env("QT_QPA_PLATFORM", "wayland;xcb")
hl.env("SDL_VIDEODRIVER", "wayland,x11")
hl.env("MOZ_ENABLE_WAYLAND", "1")

