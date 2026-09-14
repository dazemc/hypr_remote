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
- Systemd for service management
- Sudo privileges for installation

## Installation

1. Clone or download this repository.
2. Run the installation script:
   ```bash
   chmod +x install.sh
   ./install.sh
   ```
3. Enable and start the service:
   ```bash
   sudo systemctl enable hypr_remote.service
   sudo systemctl start hypr_remote.service
   ```

## How It Works

- **Service (`hypr_remote.service`)**: Runs `hypr_remote.sh` as a systemd service, starting after Hyprland and graphical target are ready. It uses environment variables from `/etc/hyprland_env`.
- **Script (`hypr_remote.sh`)**:
  - Checks for Hyprland environment variables (`HYPRLAND_INSTANCE_SIGNATURE`, `WAYLAND_DISPLAY`).
  - Creates a headless monitor (`HEADLESS-2`) if it doesn't exist.
  - Moves workspace 3 to the virtual monitor and focuses back to the primary monitor (`DP-2`).
  - Starts WayVNC on `127.0.0.1:5900` for remote access to the virtual monitor (localhost-only by default; override with `HYPR_REMOTE_BIND`).
  - Cleans up on exit by moving the workspace back and stopping WayVNC.
- **Install Script (`install.sh`)**: Copies files to system locations, replacing placeholders for user and runtime directory, and reloads systemd.

## Usage

After installation, the service automatically starts WayVNC on a virtual monitor, bound to localhost. Forward it over SSH and connect your VNC client to `localhost:5900`:

```bash
ssh -L 5900:localhost:5900 <your-host>
```

To expose it on the LAN instead (unencrypted — trusted networks only), set `HYPR_REMOTE_BIND=0.0.0.0` in the service environment.

## Notes

- The virtual monitor is named `HEADLESS-2`, and workspace 3 is used by default. Modify `hypr_remote.sh` to change these.
- The primary monitor is assumed to be `DP-2`. Update this in `hypr_remote.sh` if needed.
- Ensure WayVNC and Hyprland are properly configured before running.

## License

MIT License
