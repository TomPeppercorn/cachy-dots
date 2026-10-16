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
    match = { class = "^(com.gabm.satty|org.pulseaudio.pavucontrol|blueman-manager|nm-connection-editor)$" },
    float = true,
})

-- System TUIs opened by cachy-tui: float in the middle of the screen, like a popup panel
hl.window_rule({
    name   = "system-tui",
    match  = { class = "^cachy-tui-(wifi|bluetooth|audio)$" },
    float  = true,
    size   = "monitor_w*0.5 monitor_h*0.6",
    center = true,
})
hl.window_rule({
    name   = "system-tui-wide",
    match  = { class = "^cachy-tui-(packages|monitor)$" },
    float  = true,
    size   = "monitor_w*0.75 monitor_h*0.8",
    center = true,
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
