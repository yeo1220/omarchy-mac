#!/bin/bash
sketchybar --set $NAME label="$(LC_TIME=ko_KR.UTF-8 date '+%-m월 %-d일 (%a)  %H:%M')"
