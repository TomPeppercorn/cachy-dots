// cachy-dots · bar readouts: CPU %, RAM in use, download / upload speed. Click opens btop.
// Bar.qml loads this through a Loader, so if anything here fails only these readouts disappear.

import Quickshell
import QtQuick

Item {
    id: stats
    implicitWidth: row.implicitWidth
    implicitHeight: row.implicitHeight

    // Fixed-width numbers so the bar doesn't jiggle as values change
    function pad(s, n) { return s.length >= n ? s : " ".repeat(n - s.length) + s; }
    function speed(b) {
        if (b < 1024 * 1024) return pad(Math.round(b / 1024) + "K", 5);
        if (b < 1024 * 1024 * 1024) return pad((b / 1048576).toFixed(1) + "M", 5);
        return pad((b / 1073741824).toFixed(1) + "G", 5);
    }
    function load(pct) { return pct >= 85 ? Theme.red : pct >= 60 ? Theme.yellow : Theme.fg; }

    Row {
        id: row
        spacing: 12

        Text {
            text: "󰻠 " + stats.pad(Math.round(Stats.cpu) + "%", 4)
            color: stats.load(Stats.cpu)
            font.family: Theme.font
            font.pixelSize: Theme.fontSize
        }

        Text {
            text: "󰍛 " + (Stats.memUsed / 1073741824).toFixed(1) + "G"
            color: stats.load(Stats.memPct)
            font.family: Theme.font
            font.pixelSize: Theme.fontSize
        }

        Text {
            text: "󰇚" + stats.speed(Stats.down) + "  󰕒" + stats.speed(Stats.up)
            color: Theme.muted
            font.family: Theme.font
            font.pixelSize: Theme.fontSize
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: Quickshell.execDetached([Quickshell.env("HOME") + "/.local/bin/cachy-tui", "monitor"])
    }
}
