# Hypr Remote

A simple setup to run WayVNC on a Hyprland virtual monitor, enabling remote desktop functionality on a headless display.

## Overview

This project provides scripts and a systemd service to create a virtual monitor in Hyprland, move a workspace to it, and start a WayVNC server for remote access. The setup includes:

- `hypr_remote.service`: Systemd service to manage the WayVNC process.
- `hypr_remote.sh`: Script to configure the virtual monitor and start WayVNC.
- `install.sh`: Installation script to deploy the service and script.

## Prerequisites

- Hyprland window manager
- WayVNC installed
- Systemd for service management (user scope — no sudo needed)

## Installation

1. Clone or download this repository.
2. Run the installation script:
   ```bash
   chmod +x install.sh
   ./install.sh
   ```
3. Enable and start the user service:
   ```bash
   systemctl --user enable --now hypr_remote.service
   ```

## How It Works

- **Service (`hypr_remote.service`)**: Runs `hypr_remote.sh` as a systemd *user* service (`WantedBy=graphical.target`), starting after Hyprland and the graphical target are ready. `RESU` in the template is substituted with your username at install time.
- **Script (`hypr_remote.sh`)**:
  - Removes any stale `HEADLESS-2` output, then creates a headless monitor (`HEADLESS-2`).
  - Moves workspace 10 to the virtual monitor and focuses it so the served output shows the scratch workspace.
  - Starts WayVNC on `127.0.0.1:5900` for remote access to the virtual monitor (localhost-only by default; override with `HYPR_REMOTE_BIND`).
  - Cleans up on exit by moving the workspace back and stopping WayVNC.
- **Install Script (`install.sh`)**: Copies the unit to `~/.config/systemd/user/` and the script to `~/.local/bin/`, substituting the `RESU` placeholder, then reloads the user daemon. Builds the substituted unit in a temp dir so the repo stays clean.

## Usage

After installation, the service automatically starts WayVNC on a virtual monitor, bound to localhost. Forward it over SSH and connect your VNC client to `localhost:5900`:

```bash
ssh -L 5900:localhost:5900 <your-host>
```

To expose it on the LAN instead (unencrypted — trusted networks only), set `HYPR_REMOTE_BIND=0.0.0.0` in the service environment.

## Notes

- The virtual monitor is named `HEADLESS-2`, workspace `10`, and the real monitor `HDMI-A-1` by default. Override per host without editing tracked files: `HYPR_REMOTE_MONITOR`, `HYPR_REMOTE_WORKSPACE`, `HYPR_REMOTE_REAL_MONITOR`, `HYPR_REMOTE_BIND`, `HYPR_REMOTE_PORT`.
- Ensure WayVNC and Hyprland are properly configured before running.

## License

MIT License
