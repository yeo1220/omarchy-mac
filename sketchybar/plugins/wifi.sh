#!/bin/bash
IF=$(networksetup -listallhardwareports | awk '/Wi-Fi/{getline; print $2}')
if ipconfig getifaddr "$IF" >/dev/null 2>&1; then ICON="󰖩"
elif ipconfig getifaddr en0 >/dev/null 2>&1 || route -n get default >/dev/null 2>&1; then ICON="󰈀"
else ICON="󰖪"; fi
sketchybar --set $NAME icon="$ICON" label.drawing=off
