-- cachy-dots · window rules
-- Managed by the installer; put your own tweaks in ~/.config/hypr/user.lua

----------------------
---- WINDOW RULES ----
----------------------
hl.window_rule({
    name  = "suppress-maximize-events",
    match = { class = ".*" },
    suppress_event = "maximize",
})

hl.window_rule({
    name  = "fix-xwayland-drags",
    match = { class = "^$", title = "^$", xwayland = true, float = true, fullscreen = false, pin = false },
    no_focus = true,
})

hl.window_rule({
    name  = "float-utility-windows",
    match = { class = "^(pavucontrol|org.pulseaudio.pavucontrol|blueman-manager|nm-connection-editor|com.gabm.satty)$" },
    float = true,
})

-- Games: let Steam/Proton titles tear for lowest latency (needs allow_tearing above)
hl.window_rule({
    name  = "games-immediate",
    match = { class = "^(steam_app_.*|gamescope)$" },
    immediate = true,
})


---------------------
---- LAYER RULES ----
---------------------
-- Launchers and the theme picker: blur behind them, and no slide animation for the launchers
-- (Vicinae recommends this; it makes them feel instant).
hl.layer_rule({ name = "launcher-blur",     match = { namespace = "^(vicinae|walker)$" }, blur = true, ignore_alpha = 0 })
hl.layer_rule({ name = "launcher-no-anim",  match = { namespace = "^(vicinae|walker)$" }, no_anim = true })
hl.layer_rule({ name = "theme-picker-blur", match = { namespace = "^cachy-theme-picker$" }, blur = true, ignore_alpha = 0.3 })
