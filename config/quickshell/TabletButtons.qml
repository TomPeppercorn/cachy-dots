// cachy-dots · tablet mode buttons (EXPERIMENTAL): rotation lock + on-screen keyboard.
// Only shown when the installer set TABLET=1 in ~/.config/cachy-dots/settings, so they're
// there to tap when the keyboard is folded away. Bar.qml loads this through a Loader.

import Quickshell
import Quickshell.Io
import QtQuick

Item {
    id: tablet
    property bool active: false
    property bool locked: false

    visible: active
    implicitWidth: row.implicitWidth
    implicitHeight: row.implicitHeight

    readonly property string home: Quickshell.env("HOME")

    FileView {
        path: tablet.home + "/.config/cachy-dots/settings"
        watchChanges: true
        onFileChanged: reload()
        onLoaded: tablet.active = /^TABLET=1\s*$/m.test(text())
    }

    // Rotation lock state: cachy-rotate creates/removes this file
    Process {
        id: lockCheck
        command: ["test", "-e", tablet.home + "/.cache/cachy-dots/rotation-locked"]
        onExited: (code, status) => tablet.locked = (code === 0)
    }
    Timer {
        interval: 2000
        running: tablet.active
        repeat: true
        triggeredOnStart: true
        onTriggered: lockCheck.running = true
    }

    Row {
        id: row
        spacing: 14

        Text {
            text: tablet.locked ? "󰑸" : "󰑵"   // md-screen_rotation_lock / md-screen_rotation
            color: tablet.locked ? Theme.accent : Theme.fg
            font.family: Theme.font
            font.pixelSize: Theme.fontSize + 3

            MouseArea {
                anchors.fill: parent
                anchors.margins: -6                            // bigger target for fingers
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    Quickshell.execDetached([tablet.home + "/.local/bin/cachy-rotate", "lock"]);
                    tablet.locked = !tablet.locked;
                }
            }
        }

        Text {
            text: "󰌌"                                 // md-keyboard
            color: Theme.fg
            font.family: Theme.font
            font.pixelSize: Theme.fontSize + 3

            MouseArea {
                anchors.fill: parent
                anchors.margins: -6
                cursorShape: Qt.PointingHandCursor
                onClicked: Quickshell.execDetached([tablet.home + "/.local/bin/cachy-osk"])
            }
        }
    }
}
