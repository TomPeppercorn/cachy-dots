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
| Bar | **Quickshell**: workspaces, window title, clock, CPU %, RAM in use, download/upload speed, tray, network, Bluetooth, volume, battery, theme + notification buttons. The readouts open btop; network, Bluetooth and volume open their TUIs |
| Themes | **cachy-theme**: 8 presets or colors generated from your wallpaper (matugen). One switch recolors everything |
| Launcher | **Vicinae** or **Walker** (asked at install): apps, indexed file search, clipboard, calculator |
| Login screen | **SDDM** + [SilentSDDM](https://github.com/uiriansan/SilentSDDM), neutral: your wallpaper blurred and dimmed, white text, frosted fields, IBM Plex Sans. It follows your wallpaper automatically, so it never clashes with a theme |
| Terminal | kitty, IBM Plex (BlexMono Nerd Font) |
| System tools | **Terminal apps in floating windows**: wlctl (Wi-Fi, Ethernet, VPN), bluetui (Bluetooth), wiremix (sound), Pacsea (packages, replaces Shelly), btop. Same toggle keys, same theme |
| Notifications | swaync (themed) |
| Lock / idle | hyprlock (Super+L), hypridle (lock 10 min, suspend 30 min) |
| Browser · chat · music · notes | Helium (Firefox removed) · Vesktop · [Spotifast](https://github.com/crmne/spotifast) (native Spotify client, needs Premium; follows your theme) · Obsidian |
| Files | Thunar (Super+E), Yazi (Super+Shift+E) |
| Screenshots | Print = instant, Super+Shift+S = annotate in Satty |
| Screen recording | **GPU Screen Recorder** with its ShadowPlay-style overlay (Left Alt+Z or Super+Alt+O): record, pause, stream, instant replay. Encodes on the GPU, so it barely touches performance |
| Wallpapers | A 24-image pack copied to `~/Pictures/Wallpapers` (in folders: `gruvbox/`, `cars/`, and loose ones). Default: `gruvbox/dan-otis-OYFHT4X5isg.jpg`, a foggy forest |
| GPU | Detected and confirmed at install; NVIDIA desktop vs hybrid laptop handled differently |
| Dev · Gaming | neovim, git, gh, lazygit, docker, node, python + uv, go, CLI tools; optional VSCodium; Vim upgraded with [amix/vimrc](https://github.com/amix/vimrc) (Awesome or Basic, asked at install) · CachyOS gaming meta-packages |
| Creative | **Blender** (official repos), **FilmCraft** (video editing, color and sound; open-source Premiere Pro alternative), **LightCraft** (photo library and raw development; open-source Lightroom alternative). The two Craft apps come from the AUR `-bin` packages, or the project's checksum-verified release in `~/.local` if those aren't found |

## Themes

| Do this | How |
|---|---|
| Switch theme | **Super+Shift+T** (or the palette icon in the bar), or `cachy-theme set nord` |
| Colors from wallpaper | Pick "From wallpaper" in the picker, or `cachy-theme set wallpaper` |
| Change wallpaper | **Super+Shift+W**, or `cachy-theme wallpaper ~/Pictures/x.jpg`. Drop images (any subfolder) in `~/Pictures/Wallpapers`. The login screen follows |
| Light wallpaper colors | `cachy-theme variant light` |
| Make your own preset | Copy a file in `~/.config/cachy-dots/themes/`, edit the hex values; it appears in the picker |
| Login screen | Follows your wallpaper by itself. `cachy-login-theme` refreshes it now; `cachy-login-theme off` / `on` stops / resumes following |
| Spotifast colors | Settings → Theme → **cachy** (once); after that it recolors with everything else |

Presets: Gruvbox Dark, Catppuccin Mocha, Catppuccin Latte (light), Tokyo Night, Nord, Rosé Pine, Everforest, Kanagawa.

A switch updates the bar, window borders, kitty, GTK apps, notifications, the launcher, the lock screen and btop. Open GTK apps and btop pick it up when reopened.

## System tools

Every system tool is a terminal app that opens as a floating window in the middle of the screen. If one exits with an error, its window stays open showing the message until you press Enter. Press its key again to close it; if it's open behind other windows, the key brings it forward. They use kitty's colors, so they follow your theme.

| Keys | Tool | Also opens from |
|---|---|---|
| Super + Alt + W | **wlctl**: Wi-Fi, Ethernet, WireGuard, hotspot (NetworkManager). On a machine with no Wi-Fi adapter, opens **nmtui** instead | Bar network icon, launcher "Wi-Fi" |
| Super + Alt + B | **bluetui**: pair and connect Bluetooth devices | Bar Bluetooth icon, launcher "Bluetooth" |
| Super + Alt + A | **wiremix**: volume per app, outputs, inputs (PipeWire) | Click the bar volume, launcher "Sound" |
| Super + Alt + P | **Pacsea**: search, install, update and remove packages, Arch news, AUR scans | Launcher "Packages" |
| Ctrl + Shift + Esc | **btop**: processes, CPU, memory, disks | Launcher "Monitor" |

The installer removes the GUI tools these replace (Shelly, pavucontrol, Blueman, the network tray applet) one at a time, and only when the replacement installed. Anything another package still needs is kept. Pass `--keep-gui-tools` to keep them all. `nmtui` and `bluetoothctl` are still there as fallbacks.

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
| Super + Alt + W / B / A / P | Wi-Fi / Bluetooth / sound / packages |
| Ctrl + Shift + Esc | Task manager (btop) |
| Print / Super + Shift + S | Screenshot region / region + annotate |
| Shift + Print / Alt + Print | Screenshot monitor / window |
| Super + Alt + O (or Left Alt + Z) | Screen recorder overlay |
| Super + Alt + R / C | Start/stop recording / save a replay clip (Replay on) |
| Super + L | Lock |
| Super + Shift + R / M | Reload Hyprland / log out |
| Ctrl + Alt + Delete | Log out |

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
--no-dev  --no-gaming  --no-everyday  --no-creative  --keep-firefox  --keep-gui-tools  --no-login-screen
-y, --yes      unattended (also skips paru's PKGBUILD review)
--dry-run      show actions, change nothing
```

Re-running is safe. Packages use `--needed`, old configs go to `~/.config/cachy-dots/backups/<time>/`, and your theme, `user.lua` and HyprMod settings are kept. AUR packages whose names vary (`foo` vs `foo-bin`) are looked up at install time; one that can't be found is skipped with a warning instead of failing the install.

## Notes

- Needs Hyprland 0.55+ (Lua config). The bar sends Lua-style dispatches when you click a workspace.
- **NVIDIA:** if the first animation after a pause stutters, that's the GPU waking from low clocks, a known driver behavior, not the config.
- **Hybrid laptops:** the desktop runs on the integrated GPU. Use `prime-run %command%` in Steam launch options for games.
- **Login wallpaper without a password:** a small root helper (`/usr/local/libexec/cachy-login-wallpaper`) plus a polkit rule let the logged-in user copy an image onto the login screen. The helper only accepts a PNG, JPEG or WebP on stdin (64 MB max) and writes two fixed files in the theme folder, so it can't be pointed at anything else.
- **Screen recorder overlay:** it catches its own hotkeys by grabbing the keyboards (it adds a "gsr-ui virtual keyboard"), which can clash with key-remapping tools; its settings have "Only grab virtual devices" for that, and the Super+Alt binds keep working. Locked out of the keyboard? Left Ctrl+Shift+Alt+Esc closes it. The project lists two Hyprland quirks: the wallpaper can show instead of a game while the overlay is open, and opening it over a fullscreen game can upset that window. Recording itself is unaffected; use Super+Alt+R in games if it bothers you.
- **Wallpapers in a public repo** are public. Remove any you don't have the rights to share before pushing.
- Vicinae sends anonymous system info once a day by default; turn it off in its settings (`telemetry`).
- **FilmCraft / LightCraft from `~/.local`:** that's the fallback when the AUR packages aren't found. It's pinned to the release whose checksums were verified (0.8.0); re-run the installer after updating `STORYTOLD_VER` to move to a newer one. AUR installs update with the rest of the system.
- **LightCraft on Wayland** runs through XWayland by default so drag-and-drop works; set `LIGHTCRAFT_WAYLAND=1` for native Wayland (sharper fractional scaling, no drop).
