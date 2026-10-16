-- cachy-dots · autostart
-- Managed by the installer; put your own tweaks in ~/.config/hypr/user.lua

-------------------
---- AUTOSTART ----
-------------------
hl.on("hyprland.start", function()
    hl.exec_cmd("qs")                                         -- Quickshell bar + theme picker
    hl.exec_cmd("swaync")                                     -- notifications
    hl.exec_cmd("swaybg -m fill -i ~/.config/cachy-dots/wallpaper")
    hl.exec_cmd("~/.local/bin/cachy-launcher daemon")         -- Vicinae or Walker in the background
    hl.exec_cmd("hypridle")
    hl.exec_cmd("systemctl --user start hyprpolkitagent")
    hl.exec_cmd("nm-applet --indicator")
end)
