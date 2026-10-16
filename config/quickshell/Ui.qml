pragma Singleton

// Shared UI state, so the bar button and the Super+Shift+T keybind open the same picker.
import Quickshell
import QtQuick

Singleton {
    property bool themePickerOpen: false
}
