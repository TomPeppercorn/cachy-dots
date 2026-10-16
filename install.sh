#!/usr/bin/env bash
# ╭──────────────────────────────────────────────────────────────╮
# │  cachy-dots installer · Hyprland + Quickshell on CachyOS      │
# │                                                              │
# │  bash install.sh              interactive (a few questions)  │
# │  bash install.sh --yes        unattended, defaults/flags     │
# │  bash install.sh --dry-run    show what would happen, change │
# │                               nothing                        │
# │  bash install.sh --help       all options                    │
# │                                                              │
# │  Works from a plain text console (TTY) — no desktop needed.  │
# ╰──────────────────────────────────────────────────────────────╯
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
USER="${USER:-$(id -un)}"
CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}"
STAMP="$(date +%Y%m%d-%H%M%S)"
BACKUP="$CONFIG/cachy-dots/backups/$STAMP"
CD="$CONFIG/cachy-dots"

# ── defaults (overridable by flags) ──────────────────────────────
EDITOR_PICK=""   # none | codium
VIMRC=""         # awesome | basic | none
LAUNCHER=""      # vicinae | walker
GPU=""           # amd | nvidia | intel | hybrid
THEME="gruvbox-dark"
WANT_DEV=1
WANT_GAMING=1
WANT_EVERYDAY=1
WANT_CREATIVE=1
GROUPS_FROM_FLAGS=0
REMOVE_FIREFOX=1
REMOVE_GUI_TOOLS=1   # Shelly, pavucontrol, Blueman, nm-applet → replaced by TUIs
SETUP_LOGIN=1
ASSUME_YES=0
DRY_RUN=0

# ── pretty output ────────────────────────────────────────────────
c_acc=$'\e[38;2;250;189;47m'; c_ok=$'\e[38;2;184;187;38m'
c_warn=$'\e[38;2;254;128;25m'; c_err=$'\e[38;2;251;73;52m'
c_dim=$'\e[2m'; c_b=$'\e[1m'; c_0=$'\e[0m'
step() { printf '\n%s==>%s %s%s%s\n' "$c_acc" "$c_0" "$c_b" "$*" "$c_0"; }
ok()   { printf '  %s✓%s %s\n' "$c_ok" "$c_0" "$*"; }
warn() { printf '  %s!%s %s\n' "$c_warn" "$c_0" "$*"; }
die()  { printf '%s✗ %s%s\n' "$c_err" "$*" "$c_0" >&2; exit 1; }

# run: execute, or just print in --dry-run
run() {
    if (( DRY_RUN )); then printf '  %s[dry-run]%s %s\n' "$c_dim" "$c_0" "$*"; return 0; fi
    "$@"
}

usage() {
    cat <<EOF
cachy-dots installer

Options:
  --launcher NAME   vicinae | walker
  --gpu NAME        amd | nvidia | intel | hybrid   (default: detected)
  --editor NAME     none | codium   (extra editor; neovim comes with dev tools)
  --vimrc NAME      awesome | basic | none   (amix/vimrc for Vim)
  --theme NAME      starting color theme, e.g. gruvbox-dark, catppuccin-mocha, nord, wallpaper
  --no-dev          skip dev tools
  --no-gaming       skip CachyOS gaming packages
  --no-everyday     skip Helium / Vesktop / media apps
  --no-creative     skip Blender / FilmCraft / LightCraft
  --keep-firefox    don't uninstall Firefox
  --keep-gui-tools  don't remove Shelly / pavucontrol / Blueman / nm-applet (the TUIs replace them)
  --no-login-screen don't set up SDDM even if no login screen is enabled
  -y, --yes         no questions; also passes --noconfirm/--skipreview to paru
  --dry-run         print every action without changing anything
  -h, --help        this help
EOF
}

while (( $# )); do
    case "$1" in
        --launcher)        LAUNCHER="${2:-}"; shift ;;
        --gpu)             GPU="${2:-}"; shift ;;
        --editor)          EDITOR_PICK="${2:-}"; shift ;;
        --vimrc)           VIMRC="${2:-}"; shift ;;
        --theme)           THEME="${2:-}"; shift ;;
        --no-dev)          WANT_DEV=0; GROUPS_FROM_FLAGS=1 ;;
        --no-gaming)       WANT_GAMING=0; GROUPS_FROM_FLAGS=1 ;;
        --no-everyday)     WANT_EVERYDAY=0; GROUPS_FROM_FLAGS=1 ;;
        --no-creative)     WANT_CREATIVE=0; GROUPS_FROM_FLAGS=1 ;;
        --keep-firefox)    REMOVE_FIREFOX=0 ;;
        --keep-gui-tools)  REMOVE_GUI_TOOLS=0 ;;
        --no-login-screen) SETUP_LOGIN=0 ;;
        -y|--yes)          ASSUME_YES=1 ;;
        --dry-run)         DRY_RUN=1 ;;
        -h|--help)         usage; exit 0 ;;
        *)                 usage; die "Unknown option: $1" ;;
    esac
    shift
done

# ── prompts ──────────────────────────────────────────────────────
# pick VAR "Question" default_key key1 "label1" key2 "label2" ...
pick() {
    local __var="$1" question="$2" default="$3"; shift 3
    local -a keys=() labels=()
    while (( $# )); do keys+=("$1"); labels+=("$2"); shift 2; done

    if [[ -n "${!__var}" ]]; then   # already set by a flag — validate it
        local k; for k in "${keys[@]}"; do [[ "$k" == "${!__var}" ]] && return 0; done
        die "Invalid value '${!__var}' for: $question (choose: ${keys[*]})"
    fi
    if (( ASSUME_YES )) || [[ ! -t 0 ]]; then printf -v "$__var" '%s' "$default"; return 0; fi

    printf '\n%s%s%s\n' "$c_b" "$question" "$c_0"
    local i def_n=1
    for i in "${!keys[@]}"; do
        local mark=" "
        [[ "${keys[$i]}" == "$default" ]] && { mark="*"; def_n=$((i+1)); }
        printf '  %s%d)%s %s %s\n' "$c_acc" $((i+1)) "$c_0" "$mark" "${labels[$i]}"
    done
    local ans
    while true; do
        read -rp "  choice [${def_n}]: " ans
        ans="${ans:-$def_n}"
        if [[ "$ans" =~ ^[0-9]+$ ]] && (( ans >= 1 && ans <= ${#keys[@]} )); then
            printf -v "$__var" '%s' "${keys[$((ans-1))]}"; return 0
        fi
        warn "Pick a number from 1 to ${#keys[@]}"
    done
}

yesno() { # yesno "Question" default(y/n) -> returns 0 for yes
    local q="$1" d="${2:-y}" ans
    if (( ASSUME_YES )) || [[ ! -t 0 ]]; then [[ "$d" == y ]]; return; fi
    read -rp "$(printf '%s%s%s [%s] ' "$c_b" "$q" "$c_0" "$([[ $d == y ]] && echo Y/n || echo y/N)")" ans
    ans="${ans:-$d}"; [[ "${ans,,}" == y* ]]
}

read_list() { grep -vE '^\s*(#|$)' "$1" | awk '{print $1}'; }

# Which GPUs are in this machine? (vendor IDs from sysfs, no extra tools needed)
detect_gpu() {
    local v nvidia=0 amd=0 intel=0
    for v in /sys/class/drm/card*/device/vendor; do
        [[ -r "$v" ]] || continue
        case "$(<"$v")" in
            0x10de) nvidia=1 ;;
            0x1002) amd=1 ;;
            0x8086) intel=1 ;;
        esac
    done
    if (( nvidia && (amd || intel) )); then echo hybrid
    elif (( nvidia )); then echo nvidia
    elif (( amd )); then echo amd
    elif (( intel )); then echo intel
    else echo amd; fi
}

# ── preflight ────────────────────────────────────────────────────
printf '%s' "$c_acc"
cat <<'ART'
   ┌─┐┌─┐┌─┐┬ ┬┬ ┬   ┌┬┐┌─┐┌┬┐┌─┐
   │  ├─┤│  ├─┤└┬┘ ── │││ │ │ └─┐
   └─┘┴ ┴└─┘┴ ┴ ┴    ─┴┘└─┘ ┴ └─┘   Hyprland · Quickshell · theme manager
ART
printf '%s' "$c_0"

(( EUID == 0 )) && die "Run this as your normal user, not root (it uses sudo when needed)."
command -v pacman >/dev/null || die "pacman not found — this is for CachyOS / Arch."
grep -qi cachyos /etc/os-release 2>/dev/null || warn "This doesn't look like CachyOS. Arch should work, but gaming meta-packages are CachyOS-only."
(( DRY_RUN )) && warn "Dry run: nothing will be installed or changed."

# Is a login screen already enabled? (sddm, gdm, greetd… all register as display-manager.service)
EXISTING_DM=""
if systemctl is-enabled --quiet display-manager.service 2>/dev/null; then
    EXISTING_DM="$(basename "$(readlink -f /etc/systemd/system/display-manager.service 2>/dev/null)" .service)"
    [[ -z "$EXISTING_DM" || "$EXISTING_DM" == display-manager ]] && EXISTING_DM="your existing login screen"
fi
NEED_LOGIN=0
(( SETUP_LOGIN )) && [[ -z "$EXISTING_DM" ]] && NEED_LOGIN=1

# ── questions ────────────────────────────────────────────────────
step "A few picks"

if [[ -t 0 ]] && (( ! ASSUME_YES && ! GROUPS_FROM_FLAGS )); then
    yesno "Install dev tools (git, docker, neovim, node, python, go…)?" y && WANT_DEV=1 || WANT_DEV=0
    yesno "Install CachyOS gaming packages (Steam, Lutris, Heroic, MangoHud, Proton)?" y && WANT_GAMING=1 || WANT_GAMING=0
    yesno "Install everyday apps (Helium, Vesktop, mpv) and replace Firefox?" y && WANT_EVERYDAY=1 || WANT_EVERYDAY=0
    yesno "Install creative apps (Blender, FilmCraft video editor, LightCraft photo editor)?" y && WANT_CREATIVE=1 || WANT_CREATIVE=0
fi
if [[ -t 0 ]] && (( ! ASSUME_YES && REMOVE_GUI_TOOLS )); then
    yesno "Remove the GUI tools the terminal apps replace (Shelly, pavucontrol, Blueman, network applet)?" y \
        && REMOVE_GUI_TOOLS=1 || REMOVE_GUI_TOOLS=0
fi

pick LAUNCHER "Launcher?" vicinae \
    vicinae "Vicinae — Raycast-style: apps, indexed file search, clipboard, calculator, emoji, extensions" \
    walker  "Walker  — lighter GTK launcher: apps, file search, clipboard, calculator"

DETECTED_GPU="$(detect_gpu)"
pick GPU "Graphics card? (detected: $DETECTED_GPU)" "$DETECTED_GPU" \
    amd    "AMD" \
    nvidia "NVIDIA (desktop)" \
    intel  "Intel" \
    hybrid "Laptop with NVIDIA + Intel/AMD (desktop runs on the integrated GPU)"

if (( WANT_DEV )); then
    pick EDITOR_PICK "Editor besides Neovim?" none \
        none "Just Neovim" \
        codium "VSCodium (VS Code without Microsoft telemetry; AUR, builds from source — slow)"
else
    EDITOR_PICK="${EDITOR_PICK:-none}"
fi

pick VIMRC "Set up Vim with amix/vimrc (github.com/amix/vimrc)?" awesome \
    awesome "Awesome — plugins, color schemes, file tree, fuzzy finder" \
    basic   "Basic — one file of sensible settings, no plugins" \
    none    "Leave Vim as it is"

[[ "$THEME" == wallpaper || -f "$REPO/themes/$THEME.json" ]] \
    || die "Unknown theme '$THEME'. Choose from: $(cd "$REPO/themes" && ls *.json | sed 's/\.json$//' | tr '\n' ' ')wallpaper"

# ── resolve package set ──────────────────────────────────────────
# PKGS: official-repo packages (every name checked against archlinux.org), installed in one go.
# AUR: AUR packages by exact name (each checked against its AUR page or upstream install docs).
# Each AUR name is still looked up before installing, so if one is ever renamed or removed,
# that one is skipped with a warning instead of failing the whole install.
declare -a PKGS=() AUR=()
mapfile -t -O "${#PKGS[@]}" PKGS < <(read_list "$REPO/packages/base.txt")
(( WANT_DEV ))      && mapfile -t -O "${#PKGS[@]}" PKGS < <(read_list "$REPO/packages/dev.txt")
(( WANT_GAMING ))   && mapfile -t -O "${#PKGS[@]}" PKGS < <(read_list "$REPO/packages/gaming.txt")
(( WANT_EVERYDAY )) && mapfile -t -O "${#PKGS[@]}" PKGS < <(read_list "$REPO/packages/everyday.txt")
(( WANT_CREATIVE )) && mapfile -t -O "${#PKGS[@]}" PKGS < <(read_list "$REPO/packages/creative.txt")
(( NEED_LOGIN ))    && PKGS+=(sddm qt6-svg qt6-virtualkeyboard qt6-multimedia-ffmpeg git)

AUR+=(hyprmod)                                   # github.com/BlueManCZ/hyprmod README
AUR+=(wlctl-bin pacsea-bin)                      # Wi-Fi + package TUIs: wlctl README; Pacsea README + its PKGBUILD-bin
(( WANT_EVERYDAY )) && AUR+=(helium-browser-bin vesktop)   # AUR pages checked
case "$LAUNCHER" in
    vicinae) AUR+=(vicinae-bin) ;;              # docs.vicinae.com/install
    walker)  AUR+=(walker elephant elephant-desktopapplications elephant-files elephant-clipboard
                   elephant-calc elephant-runner elephant-symbols elephant-providerlist) ;;
             # walker + elephant: AUR pages; providers: listed on the elephant AUR page
esac

case "$GPU" in
    nvidia) PKGS+=(libva-nvidia-driver) ;;
    hybrid) PKGS+=(nvidia-prime) ;;
esac

case "$EDITOR_PICK" in
    codium) AUR+=(vscodium) ;;   # AUR page checked
esac

[[ "$VIMRC" != none ]] && PKGS+=(vim git)   # vim usually comes with CachyOS's Common packages

# de-duplicate, keep order
mapfile -t PKGS < <(printf '%s\n' "${PKGS[@]}" | awk '!seen[$0]++')

yn() { (( $1 )) && echo yes || echo no; }
step "Plan"
printf '  Launcher: %s   GPU: %s   Theme: %s   Editor: neovim%s   Vim: %s\n' "$LAUNCHER" "$GPU" "$THEME" \
    "$([[ $EDITOR_PICK != none ]] && echo " + $EDITOR_PICK")" "$([[ $VIMRC != none ]] && echo "amix/vimrc ($VIMRC)" || echo unchanged)"
printf '  Dev: %s   Gaming: %s   Everyday: %s   Creative: %s   Remove Firefox: %s\n' \
    "$(yn "$WANT_DEV")" "$(yn "$WANT_GAMING")" "$(yn "$WANT_EVERYDAY")" "$(yn "$WANT_CREATIVE")" \
    "$(yn $(( WANT_EVERYDAY && REMOVE_FIREFOX )))"
printf '  System tools: wlctl (Wi-Fi), bluetui (Bluetooth), wiremix (sound), Pacsea (packages) · remove GUI ones: %s\n' \
    "$(yn "$REMOVE_GUI_TOOLS")"
if [[ -n "$EXISTING_DM" ]]; then
    printf '  Login screen: keeping %s\n' "$EXISTING_DM"
elif (( NEED_LOGIN )); then
    printf '  Login screen: none found — will set up SDDM with the astronaut theme\n'
else
    printf '  Login screen: none, and --no-login-screen given — start Hyprland with start-hyprland\n'
fi
printf '  %d packages + %d from the AUR · old configs backed up to %s\n' \
    "${#PKGS[@]}" "${#AUR[@]}" "${BACKUP/#$HOME/\~}"
yesno "Go?" y || die "Cancelled."

# ── paru ─────────────────────────────────────────────────────────
# CachyOS stopped preinstalling paru in June 2026, so install it if missing.
step "Making sure paru (AUR helper) is available"
if command -v paru >/dev/null; then
    ok "paru found"
else
    if pacman -Si paru >/dev/null 2>&1; then
        run sudo pacman -S --needed --noconfirm paru
    else
        warn "paru isn't in your repos — building paru-bin from the AUR"
        run sudo pacman -S --needed --noconfirm git base-devel
        tmp="$(mktemp -d)"
        run git clone --depth=1 https://aur.archlinux.org/paru-bin.git "$tmp/paru-bin"
        (( DRY_RUN )) || (cd "$tmp/paru-bin" && makepkg -si --noconfirm)
        rm -rf "$tmp"
    fi
    ok "paru ready"
fi

# ── packages ─────────────────────────────────────────────────────
step "Updating system and installing packages"
PARU_FLAGS=(--needed)
(( ASSUME_YES )) && PARU_FLAGS+=(--noconfirm --skipreview)
run sudo pacman -Syu --noconfirm
run paru -S "${PARU_FLAGS[@]}" "${PKGS[@]}"
ok "Main packages installed"

declare -a FOUND=()
for name in "${AUR[@]}"; do
    if (( DRY_RUN )) || paru -Si "$name" >/dev/null 2>&1; then FOUND+=("$name")
    else warn "AUR package '$name' wasn't found — skipped. Check https://aur.archlinux.org/packages/$name"; fi
done
if (( ${#FOUND[@]} )); then
    run paru -S "${PARU_FLAGS[@]}" "${FOUND[@]}"
    ok "AUR packages installed: ${FOUND[*]}"
fi

# ── GUI tools → TUIs ─────────────────────────────────────────────
# Each GUI tool is removed only if its replacement actually installed, one at a time,
# so anything another package still needs is kept instead of failing the whole step.
if (( REMOVE_GUI_TOOLS )); then
    step "Replacing GUI system tools with the terminal apps"
    for pair in "shelly:pacsea" "pavucontrol:wiremix" "blueman:bluetui" "network-manager-applet:wlctl"; do
        gui="${pair%%:*}"; tui="${pair##*:}"
        if (( DRY_RUN )); then
            printf '  %s[dry-run]%s sudo pacman -Rns %s   (only if installed and %s installed)\n' "$c_dim" "$c_0" "$gui" "$tui"
            continue
        fi
        pacman -Q "$gui" >/dev/null 2>&1 || continue
        if ! command -v "$tui" >/dev/null; then
            warn "Kept $gui: its replacement ($tui) didn't install"
            continue
        fi
        if out="$(sudo pacman -Rns --noconfirm "$gui" 2>&1)"; then
            ok "Removed $gui → use $tui"
        else
            why="$(printf '%s' "$out" | grep -m1 -iE 'required by' || printf '%s' "$out" | grep -m1 -i 'error' || echo 'pacman refused to remove it')"
            warn "Kept $gui (${why#:: })"
        fi
    done
fi

# ── creative apps ────────────────────────────────────────────────
# Blender comes from the official repos (packages/creative.txt). FilmCraft and LightCraft
# (github.com/storytold) install from the AUR -bin packages when they exist, so they update with
# the rest of the system. Otherwise: the project's own release tarball, checked against its
# published SHA256SUMS.txt and installed into ~/.local, the same way FilmCraft's install.sh does it.
STORYTOLD_VER=0.8.0   # tarball fallback only; checksums verified for this release

install_storytold_tarball() { # app
    local app="$1" ver="$STORYTOLD_VER" base="https://github.com/storytold/$1/releases/download/v$STORYTOLD_VER"
    local file="$app-$ver-linux-x86_64.tar.gz" tmp want got prefix="$HOME/.local"
    if (( DRY_RUN )); then
        printf '  %s[dry-run]%s download %s, check it against SHA256SUMS.txt, install into ~/.local\n' "$c_dim" "$c_0" "$file"
        return 0
    fi
    tmp="$(mktemp -d)"
    if ! curl -fsSL -o "$tmp/$file" "$base/$file" || ! curl -fsSL -o "$tmp/SHA256SUMS.txt" "$base/SHA256SUMS.txt"; then
        warn "Couldn't download $app $ver — skipped"; rm -rf "$tmp"; return 1
    fi
    want="$(awk -v f="$file" '$2 == f {print $1}' "$tmp/SHA256SUMS.txt")"
    got="$(sha256sum "$tmp/$file" | cut -d' ' -f1)"
    if [[ -z "$want" || "$want" != "$got" ]]; then
        warn "$app download didn't match its published checksum — not installed"; rm -rf "$tmp"; return 1
    fi
    tar -xzf "$tmp/$file" -C "$tmp"
    local src="$tmp/$app-$ver-linux-x86_64"
    mkdir -p "$prefix/bin" "$prefix/share"
    install -m755 "$src/bin/$app" "$prefix/bin/$app"
    install -m755 "$src/bin/$app-cli" "$prefix/bin/$app-cli"
    cp -R "$src/share/." "$prefix/share/"
    # Absolute Exec path so the app menu doesn't depend on PATH (as upstream's install.sh does)
    sed -i -e "s|^Exec=$app |Exec=\"$prefix/bin/$app\" |" -e "s|^TryExec=.*|TryExec=$prefix/bin/$app|" \
        "$prefix/share/applications/ai.storyteller.$app.desktop"
    command -v update-desktop-database >/dev/null && update-desktop-database -q "$prefix/share/applications" || true
    command -v update-mime-database >/dev/null && update-mime-database "$prefix/share/mime" >/dev/null 2>&1 || true
    rm -rf "$tmp"
    ok "Installed $app $ver into ~/.local (checksum verified). Re-run this installer to update it."
}

if (( WANT_CREATIVE )); then
    step "Creative apps: Blender, FilmCraft, LightCraft"
    for app in filmcraft lightcraft; do
        if pacman -Q "$app-bin" >/dev/null 2>&1; then
            ok "$app-bin already installed"
        elif (( ! DRY_RUN )) && paru -Si "$app-bin" >/dev/null 2>&1; then
            if run paru -S "${PARU_FLAGS[@]}" "$app-bin"; then
                ok "Installed $app-bin (AUR, updates with your system)"
                # drop an earlier ~/.local fallback copy so there's only one
                rm -f "$HOME/.local/bin/$app" "$HOME/.local/bin/$app-cli" \
                      "$HOME/.local/share/applications/ai.storyteller.$app.desktop"
            else
                warn "$app-bin failed to install — trying the official release instead"
                install_storytold_tarball "$app" || true
            fi
        else
            (( DRY_RUN )) && printf '  %s[dry-run]%s paru -S %s   (if it exists in the AUR, else:)\n' "$c_dim" "$c_0" "$app-bin" \
                          || warn "AUR package '$app-bin' wasn't found — installing the official release instead"
            install_storytold_tarball "$app" || true
        fi
    done
fi

# ── Firefox → Helium ─────────────────────────────────────────────
if (( WANT_EVERYDAY )); then
    step "Setting Helium as your browser"
    if (( DRY_RUN )) || pacman -Q helium-browser-bin >/dev/null 2>&1 || command -v helium-browser >/dev/null; then
        desktop="$(find /usr/share/applications -maxdepth 1 -iname 'helium*.desktop' -printf '%f\n' 2>/dev/null | head -n1)"
        desktop="${desktop:-helium-browser.desktop}"
        run xdg-settings set default-web-browser "$desktop" 2>/dev/null || true
        for mime in x-scheme-handler/http x-scheme-handler/https text/html application/xhtml+xml; do
            run xdg-mime default "$desktop" "$mime" || true
        done
        ok "Default browser → ${desktop%.desktop}"

        if (( REMOVE_FIREFOX )); then
            mapfile -t ff < <(pacman -Qq 2>/dev/null | grep -E '^(firefox|firefox-.*|cachyos-firefox-settings)$' || true)
            if (( ${#ff[@]} )); then
                if run sudo pacman -Rns --noconfirm "${ff[@]}"; then
                    ok "Removed: ${ff[*]}"
                else
                    warn "Couldn't remove Firefox cleanly (something depends on it). Left it installed."
                fi
            else
                ok "Firefox isn't installed — nothing to remove"
            fi
        fi
    else
        warn "Helium didn't install, so Firefox was left alone. Re-run the installer once paru succeeds."
    fi
fi

# ── configs ──────────────────────────────────────────────────────
step "Installing configs (backups → ${BACKUP/#$HOME/\~})"
run mkdir -p "$BACKUP" "$CD/themes" "$CD/wallpapers" "$HOME/.local/bin"

for dir in hypr quickshell kitty btop; do
    if [[ -e "$CONFIG/$dir" ]]; then
        run mv "$CONFIG/$dir" "$BACKUP/$dir"
    fi
    run cp -r "$REPO/config/$dir" "$CONFIG/$dir"
done

# Single files we own inside folders that may hold other things of yours
backup_file() { # backup_file <path>
    if [[ -f "$1" ]]; then
        run mkdir -p "$BACKUP/$(dirname "${1#$HOME/}")"
        run cp "$1" "$BACKUP/${1#$HOME/}"
    fi
}
for f in "$CONFIG/gtk-3.0/gtk.css" "$CONFIG/gtk-4.0/gtk.css" "$CONFIG/swaync/style.css"; do backup_file "$f"; done
case "$LAUNCHER" in
    vicinae) backup_file "$CONFIG/vicinae/settings.json"
             run install -Dm644 "$REPO/config/vicinae/settings.json" "$CONFIG/vicinae/settings.json" ;;
    walker)  backup_file "$CONFIG/walker/config.toml"
             run install -Dm644 "$REPO/config/walker/config.toml" "$CONFIG/walker/config.toml" ;;
esac

# Keep what's yours across re-installs: your tweaks and HyprMod's saved settings
for keep in user.lua hyprland-gui.lua; do
    if [[ -f "$BACKUP/hypr/$keep" ]]; then
        run cp "$BACKUP/hypr/$keep" "$CONFIG/hypr/$keep"
        ok "Kept your $keep"
    fi
done

if (( ! WANT_EVERYDAY )); then
    # no Helium: point Super+B at your current default browser instead
    run sed -i 's|local browser     = "helium-browser"|local browser     = "gtk-launch $(xdg-settings get default-web-browser)"|' "$CONFIG/hypr/cachy/binds.lua"
fi

# GPU settings
case "$GPU" in
    nvidia) gpu_lua='-- NVIDIA (desktop) — written by the cachy-dots installer.
-- Hardware video decoding (libva-nvidia-driver) and the right OpenGL vendor library.
hl.env("LIBVA_DRIVER_NAME", "nvidia")
hl.env("__GLX_VENDOR_LIBRARY_NAME", "nvidia")
hl.env("NVD_BACKEND", "direct")' ;;
    hybrid) gpu_lua='-- Hybrid laptop (integrated + NVIDIA) — written by the cachy-dots installer.
-- The desktop runs on the integrated GPU to save battery. NVIDIA-only variables are left
-- out on purpose: set globally, they force everything onto the NVIDIA card.
-- Run a game on NVIDIA with:  prime-run <program>   (Steam launch option: prime-run %command%)' ;;
    *)      gpu_lua="-- $GPU — written by the cachy-dots installer. Nothing extra needed." ;;
esac
if (( DRY_RUN )); then
    printf '  %s[dry-run]%s write %s (%s)\n' "$c_dim" "$c_0" "$CONFIG/hypr/cachy/gpu.lua" "$GPU"
else
    printf '%s\n' "$gpu_lua" > "$CONFIG/hypr/cachy/gpu.lua"
fi

# Launcher choice (read by cachy-launcher)
if (( DRY_RUN )); then
    printf '  %s[dry-run]%s write %s (LAUNCHER=%s)\n' "$c_dim" "$c_0" "$CD/settings" "$LAUNCHER"
else
    cat > "$CD/settings" <<EOF
# cachy-dots choices. Switch launcher by changing this (and installing the other one).
LAUNCHER=$LAUNCHER
EOF
fi

# Scripts, themes, wallpapers
for s in "$REPO"/bin/*; do
    [[ -f "$s" ]] || continue
    run install -Dm755 "$s" "$HOME/.local/bin/$(basename "$s")"
done
# App-menu entries: open the TUIs as floating windows. wiremix/btop/pacsea entries replace
# the stock ones (same filename, ~/.local/share wins over /usr/share).
for d in "$REPO"/config/applications/*.desktop; do
    [[ -f "$d" ]] || continue
    dst="$HOME/.local/share/applications/$(basename "$d")"
    backup_file "$dst"
    if (( DRY_RUN )); then
        printf '  %s[dry-run]%s write %s\n' "$c_dim" "$c_0" "$dst"
    else
        mkdir -p "$(dirname "$dst")"
        sed "s|@HOME@|$HOME|g" "$d" > "$dst"
    fi
done
for t in "$REPO"/themes/*.json; do
    [[ -f "$t" ]] || continue
    run install -Dm644 "$t" "$CD/themes/$(basename "$t")"
done
for w in "$REPO"/wallpapers/*; do
    [[ -f "$w" ]] || continue
    run install -Dm644 "$w" "$CD/wallpapers/$(basename "$w")"
done
ok "Configs, scripts, themes and wallpapers in place"

# ── colors ───────────────────────────────────────────────────────
step "Applying your theme"
THEME_CMD="$HOME/.local/bin/cachy-theme"
if [[ ! -e "$CD/wallpaper" ]]; then
    run python3 "$THEME_CMD" wallpaper "$CD/wallpapers/gruvbox-hills.png"
fi
if [[ ! -f "$CD/state.json" ]] || [[ "$THEME" != gruvbox-dark ]]; then
    # first install (or --theme given): set the starting theme without reloading anything
    if (( DRY_RUN )); then
        printf '  %s[dry-run]%s cachy-theme set %s (no reload)\n' "$c_dim" "$c_0" "$THEME"
    else
        printf '{"theme": "%s", "variant": "dark"}\n' "$THEME" > "$CD/state.json"
    fi
fi
if run python3 "$THEME_CMD" apply --no-reload; then
    ok "Theme applied — switch any time with Super+Shift+T"
else
    warn "Couldn't apply the theme (see the message above). Run 'cachy-theme apply' after logging in."
fi

# ── vim ──────────────────────────────────────────────────────────
if [[ "$VIMRC" != none ]]; then
    step "Setting up Vim (amix/vimrc, $VIMRC)"
    backup_file "$HOME/.vimrc"          # the vimrc installer overwrites ~/.vimrc
    if [[ -d "$HOME/.vim_runtime/.git" ]]; then
        run git -C "$HOME/.vim_runtime" pull --rebase --quiet || warn "Couldn't update ~/.vim_runtime; kept the current copy"
    elif [[ -e "$HOME/.vim_runtime" ]]; then
        warn "~/.vim_runtime exists but isn't a git checkout — left it alone"
    else
        run git clone --depth=1 https://github.com/amix/vimrc.git "$HOME/.vim_runtime"
    fi
    if [[ -f "$HOME/.vim_runtime/install_${VIMRC}_vimrc.sh" ]] || (( DRY_RUN )); then
        run sh "$HOME/.vim_runtime/install_${VIMRC}_vimrc.sh" >/dev/null
        if [[ "$VIMRC" == awesome ]]; then
            ok "Vim set up — put your own tweaks in ~/.vim_runtime/my_configs.vim"
        else
            ok "Vim set up — add your own tweaks at the end of ~/.vimrc"
        fi
    else
        warn "amix/vimrc installer not found — Vim left unchanged"
    fi
fi

# ── login screen ─────────────────────────────────────────────────
if (( NEED_LOGIN )); then
    step "Setting up the login screen (SDDM + astronaut theme)"
    theme_dst=/usr/share/sddm/themes/sddm-astronaut-theme
    tmp="$(mktemp -d)"
    if run git clone -q --depth 1 https://github.com/Keyitdev/sddm-astronaut-theme.git "$tmp/theme"; then
        run sudo rm -rf "$theme_dst"
        run sudo mkdir -p "$theme_dst" /usr/share/fonts/sddm-astronaut-theme
        (( DRY_RUN )) || sudo cp -r "$tmp/theme/." "$theme_dst/"
        (( DRY_RUN )) || [[ ! -d "$tmp/theme/Fonts" ]] || sudo cp -r "$tmp/theme/Fonts/." /usr/share/fonts/sddm-astronaut-theme/
        run sudo rm -rf "$theme_dst/.git"
        run sudo install -Dm644 "$REPO/config/sddm/10-cachy-dots.conf" /etc/sddm.conf.d/10-cachy-dots.conf
        ok "Astronaut theme installed — change its style any time with: cachy-login-theme"
    else
        warn "Couldn't download the SDDM theme; SDDM will use its default look."
    fi
    rm -rf "$tmp"
    # enable only — starting it now would take over the console you're typing in
    run sudo systemctl enable sddm.service
    ok "Login screen enabled — it appears after a reboot"
elif [[ -n "$EXISTING_DM" ]]; then
    ok "Login screen: kept $EXISTING_DM"
fi

# ── system tweaks ────────────────────────────────────────────────
step "Final touches"
run xdg-user-dirs-update || true
run mkdir -p "$(xdg-user-dir PICTURES 2>/dev/null || echo "$HOME/Pictures")/Screenshots" \
             "$(xdg-user-dir PICTURES 2>/dev/null || echo "$HOME/Pictures")/Wallpapers"
if command -v gsettings >/dev/null || (( DRY_RUN )); then
    run gsettings set org.gnome.desktop.interface font-name 'IBM Plex Sans 11' || true
    run gsettings set org.gnome.desktop.interface document-font-name 'IBM Plex Sans 11' || true
    run gsettings set org.gnome.desktop.interface monospace-font-name 'BlexMono Nerd Font 11' || true
fi

run sudo systemctl enable --now bluetooth.service || warn "Bluetooth service not enabled (no adapter?)"

if (( WANT_DEV )); then
    run sudo systemctl enable --now docker.service
    if ! id -nG "$USER" 2>/dev/null | grep -qw docker; then
        run sudo usermod -aG docker "$USER"
        ok "Added you to the docker group (applies from your next login)"
    fi
fi

# ── done ─────────────────────────────────────────────────────────
step "Done"
if (( NEED_LOGIN )); then
    next="Type ${c_b}reboot${c_0}${c_ok}. Pick the Hyprland session on the login screen and log in.${c_0}"
elif [[ -n "$EXISTING_DM" ]]; then
    next="Log out (or reboot) and pick ${c_b}Hyprland${c_0}${c_ok} on the login screen.${c_0}"
else
    next="Run ${c_b}start-hyprland${c_0}${c_ok} from the console to start your desktop.${c_0}"
fi
cat <<EOF
  ${c_ok}${next}

  Super + Space        launcher           Super + Return   terminal
  Super + Shift + T    theme picker       Super + ,        Hyprland settings (HyprMod)
  Super + /            ${c_b}every keybind${c_0}      Super + Q        close window

  Your own binds:   ~/.config/hypr/user.lua   (never overwritten)
  Old configs:      ${BACKUP/#$HOME/\~}
EOF
