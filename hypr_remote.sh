#!/usr/bin/env bash

VIRTUAL_MONITOR="HEADLESS-2"
VIRTUAL_WORKSPACE=10
REAL_MONITOR="HDMI-A-1"

cleanup() {
  pkill wayvnc
  hyprctl dispatch moveworkspacetomonitor "$VIRTUAL_WORKSPACE" "$REAL_MONITOR"
  hyprctl dispatch focusmonitor "$REAL_MONITOR"
}

trap cleanup INT TERM EXIT

main() {
  hyprctl output remove "$VIRTUAL_MONITOR" 2>/dev/null
  sleep 0.2
  hyprctl output create headless "$VIRTUAL_MONITOR"
  sleep 0.5

  hyprctl dispatch workspace "$VIRTUAL_WORKSPACE"
  hyprctl dispatch moveworkspacetomonitor "$VIRTUAL_WORKSPACE" "$VIRTUAL_MONITOR"
  sleep 0.2

  hyprctl dispatch focusmonitor "$VIRTUAL_MONITOR"

  wayvnc 0.0.0.0 5900 "$VIRTUAL_MONITOR"
}

main
