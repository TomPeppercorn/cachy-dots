-- cachy-dots · tablet mode (EXPERIMENTAL)
-- Installed as ~/.config/hypr/cachy/tablet.lua because you picked tablet mode in the installer.
-- Re-run the installer without it (or delete this file) to turn it all off.
--
--   cachy-rotate   follows the accelerometer: turns the screen, touchscreen and pen together
--   squeekboard    on-screen keyboard, shown/hidden with cachy-osk
--   Bar buttons:   rotation lock + keyboard (touch-friendly; they appear when this file is in use)

local mod = "SUPER"

-- After a config reload Hyprland forgets the rotation it was given at runtime. cachy-rotate saves
-- the current one ("<output> <transform>") so it can be put straight back here.
local state = io.open((os.getenv("HOME") or "") .. "/.cache/cachy-dots/rotation", "r")
if state then
    local output, transform = (state:read("*l") or ""):match("^(%S+)%s+(%d)$")
    state:close()
    transform = tonumber(transform)
    if output and transform and transform >= 0 and transform <= 3 then
        hl.monitor({ output = output, transform = transform })
        hl.config({ input = { touchdevice = { transform = transform }, tablet = { transform = transform } } })
    end
end

hl.on("hyprland.start", function()
    hl.exec_cmd("~/.local/bin/cachy-rotate")   -- exits by itself if there's no accelerometer
    hl.exec_cmd("squeekboard")                 -- stays hidden until cachy-osk shows it
end)

hl.bind(mod .. " + ALT + T", hl.dsp.exec_cmd("~/.local/bin/cachy-rotate lock"))  -- Lock / unlock screen rotation
hl.bind(mod .. " + ALT + K", hl.dsp.exec_cmd("~/.local/bin/cachy-osk"))          -- Show / hide on-screen keyboard
