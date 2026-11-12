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
    -- Give systemd's user manager and D-Bus the Wayland session env, THEN start the polkit agent
    -- (it's a Wayland client; without WAYLAND_DISPLAY it fails to register, and apps like Shelly
    -- then report "no polkit agent"). The import also fixes dbus-activated portals/screenshare.
    hl.exec_cmd("dbus-update-activation-environment --systemd --all; systemctl --user start hyprpolkitagent")
    hl.exec_cmd("command -v gsr-ui >/dev/null && gsr-ui")    -- screen recorder overlay (Left Alt + Z)
end)
