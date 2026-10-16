// cachy-dots · theme picker
// A centered panel of theme cards with color swatches. Click one to apply it everywhere.
// Esc or a click outside closes it. Themes come from `cachy-theme list --json`.

import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts

PanelWindow {
    id: picker

    visible: Ui.themePickerOpen
    color: "transparent"

    // Show on whichever monitor is focused
    screen: {
        const m = Hyprland.focusedMonitor;
        const all = Quickshell.screens;
        for (let i = 0; i < all.length; i++)
            if (m && all[i].name === m.name) return all[i];
        return all[0];
    }

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
    WlrLayershell.namespace: "cachy-theme-picker"

    property var themes: []
    readonly property string themeCmd: Quickshell.env("HOME") + "/.local/bin/cachy-theme"

    onVisibleChanged: {
        if (visible) {
            listThemes.running = true;
            card.forceActiveFocus();
        }
    }

    function choose(id) {
        Quickshell.execDetached([picker.themeCmd, "set", id]);
        Ui.themePickerOpen = false;
    }

    Process {
        id: listThemes
        command: [picker.themeCmd, "list", "--json"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    picker.themes = JSON.parse(this.text);
                } catch (e) {
                    picker.themes = [];
                }
            }
        }
    }

    // Dimmed backdrop — click to close
    Rectangle {
        anchors.fill: parent
        color: "#000000"
        opacity: 0.35

        MouseArea {
            anchors.fill: parent
            onClicked: Ui.themePickerOpen = false
        }
    }

    Rectangle {
        id: card
        anchors.centerIn: parent
        width: 640
        height: content.implicitHeight + 40
        radius: 16
        color: Theme.surface
        border.color: Theme.border
        border.width: 1
        focus: true
        Keys.onEscapePressed: Ui.themePickerOpen = false

        // Swallow clicks so they don't reach the backdrop
        MouseArea { anchors.fill: parent }

        ColumnLayout {
            id: content
            anchors.fill: parent
            anchors.margins: 20
            spacing: 14

            RowLayout {
                Layout.fillWidth: true

                Text {
                    text: "Theme"
                    color: Theme.fg
                    font.family: Theme.uiFont
                    font.pixelSize: 18
                    font.bold: true
                }
                Item { Layout.fillWidth: true }
                Text {
                    text: "Esc to close"
                    color: Theme.muted
                    font.family: Theme.uiFont
                    font.pixelSize: 11
                }
            }

            GridLayout {
                Layout.fillWidth: true
                columns: 3
                columnSpacing: 10
                rowSpacing: 10

                Repeater {
                    model: picker.themes

                    Rectangle {
                        id: tile
                        required property var modelData
                        readonly property bool isWallpaper: modelData.id === "wallpaper"

                        Layout.fillWidth: true
                        Layout.preferredHeight: 70
                        radius: 10
                        color: isWallpaper ? Theme.overlay : modelData.colors[0]
                        border.width: modelData.active ? 2 : 1
                        border.color: modelData.active ? Theme.accent : Theme.border

                        Column {
                            anchors.fill: parent
                            anchors.margins: 12
                            spacing: 10

                            Text {
                                text: (tile.isWallpaper ? "󰸉  " : "") + tile.modelData.name
                                color: tile.isWallpaper ? Theme.fg
                                     : (tile.modelData.variant === "light" ? "#2a2a2a" : "#f2f2f2")
                                font.family: Theme.font
                                font.pixelSize: 13
                                font.bold: tile.modelData.active
                            }

                            Row {
                                spacing: 5
                                visible: !tile.isWallpaper

                                Repeater {
                                    model: tile.isWallpaper ? [] : tile.modelData.colors.slice(1)

                                    Rectangle {
                                        required property var modelData
                                        width: 14
                                        height: 14
                                        radius: 7
                                        color: modelData
                                    }
                                }
                            }

                            Text {
                                visible: tile.isWallpaper
                                text: "Material colors from your wallpaper"
                                color: Theme.muted
                                font.family: Theme.uiFont
                                font.pixelSize: 11
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: picker.choose(tile.modelData.id)
                        }
                    }
                }
            }

            // Wallpaper button
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 40
                radius: 10
                color: wallMouse.containsMouse ? Theme.overlay : "transparent"
                border.color: Theme.border
                border.width: 1

                Text {
                    anchors.centerIn: parent
                    text: "󰋩  Change wallpaper…"
                    color: Theme.fg
                    font.family: Theme.font
                    font.pixelSize: 13
                }

                MouseArea {
                    id: wallMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        Ui.themePickerOpen = false;
                        Quickshell.execDetached([picker.themeCmd, "pick-wallpaper"]);
                    }
                }
            }
        }
    }
}
