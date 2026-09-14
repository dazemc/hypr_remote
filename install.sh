#!/usr/bin/env bash
set -euo pipefail
command -v wayvnc >/dev/null || { echo "hypr_remote: missing required command: wayvnc" >&2; exit 1; }
command -v hyprctl >/dev/null || { echo "hypr_remote: missing required command: hyprctl" >&2; exit 1; }
mkdir -p ~/.config/systemd/user/
mkdir -p ~/.local/bin/
WORK_DIR="$(mktemp -d)"
trap 'rm -rf "$WORK_DIR"' EXIT
cp ./hypr_remote.service "$WORK_DIR/hypr_remote.service"
sed -i "s/RESU/$USER/g" "$WORK_DIR/hypr_remote.service"
sed -i "s|GDX|$XDG_RUNTIME_DIR|g" "$WORK_DIR/hypr_remote.service"
cp "$WORK_DIR/hypr_remote.service" ~/.config/systemd/user/hypr_remote.service
cp ./hypr_remote.sh ~/.local/bin/hypr_remote.sh
systemctl --user daemon-reload
