// cachy-dots · top bar
// Left: workspaces + focused window · Center: clock
// Right: CPU · RAM · net speed, tray, network, Bluetooth, volume, battery, theme, notifications

import Quickshell
import Quickshell.Hyprland
import Quickshell.Services.Pipewire
import Quickshell.Services.SystemTray
import Quickshell.Services.UPower
import QtQuick
import QtQuick.Layouts

PanelWindow {
    id: bar

    required property var modelData
    screen: modelData

    anchors {
        top: true
        left: true
        right: true
    }

    implicitHeight: Theme.barHeight + 8
    color: "transparent"

    // Hyprland's dispatcher syntax differs between Lua configs (0.55+) and legacy hyprlang
    function goToWorkspace(id) {
        if (Hyprland.usingLua)
            Hyprland.dispatch("hl.dsp.focus({ workspace = " + id + " })");
        else
            Hyprland.dispatch("workspace " + id);
    }

    function workspaceById(id) {
        const all = Hyprland.workspaces.values;
        for (let i = 0; i < all.length; i++)
            if (all[i].id === id) return all[i];
        return null;
    }

    Rectangle {
        anchors.fill: parent
        anchors.topMargin: 6
        anchors.leftMargin: 10
        anchors.rightMargin: 10
        radius: Theme.radius
        color: Theme.bg
        border.color: Theme.overlay
        border.width: 1
        Behavior on color { ColorAnimation { duration: 250 } }

        // ───────────── LEFT ─────────────
        RowLayout {
            anchors.left: parent.left
            anchors.leftMargin: 8
            anchors.verticalCenter: parent.verticalCenter
            spacing: 10

            Row {
                spacing: 4

                Repeater {
                    model: 10

                    Rectangle {
                        id: wsButton
                        required property int index
                        readonly property int wsId: index + 1
                        readonly property var ws: bar.workspaceById(wsId)
                        readonly property bool isFocused: !!Hyprland.focusedWorkspace
                                                          && Hyprland.focusedWorkspace.id === wsId
                        readonly property bool isOccupied: !!ws && ws.toplevels.values.length > 0

                        // Always show 1–5; show 6–10 only when they exist
                        visible: wsId <= 5 || !!ws
                        width: isFocused ? 26 : 18
                        height: 18
                        radius: 9
                        color: isFocused ? Theme.accent
                             : isOccupied ? Theme.overlay
                             : "transparent"
                        border.color: isFocused ? Theme.accent : Theme.overlay
                        border.width: 1

                        Behavior on width { NumberAnimation { duration: 140; easing.type: Easing.OutCubic } }
                        Behavior on color { ColorAnimation { duration: 140 } }

                        Text {
                            anchors.centerIn: parent
                            text: wsButton.wsId === 10 ? "0" : wsButton.wsId
                            color: wsButton.isFocused ? Theme.accentFg : Theme.fg
                            font.family: Theme.font
                            font.pixelSize: 10
                            font.bold: wsButton.isFocused
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: bar.goToWorkspace(wsButton.wsId)
                        }
                    }
                }
            }

            Text {
                Layout.maximumWidth: bar.width * 0.28
                text: Hyprland.activeToplevel ? Hyprland.activeToplevel.title : ""
                color: Theme.muted
                elide: Text.ElideRight
                font.family: Theme.uiFont
                font.pixelSize: Theme.fontSize
            }
        }

        // ───────────── CENTER ─────────────
        Text {
            anchors.centerIn: parent
            text: Qt.formatDateTime(clock.date, "ddd d MMM   hh:mm")
            color: Theme.fg
            font.family: Theme.font
            font.pixelSize: Theme.fontSize + 1
            font.bold: true

            SystemClock {
                id: clock
                precision: SystemClock.Minutes
            }
        }

        // ───────────── RIGHT ─────────────
        RowLayout {
            anchors.right: parent.right
            anchors.rightMargin: 12
            anchors.verticalCenter: parent.verticalCenter
            spacing: 14

            // CPU, RAM, download/upload (click for btop). Loaded separately like the icons below.
            Loader {
                source: Qt.resolvedUrl("StatsIndicator.qml")
                visible: status === Loader.Ready
                Layout.alignment: Qt.AlignVCenter
            }

            // System tray
            Row {
                spacing: 8

                Repeater {
                    model: SystemTray.items

                    Item {
                        id: trayItem
                        required property var modelData
                        width: 16
                        height: 16

                        Image {
                            anchors.fill: parent
                            source: trayItem.modelData.icon
                            sourceSize.width: 16
                            sourceSize.height: 16
                            smooth: true
                        }

                        MouseArea {
                            anchors.fill: parent
                            acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
                            cursorShape: Qt.PointingHandCursor
                            onClicked: mouse => {
                                const item = trayItem.modelData;
                                const p = trayItem.mapToItem(null, 0, trayItem.height + 6);
                                if (mouse.button === Qt.MiddleButton) {
                                    item.secondaryActivate();
                                } else if (mouse.button === Qt.RightButton || item.onlyMenu) {
                                    if (item.hasMenu) item.display(bar, p.x, p.y);
                                } else {
                                    item.activate();
                                }
                            }
                        }
                    }
                }
            }

            // Network + Bluetooth: separate files, loaded on demand. If one fails to load,
            // only that icon is missing; the bar itself never breaks.
            Loader {
                source: Qt.resolvedUrl("NetIndicator.qml")
                visible: status === Loader.Ready && !!item && item.visible
                Layout.alignment: Qt.AlignVCenter
            }
            Loader {
                source: Qt.resolvedUrl("BtIndicator.qml")
                visible: status === Loader.Ready && !!item && item.visible
                Layout.alignment: Qt.AlignVCenter
            }

            // Volume — scroll to change, middle-click to mute, click for the mixer (wiremix)
            Text {
                id: volume
                readonly property var sink: Pipewire.defaultAudioSink
                readonly property bool ok: !!sink && !!sink.audio
                readonly property int pct: ok ? Math.round(sink.audio.volume * 100) : 0

                PwObjectTracker { objects: [ Pipewire.defaultAudioSink ] }

                text: !ok ? "󰖁 --"
                    : sink.audio.muted ? "󰖁 muted"
                    : (pct > 60 ? "󰕾 " : pct > 25 ? "󰖀 " : "󰕿 ") + pct + "%"
                color: ok && sink.audio.muted ? Theme.muted : Theme.fg
                font.family: Theme.font
                font.pixelSize: Theme.fontSize

                MouseArea {
                    anchors.fill: parent
                    acceptedButtons: Qt.LeftButton | Qt.MiddleButton
                    cursorShape: Qt.PointingHandCursor
                    onClicked: mouse => {
                        if (mouse.button === Qt.MiddleButton && volume.ok)
                            volume.sink.audio.muted = !volume.sink.audio.muted;
                        else
                            Quickshell.execDetached([Quickshell.env("HOME") + "/.local/bin/cachy-tui", "audio"]);
                    }
                    onWheel: wheel => {
                        if (!volume.ok) return;
                        const step = wheel.angleDelta.y > 0 ? 0.05 : -0.05;
                        volume.sink.audio.volume = Math.max(0, Math.min(1.5, volume.sink.audio.volume + step));
                    }
                }
            }

            // Battery — hidden on desktops
            Text {
                readonly property var dev: UPower.displayDevice
                readonly property bool show: !!dev && dev.isLaptopBattery
                readonly property int pct: show ? Math.round(dev.percentage * 100) : 0
                readonly property bool charging: show && dev.changeRate > 0

                visible: show
                text: (charging ? "󰂄 " : pct > 80 ? "󰁹 " : pct > 50 ? "󰂀 " : pct > 20 ? "󰁽 " : "󰂃 ") + pct + "%"
                color: !charging && pct <= 15 ? Theme.red : charging ? Theme.green : Theme.fg
                font.family: Theme.font
                font.pixelSize: Theme.fontSize
            }

            // Theme picker
            Text {
                text: "󰏘"
                color: Theme.accent
                font.family: Theme.font
                font.pixelSize: Theme.fontSize + 2

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: Ui.themePickerOpen = !Ui.themePickerOpen
                }
            }

            // Notification center
            Text {
                text: "󰂚"
                color: Theme.accent2
                font.family: Theme.font
                font.pixelSize: Theme.fontSize + 2

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: Quickshell.execDetached(["swaync-client", "-t", "-sw"])
                }
            }
        }
    }
}
