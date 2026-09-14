#!/usr/bin/env bash
set -euo pipefail

VIRTUAL_MONITOR="${HYPR_REMOTE_MONITOR:-HEADLESS-2}"
VIRTUAL_WORKSPACE="${HYPR_REMOTE_WORKSPACE:-10}"
REAL_MONITOR="${HYPR_REMOTE_REAL_MONITOR:-HDMI-A-1}"
VNC_BIND="${HYPR_REMOTE_BIND:-0.0.0.0}"
VNC_PORT="${HYPR_REMOTE_PORT:-5900}"

WAYVNC_PID=""
STARTED=0

cleanup() {
  [[ "$STARTED" -eq 1 ]] || return 0
  STARTED=0
  if [[ -n "$WAYVNC_PID" ]] && kill -0 "$WAYVNC_PID" 2>/dev/null; then
    kill "$WAYVNC_PID" 2>/dev/null || true
  fi
  hyprctl dispatch moveworkspacetomonitor "$VIRTUAL_WORKSPACE" "$REAL_MONITOR"
  hyprctl dispatch focusmonitor "$REAL_MONITOR"
}

trap cleanup INT TERM EXIT

main() {
  hyprctl output remove "$VIRTUAL_MONITOR" 2>/dev/null || true
  sleep 0.2
  hyprctl output create headless "$VIRTUAL_MONITOR"
  sleep 0.5

  hyprctl dispatch workspace "$VIRTUAL_WORKSPACE"
  hyprctl dispatch moveworkspacetomonitor "$VIRTUAL_WORKSPACE" "$VIRTUAL_MONITOR"
  sleep 0.2

  hyprctl dispatch focusmonitor "$VIRTUAL_MONITOR"

  wayvnc "$VNC_BIND" "$VNC_PORT" "$VIRTUAL_MONITOR" &
  WAYVNC_PID=$!
  STARTED=1
  wait "$WAYVNC_PID"
}

main
