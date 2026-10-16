pragma Singleton

// cachy-dots · live palette. `cachy-theme` writes ~/.config/cachy-dots/palette.json;
// this file watches it, so switching themes recolors the bar instantly.
// The defaults below (Gruvbox) only show until the file is read.
import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    readonly property string name:     pal.name
    readonly property string variant:  pal.variant
    readonly property color bg:        pal.bg
    readonly property color surface:   pal.surface
    readonly property color overlay:   pal.overlay
    readonly property color border:    pal.border
    readonly property color fg:        pal.fg
    readonly property color muted:     pal.muted
    readonly property color accent:    pal.accent
    readonly property color accent2:   pal.accent2
    readonly property color onAccent:  pal.onAccent
    readonly property color red:       pal.red
    readonly property color green:     pal.green
    readonly property color yellow:    pal.yellow
    readonly property color blue:      pal.blue
    readonly property color magenta:   pal.magenta
    readonly property color cyan:      pal.cyan

    // Fonts and sizes (not part of the color theme)
    readonly property string font:     "BlexMono Nerd Font Propo"
    readonly property string uiFont:   "IBM Plex Sans"
    readonly property int    fontSize: 12
    readonly property int    barHeight: 34
    readonly property int    radius:   10

    FileView {
        path: Quickshell.env("HOME") + "/.config/cachy-dots/palette.json"
        watchChanges: true
        onFileChanged: reload()

        JsonAdapter {
            id: pal
            property string name:     "Gruvbox Dark"
            property string variant:  "dark"
            property string bg:       "#1d2021"
            property string surface:  "#282828"
            property string overlay:  "#3c3836"
            property string border:   "#504945"
            property string fg:       "#ebdbb2"
            property string muted:    "#928374"
            property string accent:   "#fabd2f"
            property string accent2:  "#fe8019"
            property string onAccent: "#1d2021"
            property string red:      "#fb4934"
            property string green:    "#b8bb26"
            property string yellow:   "#fabd2f"
            property string blue:     "#83a598"
            property string magenta:  "#d3869b"
            property string cyan:     "#8ec07c"
            property string orange:   "#fe8019"
        }
    }
}
