//@ pragma UseQApplication
// cachy-dots · Quickshell entry point
// UseQApplication is required for tray icon right-click menus.
// Quickshell hot-reloads this folder on save — just edit and watch.

import Quickshell
import Quickshell.Io
import QtQuick

ShellRoot {
    // One bar per monitor
    Variants {
        model: Quickshell.screens

        delegate: Component {
            Bar {}
        }
    }

    // Theme picker (Super+Shift+T, or the palette icon in the bar)
    ThemePicker {}

    // Power menu (Ctrl+Alt+Delete)
    PowerMenu {}

    // `qs ipc call theme toggle` — used by the Super+Shift+T keybind
    IpcHandler {
        target: "theme"

        function toggle(): void {
            Ui.themePickerOpen = !Ui.themePickerOpen;
        }
    }

    // `qs ipc call power toggle` — used by the Ctrl+Alt+Delete keybind
    IpcHandler {
        target: "power"

        function toggle(): void {
            Ui.powerMenuOpen = !Ui.powerMenuOpen;
        }
    }
}
