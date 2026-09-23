#!/bin/bash
V="${INFO:-$(osascript -e 'output volume of (get volume settings)')}"
if [ "$V" = "missing value" ] || [ -z "$V" ]; then V=0; fi
if [ "$V" -eq 0 ]; then ICON="󰝟"; elif [ "$V" -lt 50 ]; then ICON="󰖀"; else ICON="󰕾"; fi
sketchybar --set $NAME icon="$ICON" label="${V}%"
