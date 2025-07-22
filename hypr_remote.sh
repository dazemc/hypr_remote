#!/usr/bin/env bash

get_var_from_proc() {
  local proc_name="$1"
  local var_name="$2"

  for pid in $(pgrep -u "$USER" "$proc_name"); do
    val=$(tr '\0' '\n' < /proc/$pid/environ 2>/dev/null | grep "^$var_name=" | cut -d= -f2-)
    if [[ -n "$val" ]]; then
      echo "$val"
      return 0
    fi
  done

  return 1
}

if [[ -z "$HYPRLAND_INSTANCE_SIGNATURE" || -z "$WAYLAND_DISPLAY" ]]; then
  echo "[ERROR] Missing Hyprland environment variables."
  exit 1
fi

sudo sh -c "
echo "HYPRLAND_INSTANCE_SIGNATURE=$HYPRLAND_INSTANCE_SIGNATURE" > /etc/hyprland_env;
echo "WAYLAND_DISPLAY=$WAYLAND_DISPLAY" >> /etc/hyprland_env;
"

VIRTUAL_MONITOR="HEADLESS-2"
VIRTUAL_WORKSPACE=3
REAL_MONITOR="DP-2"

cleanup() {
  hyprctl dispatch moveworkspacetomonitor "$VIRTUAL_WORKSPACE" "$REAL_MONITOR"
  hyprctl dispatch focusmonitor "$REAL_MONITOR"
  pkill wayvnc
  exit 0
}

trap cleanup INT TERM EXIT

if ! hyprctl monitors | grep -q "$VIRTUAL_MONITOR"; then
  echo "[wayvnc] Creating $VIRTUAL_MONITOR dynamically..."
  hyprctl output create headless
  sleep 0.5
fi

echo "Workspace $VIRTUAL_WORKSPACE to $VIRTUAL_MONITOR..."
hyprctl dispatch moveworkspacetomonitor "$VIRTUAL_WORKSPACE" "$VIRTUAL_MONITOR"
sleep 0.2
hyprctl dispatch workspace "$VIRTUAL_WORKSPACE"
sleep 0.2

hyprctl dispatch focusmonitor "$REAL_MONITOR"

echo "Started WayVNC on $VIRTUAL_MONITOR..."
wayvnc 0.0.0.0 5900 "$VIRTUAL_MONITOR"

