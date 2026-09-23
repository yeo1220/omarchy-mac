#!/bin/bash
CORES=$(sysctl -n hw.ncpu)
U=$(ps -A -o %cpu= | awk -v c="$CORES" '{s+=$1} END {printf "%d", s/c}')
sketchybar --set $NAME label="${U}%"
