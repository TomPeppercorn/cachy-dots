// cachy-dots · power menu (Ctrl+Alt+Delete)
// A centered row of buttons: lock, log out, suspend, restart, shut down. Themed by cachy-theme.
// Esc or a click outside closes it; ← → to move, Enter to pick, or 1–5. Mirrors ThemePicker.

import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts

PanelWindow {
    id: menu

    visible: Ui.powerMenuOpen
    color: "transparent"

    screen: {
        const m = Hyprland.focusedMonitor;
        const all = Quickshell.screens;
        for (let i = 0; i < all.length; i++)
            if (m && all[i].name === m.name) return all[i];
        return all[0];
    }

    anchors { top: true; bottom: true; left: true; right: true }
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
    WlrLayershell.namespace: "cachy-power-menu"

    property int selected: 0

    // icon, label, the command to run, and whether it's a destructive action (tinted red)
    readonly property var actions: [
        { icon: "󰌾", label: "Lock",      cmd: ["loginctl", "lock-session"],  danger: false },
        { icon: "󰍃", label: "Log out",   cmd: ["sh", "-c", "command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch 'hl.dsp.exit()'"], danger: false },
        { icon: "󰤄", label: "Suspend",   cmd: ["systemctl", "suspend"],      danger: false },
        { icon: "󰜉", label: "Restart",   cmd: ["systemctl", "reboot"],       danger: true },
        { icon: "󰐥", label: "Shut down", cmd: ["systemctl", "poweroff"],     danger: true }
    ]

    function activate(i) {
        Quickshell.execDetached(menu.actions[i].cmd);
        Ui.powerMenuOpen = false;
    }
    function close() { Ui.powerMenuOpen = false; }

    onVisibleChanged: {
        if (visible) {
            selected = 0;
            card.forceActiveFocus();
        }
    }

    // Dimmed backdrop — click to close
    Rectangle {
        anchors.fill: parent
        color: "#000000"
        opacity: 0.4
        MouseArea { anchors.fill: parent; onClicked: menu.close() }
    }

    Rectangle {
        id: card
        anchors.centerIn: parent
        width: content.implicitWidth + 48
        height: content.implicitHeight + 40
        radius: 18
        color: Theme.surface
        border.color: Theme.border
        border.width: 1
        focus: true

        Keys.onEscapePressed: menu.close()
        Keys.onLeftPressed:  menu.selected = (menu.selected + menu.actions.length - 1) % menu.actions.length
        Keys.onRightPressed: menu.selected = (menu.selected + 1) % menu.actions.length
        Keys.onReturnPressed: menu.activate(menu.selected)
        Keys.onEnterPressed:  menu.activate(menu.selected)
        Keys.onPressed: (e) => {
            if (e.key >= Qt.Key_1 && e.key <= Qt.Key_5) {
                const i = e.key - Qt.Key_1;
                if (i < menu.actions.length) menu.activate(i);
            }
        }

        // Swallow clicks so they don't reach the backdrop
        MouseArea { anchors.fill: parent }

        ColumnLayout {
            id: content
            anchors.centerIn: parent
            spacing: 16

            RowLayout {
                id: buttons
                spacing: 14

                Repeater {
                    model: menu.actions

                    Rectangle {
                        id: btn
                        required property int index
                        required property var modelData
                        readonly property bool hot: hover.containsMouse || menu.selected === index
                        readonly property color tint: modelData.danger ? Theme.red : Theme.accent

                        implicitWidth: 104
                        implicitHeight: 104
                        radius: 12
                        color: hot ? Qt.rgba(tint.r, tint.g, tint.b, 0.16) : Theme.overlay
                        border.width: hot ? 2 : 1
                        border.color: hot ? tint : Theme.border

                        Column {
                            anchors.centerIn: parent
                            spacing: 10

                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: btn.modelData.icon
                                color: btn.hot ? btn.tint : Theme.fg
                                font.family: Theme.font
                                font.pixelSize: 34
                            }
                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: btn.modelData.label
                                color: btn.hot ? Theme.fg : Theme.muted
                                font.family: Theme.uiFont
                                font.pixelSize: 13
                            }
                        }

                        MouseArea {
                            id: hover
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onEntered: menu.selected = btn.index
                            onClicked: menu.activate(btn.index)
                        }
                    }
                }
            }

            Text {
                Layout.alignment: Qt.AlignHCenter
                text: "←  →  to move · Enter to pick · Esc to close"
                color: Theme.muted
                font.family: Theme.uiFont
                font.pixelSize: 11
            }
        }
    }
}
