#!/bin/bash
# 워크스페이스 1~9 표시를 한 번에 갱신 (aerospace 호출 2번 + sketchybar 호출 1번)
#  - 포커스된 워크스페이스: 파란 배경
#  - 다른 모니터에 보이는 워크스페이스: 어두운 배경
#  - 창이 있는 워크스페이스: 글자만
#  - 빈 워크스페이스: 숨김
FOCUSED="${FOCUSED_WORKSPACE:-$(aerospace list-workspaces --focused)}"
VISIBLE=" $(aerospace list-workspaces --monitor all --visible | tr '\n' ' ') "
NONEMPTY=" $(aerospace list-workspaces --monitor all --empty no | tr '\n' ' ') "

ARGS=()
for sid in 1 2 3 4 5 6 7 8 9; do
  if [ "$sid" = "$FOCUSED" ]; then
    ARGS+=(--set space.$sid drawing=on background.drawing=on background.color=0xff7aa2f7 icon.color=0xff1a1b26)
  elif [[ "$VISIBLE" == *" $sid "* ]]; then
    ARGS+=(--set space.$sid drawing=on background.drawing=on background.color=0xff3b4261 icon.color=0xffc0caf5)
  elif [[ "$NONEMPTY" == *" $sid "* ]]; then
    ARGS+=(--set space.$sid drawing=on background.drawing=off icon.color=0xffc0caf5)
  else
    ARGS+=(--set space.$sid drawing=off)
  fi
done
sketchybar "${ARGS[@]}"
