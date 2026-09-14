# Hypr Remote service

How the virtual monitor, WayVNC, and the user service fit together. Derived
from `AGENTS.md`; on a conflict the constitution wins.

```text
hypr_remote.sh          lifecycle: create output, place workspace, serve, clean up
  hyprctl output create headless HEADLESS-2
  move workspace 10 onto HEADLESS-2
  wayvnc 0.0.0.0 5900 HEADLESS-2        (foreground; blocks until killed)
  on INT/TERM/EXIT: pkill wayvnc, move workspace 10 back to HDMI-A-1

hypr_remote.service     user unit: WantedBy=graphical.target,
                        After=hyprland.service graphical.target,
                        ExecStart=%h/.local/bin/hypr_remote.sh,
                        User=RESU placeholder

install.sh              deploy: substitute RESU/GDX from live env,
                        copy unit -> ~/.config/systemd/user/,
                        copy script -> ~/.local/bin/,
                        systemctl --user daemon-reload
```

## Current values

- Virtual monitor: `HEADLESS-2` (created via `hyprctl output create
  headless`; a stale same-name output is removed first).
- Scratch workspace: `10` (moved onto the headless output on start, back
  onto the real monitor on exit).
- Real monitor: `HDMI-A-1` (cleanup target; where the local session keeps
  working while the remote client uses the headless output).
- VNC endpoint: `0.0.0.0:5900` against `HEADLESS-2`.

When monitor or workspace names change in the script, the service and
installer need no change unless a path or placeholder moves — but this file
must be updated in the same step (its own commit on `master`).

## Lifecycle notes

- `wayvnc` runs in the foreground as the unit's main process; stopping the
  unit (or a TERM/INT) fires the trap, which kills `wayvnc` and returns the
  workspace to the real monitor.
- The script focuses the headless monitor before starting `wayvnc` so the
  served output has the scratch workspace visible.
- WayVNC is a prerequisite binary, not part of this repo. Empty/missing
  output or a dead workspace at serve time means the remote client sees
  nothing — reason through the `hyprctl` ordering dry before changing it.
