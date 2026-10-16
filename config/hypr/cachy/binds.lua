-- cachy-dots · keybinds
-- Managed by the installer; put your own tweaks in ~/.config/hypr/user.lua

------------------
---- PROGRAMS ----
------------------
-- The installer fills these in from your picks. Change them any time.
local terminal    = "kitty"
local browser     = "helium-browser"
local fileManager = "thunar"
local launcher    = "~/.local/bin/cachy-launcher"
local discord     = "vesktop"
local screenshot  = "~/.local/bin/cachy-screenshot"
local tui         = "~/.local/bin/cachy-tui"   -- floating system TUIs (wlctl, bluetui, wiremix, pacsea, btop)

---------------------
---- KEYBINDINGS ----
---------------------
local mod = "SUPER"

-- Apps
hl.bind(mod .. " + Return", hl.dsp.exec_cmd(terminal))  -- Terminal (kitty)
hl.bind(mod .. " + B",      hl.dsp.exec_cmd(browser))  -- Browser (Helium)
hl.bind(mod .. " + E",      hl.dsp.exec_cmd(fileManager))  -- File manager (Thunar)
hl.bind(mod .. " + SHIFT + E", hl.dsp.exec_cmd(terminal .. " -e yazi"))  -- Terminal file manager (Yazi)
hl.bind(mod .. " + D",      hl.dsp.exec_cmd(discord))  -- Vesktop
hl.bind(mod .. " + Space",  hl.dsp.exec_cmd(launcher))  -- Launcher: apps, files, calculator
hl.bind(mod .. " + V",      hl.dsp.exec_cmd(launcher .. " clipboard"))  -- Clipboard history
hl.bind(mod .. " + SHIFT + F", hl.dsp.exec_cmd(launcher .. " files"))  -- File search
hl.bind(mod .. " + SHIFT + T", hl.dsp.exec_cmd("qs ipc call theme toggle"))  -- Theme picker
hl.bind(mod .. " + SHIFT + W", hl.dsp.exec_cmd("~/.local/bin/cachy-theme pick-wallpaper"))  -- Change wallpaper
hl.bind(mod .. " + comma",  hl.dsp.exec_cmd("hyprmod"))  -- Hyprland settings (HyprMod)
hl.bind(mod .. " + N",      hl.dsp.exec_cmd("swaync-client -t -sw"))  -- Notification center
hl.bind(mod .. " + slash",  hl.dsp.exec_cmd("~/.local/bin/cachy-keybinds"))  -- This cheatsheet
hl.bind("CTRL + SHIFT + Escape", hl.dsp.exec_cmd(tui .. " monitor"))  -- Task manager (btop)

-- System TUIs: Super + Alt + letter. Press again to close.
hl.bind(mod .. " + ALT + W", hl.dsp.exec_cmd(tui .. " wifi"))       -- Wi-Fi, Ethernet, VPN (wlctl)
hl.bind(mod .. " + ALT + B", hl.dsp.exec_cmd(tui .. " bluetooth"))  -- Bluetooth (bluetui)
hl.bind(mod .. " + ALT + A", hl.dsp.exec_cmd(tui .. " audio"))      -- Sound mixer (wiremix)
hl.bind(mod .. " + ALT + P", hl.dsp.exec_cmd(tui .. " packages"))   -- Packages: install, update, remove (Pacsea)

-- Windows
hl.bind(mod .. " + Q",             hl.dsp.window.close())  -- Close window
hl.bind(mod .. " + F",             hl.dsp.window.fullscreen({ mode = "fullscreen", action = "toggle" }))  -- Fullscreen
hl.bind(mod .. " + M",             hl.dsp.window.fullscreen({ mode = "maximized",  action = "toggle" }))  -- Maximize
hl.bind(mod .. " + SHIFT + Space", hl.dsp.window.float({ action = "toggle" }))  -- Toggle floating
hl.bind(mod .. " + P",             hl.dsp.window.pseudo())  -- Pseudo-tile
hl.bind(mod .. " + T",             hl.dsp.layout("togglesplit"))  -- Toggle split direction

-- Focus: Super + arrows
hl.bind(mod .. " + left",  hl.dsp.focus({ direction = "left" }))  -- Focus left
hl.bind(mod .. " + right", hl.dsp.focus({ direction = "right" }))  -- Focus right
hl.bind(mod .. " + up",    hl.dsp.focus({ direction = "up" }))  -- Focus up
hl.bind(mod .. " + down",  hl.dsp.focus({ direction = "down" }))  -- Focus down

-- Move windows: Super + Shift + arrows
hl.bind(mod .. " + SHIFT + left",  hl.dsp.window.move({ direction = "left" }))  -- Move window left
hl.bind(mod .. " + SHIFT + right", hl.dsp.window.move({ direction = "right" }))  -- Move window right
hl.bind(mod .. " + SHIFT + up",    hl.dsp.window.move({ direction = "up" }))  -- Move window up
hl.bind(mod .. " + SHIFT + down",  hl.dsp.window.move({ direction = "down" }))  -- Move window down

-- Workspaces: Super + N switches, Super + Shift + N sends the window there
for i = 1, 10 do
    local key = i % 10 -- workspace 10 lives on the 0 key
    hl.bind(mod .. " + " .. key,         hl.dsp.focus({ workspace = i }))
    hl.bind(mod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end
hl.bind(mod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))  -- Next workspace
hl.bind(mod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))  -- Previous workspace

-- Scratchpad
hl.bind(mod .. " + S",       hl.dsp.workspace.toggle_special("scratch"))  -- Toggle scratchpad
hl.bind(mod .. " + ALT + S", hl.dsp.window.move({ workspace = "special:scratch" }))  -- Send window to scratchpad

-- Mouse: Super + LMB drag to move, Super + RMB drag to resize
hl.bind(mod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })  -- Drag to move window
hl.bind(mod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })  -- Drag to resize window

-- Screenshots → ~/Pictures/Screenshots, also copied to the clipboard
hl.bind("Print",               hl.dsp.exec_cmd(screenshot .. " region"))    -- Screenshot region (instant)
hl.bind(mod .. " + SHIFT + S", hl.dsp.exec_cmd(screenshot .. " annotate"))  -- Screenshot region + annotate
hl.bind("SHIFT + Print",       hl.dsp.exec_cmd(screenshot .. " screen"))    -- Screenshot monitor
hl.bind("ALT + Print",         hl.dsp.exec_cmd(screenshot .. " window"))    -- Screenshot window

-- Session
hl.bind(mod .. " + L",           hl.dsp.exec_cmd("loginctl lock-session"))  -- Lock screen
hl.bind(mod .. " + SHIFT + R",   hl.dsp.exec_cmd("hyprctl reload"))  -- Reload Hyprland config
hl.bind(mod .. " + SHIFT + M",   hl.dsp.exec_cmd("command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch 'hl.dsp.exit()'"))  -- Log out of Hyprland

-- Media / brightness keys
hl.bind("XF86AudioRaiseVolume",  hl.dsp.exec_cmd("wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })  -- Volume up
hl.bind("XF86AudioLowerVolume",  hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),        { locked = true, repeating = true })  -- Volume down
hl.bind("XF86AudioMute",         hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),       { locked = true })  -- Mute
hl.bind("XF86AudioMicMute",      hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),     { locked = true })  -- Mute mic
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"),                    { locked = true, repeating = true })  -- Brightness up
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"),                    { locked = true, repeating = true })  -- Brightness down
hl.bind("XF86AudioNext",         hl.dsp.exec_cmd("playerctl next"),       { locked = true })  -- Next track
hl.bind("XF86AudioPrev",         hl.dsp.exec_cmd("playerctl previous"),   { locked = true })  -- Previous track
hl.bind("XF86AudioPlay",         hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })  -- Play/pause
hl.bind("XF86AudioPause",        hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })  -- Play/pause

