// cachy-dots · Bluetooth indicator: off / on / connected (with a count). Click opens bluetui.
// Hidden when the machine has no Bluetooth adapter. Bar.qml loads this through a Loader, so if
// Quickshell.Bluetooth were ever unavailable, only this icon disappears.

import Quickshell
import Quickshell.Bluetooth
import QtQuick

Text {
    readonly property var adapter: Bluetooth.defaultAdapter
    readonly property int connected: {
        if (!adapter) return 0;
        const ds = adapter.devices.values;
        let n = 0;
        for (let i = 0; i < ds.length; i++)
            if (ds[i].connected) n++;
        return n;
    }

    visible: !!adapter
    text: !adapter ? ""
        : !adapter.enabled ? "󰂲"
        : connected === 0 ? "󰂯"
        : connected === 1 ? "󰂱" : "󰂱 " + connected
    color: adapter && adapter.enabled ? Theme.fg : Theme.muted
    font.family: Theme.font
    font.pixelSize: Theme.fontSize + 1

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: Quickshell.execDetached([Quickshell.env("HOME") + "/.local/bin/cachy-tui", "bluetooth"])
    }
}
