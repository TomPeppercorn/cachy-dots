# cachy-dots

Hyprland + Quickshell for CachyOS, with a theme manager, your choice of launcher, and a proper login screen.

On the new machine, from the text login after installing CachyOS:

```bash
git clone https://github.com/<your-username>/cachy-dots.git
cd cachy-dots
bash install.sh --dry-run   # see every action, change nothing
bash install.sh             # do it
reboot
```

No GitHub? Copy the folder over on a USB stick and run the same `bash install.sh` from inside it.

Install CachyOS with only `hyprland` + `kitty` from the Hyprland group (no Noctalia, no Dolphin, no Firefox). The first boot lands on a text login; that's expected. Run the installer from there.

## What you get

| Piece | Choice |
|---|---|
| Compositor | Hyprland, **Lua config** (0.55+), snappy ~250 ms animations |
| Settings app | **HyprMod** (Super+,): change Hyprland settings, binds, curves in a GUI |
| Bar | **Quickshell**: workspaces, window title, clock, tray, volume, battery, theme + notification buttons |
| Themes | **cachy-theme**: 8 presets or colors generated from your wallpaper (matugen). One switch recolors everything |
| Launcher | **Vicinae** or **Walker** (asked at install): apps, indexed file search, clipboard, calculator |
| Login screen | **SDDM** + astronaut theme; `cachy-login-theme` switches its style or matches your desktop |
| Terminal | kitty, IBM Plex (BlexMono Nerd Font) |
| Notifications | swaync (themed) |
| Lock / idle | hyprlock (Super+L), hypridle (lock 10 min, suspend 30 min) |
| Browser · chat | Helium (Firefox removed) · Vesktop |
| Files | Thunar (Super+E), Yazi (Super+Shift+E) |
| Screenshots | Print = instant, Super+Shift+S = annotate in Satty |
| GPU | Detected and confirmed at install; NVIDIA desktop vs hybrid laptop handled differently |
| Dev · Gaming | neovim, git, gh, lazygit, docker, node, python + uv, go, CLI tools; optional VSCodium; Vim upgraded with [amix/vimrc](https://github.com/amix/vimrc) (Awesome or Basic, asked at install) · CachyOS gaming meta-packages |

## Themes

| Do this | How |
|---|---|
| Switch theme | **Super+Shift+T** (or the palette icon in the bar), or `cachy-theme set nord` |
| Colors from wallpaper | Pick "From wallpaper" in the picker, or `cachy-theme set wallpaper` |
| Change wallpaper | **Super+Shift+W**, or `cachy-theme wallpaper ~/Pictures/x.jpg`. Drop images in `~/Pictures/Wallpapers` |
| Light wallpaper colors | `cachy-theme variant light` |
| Make your own preset | Copy a file in `~/.config/cachy-dots/themes/`, edit the hex values; it appears in the picker |
| Login screen to match | `cachy-login-theme` → "Match my desktop" |

Presets: Gruvbox Dark, Catppuccin Mocha, Catppuccin Latte (light), Tokyo Night, Nord, Rosé Pine, Everforest, Kanagawa.

A switch updates the bar, window borders, kitty, GTK apps, notifications, the launcher, the lock screen and btop. Open GTK apps and btop pick it up when reopened.

## Keybinds

Super + / shows every bind, including ones you add.

| Keys | Action |
|---|---|
| Super + 1…0 / + Shift | Switch to / send window to workspace |
| Super + ←↑→↓ / + Shift | Move focus / move window |
| Super + Return | Terminal |
| Super + Space | Launcher |
| Super + V | Clipboard history |
| Super + Shift + F | File search |
| Super + B / E / D | Helium / Thunar / Vesktop |
| Super + Shift + E | Yazi |
| Super + Shift + T | Theme picker |
| Super + Shift + W | Change wallpaper |
| Super + , | HyprMod (Hyprland settings) |
| Super + Q | Close window |
| Super + F / M | Fullscreen / maximize |
| Super + Shift + Space | Toggle floating |
| Super + T | Toggle split direction |
| Super + S / Super + Alt + S | Scratchpad / send window there |
| Super + N | Notification center |
| Print / Super + Shift + S | Screenshot region / region + annotate |
| Shift + Print / Alt + Print | Screenshot monitor / window |
| Super + L | Lock |
| Super + Shift + R / M | Reload Hyprland / log out |

## Make it yours

- **`~/.config/hypr/user.lua`**: your binds and overrides. Loads last, never overwritten. End a bind line with `-- description` for the cheatsheet.
- **HyprMod** (Super+,) saves to `~/.config/hypr/hyprland-gui.lua`, which loads before `user.lua` and is kept on reinstall.
- **Monitor / refresh rate**: HyprMod's monitor page, or an `hl.monitor({...})` line in `user.lua`.
- **Animations**: `~/.config/hypr/cachy/look.lua`, or HyprMod's curve editor. `speed` is in tenths of a second.
- **Switch launcher later**: change `LAUNCHER=` in `~/.config/cachy-dots/settings` and install the other one.

## Installer flags

```
--launcher vicinae|walker     --gpu amd|nvidia|intel|hybrid
--editor none|codium   --vimrc awesome|basic|none   --theme <preset>|wallpaper
--no-dev  --no-gaming  --no-everyday  --keep-firefox  --no-login-screen
-y, --yes      unattended (also skips paru's PKGBUILD review)
--dry-run      show actions, change nothing
```

Re-running is safe. Packages use `--needed`, old configs go to `~/.config/cachy-dots/backups/<time>/`, and your theme, `user.lua` and HyprMod settings are kept. AUR packages whose names vary (`foo` vs `foo-bin`) are looked up at install time; one that can't be found is skipped with a warning instead of failing the install.

## Notes

- Needs Hyprland 0.55+ (Lua config). The bar sends Lua-style dispatches when you click a workspace.
- **NVIDIA:** if the first animation after a pause stutters, that's the GPU waking from low clocks, a known driver behavior, not the config.
- **Hybrid laptops:** the desktop runs on the integrated GPU. Use `prime-run %command%` in Steam launch options for games.
- Vicinae sends anonymous system info once a day by default; turn it off in its settings (`telemetry`).
