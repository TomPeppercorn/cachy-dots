pragma Singleton

// cachy-dots · live CPU, RAM and network throughput for the bar.
// Reads ~/.local/bin/cachy-stats (one line every 2 s from /proc) and turns the raw counters into
// percentages and speeds. One reader is shared by every monitor's bar.

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    property real cpu: 0          // % of all cores, 0–100
    property real memUsed: 0      // bytes in use (total − available)
    property real memPct: 0       // 0–100
    property real down: 0         // bytes per second
    property real up: 0           // bytes per second
    property var last: null       // previous sample, for the deltas

    function parse(line) {
        // cpu u n s idle iowait irq softirq steal mem total avail net rx tx
        const f = line.trim().split(/\s+/);
        if (f.length < 15 || f[0] !== "cpu" || f[9] !== "mem" || f[12] !== "net") return;

        const c = f.slice(1, 9).map(Number);
        const idle = c[3] + c[4];
        const total = c.reduce((a, b) => a + b, 0);
        const memTotal = Number(f[10]) * 1024, memAvail = Number(f[11]) * 1024;
        const rx = Number(f[13]), tx = Number(f[14]);
        const now = Date.now();

        if (root.last) {
            const dt = (now - root.last.t) / 1000;
            const dTotal = total - root.last.total;
            root.cpu = dTotal > 0 ? Math.max(0, Math.min(100, 100 * (1 - (idle - root.last.idle) / dTotal))) : 0;
            if (dt > 0) {
                // max(0, …): counters reset when an interface goes away
                root.down = Math.max(0, (rx - root.last.rx) / dt);
                root.up = Math.max(0, (tx - root.last.tx) / dt);
            }
        }
        root.memUsed = memTotal - memAvail;
        root.memPct = memTotal > 0 ? 100 * root.memUsed / memTotal : 0;
        root.last = { t: now, total: total, idle: idle, rx: rx, tx: tx };
    }

    Process {
        id: reader
        command: [Quickshell.env("HOME") + "/.local/bin/cachy-stats"]
        running: true
        stdout: SplitParser {
            onRead: data => root.parse(data)
        }
        // If the reader ever stops, start it again after a few seconds
        onExited: restart.start()
    }

    Timer {
        id: restart
        interval: 5000
        onTriggered: reader.running = true
    }
}
