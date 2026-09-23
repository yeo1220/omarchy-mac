#!/bin/bash
P=$(pmset -g batt | grep -Eo "[0-9]+%" | tr -d %)
[ -z "$P" ] && exit 0
if pmset -g batt | grep -q "AC Power"; then ICON="󰂄"
elif [ "$P" -gt 80 ]; then ICON="󰁹"
elif [ "$P" -gt 50 ]; then ICON="󰁾"
elif [ "$P" -gt 20 ]; then ICON="󰁼"
else ICON="󰂃"; fi
sketchybar --set $NAME icon="$ICON" label="${P}%"
