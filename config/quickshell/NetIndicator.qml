// cachy-dots · network indicator: Wi-Fi strength or Ethernet. Click opens wlctl.
// Bar.qml loads this through a Loader, so if Quickshell.Networking were ever unavailable,
// only this icon disappears; the rest of the bar keeps working.

import Quickshell
import Quickshell.Networking
import QtQuick

Text {
    id: net

    readonly property var devices: Networking.devices.values

    // A connected cable wins; otherwise show the Wi-Fi device
    readonly property var wired: {
        for (let i = 0; i < devices.length; i++)
            if (devices[i].type === DeviceType.Wired && devices[i].connected) return devices[i];
        return null;
    }
    readonly property var wifi: {
        for (let i = 0; i < devices.length; i++)
            if (devices[i].type === DeviceType.Wifi) return devices[i];
        return null;
    }
    readonly property var wifiNet: {
        if (!wifi) return null;
        const nets = wifi.networks.values;
        for (let i = 0; i < nets.length; i++)
            if (nets[i].connected) return nets[i];
        return null;
    }
    readonly property real strength: wifiNet ? wifiNet.signalStrength : 0   // 0–1

    visible: !!wired || !!wifi
    text: wired ? "󰈀"
        : !Networking.wifiEnabled ? "󰤮"
        : !wifiNet ? "󰤯"
        : strength > 0.75 ? "󰤨" : strength > 0.5 ? "󰤥" : strength > 0.25 ? "󰤢" : "󰤟"
    color: (wired || wifiNet) ? Theme.fg : Theme.muted
    font.family: Theme.font
    font.pixelSize: Theme.fontSize + 1

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: Quickshell.execDetached([Quickshell.env("HOME") + "/.local/bin/cachy-tui", "wifi"])
    }
}
