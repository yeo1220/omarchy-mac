#!/bin/bash
# 모니터 수에 맞춰 AeroSpace 워크스페이스 배치를 다시 씀 (모니터 연결·해제, 잠자기 해제, 바 시작 때 실행)
#  - 모니터 2대 이하: 1~5 메인, 6~9 보조 (보조가 없으면 메인)
#  - 모니터 3대 이상: 왼쪽부터 1~3 / 4~6 / 7~9 (해당 모니터가 없으면 메인)
# aerospace.toml의 [workspace-to-monitor-force-assignment] 블록(빈 줄 전까지)만 바꾸고,
# 내용이 달라졌을 때만 reload-config 합니다.
export PATH="$HOME/.local/bin:/opt/homebrew/bin:/usr/local/bin:$PATH"
command -v aerospace >/dev/null || exit 0
pgrep -x AeroSpace >/dev/null || exit 0

CONF="$HOME/.aerospace.toml"
[ -f "$CONF" ] || CONF="$HOME/.config/aerospace/aerospace.toml"
grep -q '^\[workspace-to-monitor-force-assignment\]' "$CONF" 2>/dev/null || exit 0

# 모니터를 연결한 직후에는 AeroSpace가 아직 새 모니터를 모를 수 있으므로 잠시 대기
[ "$SENDER" = display_change ] && sleep 2
MONITORS=$(aerospace list-monitors 2>/dev/null | wc -l | tr -d ' ')
[ "${MONITORS:-0}" -ge 1 ] || exit 0

BLOCK="[workspace-to-monitor-force-assignment]"
for sid in 1 2 3 4 5 6 7 8 9; do
  if [ "$MONITORS" -ge 3 ]; then
    # 숫자 = 왼쪽부터 센 모니터 순번 (aerospace list-monitors의 monitor-id와 같음)
    BLOCK+=$'\n'"$sid = [$(( (sid - 1) / 3 + 1 )), 'main']"
  elif [ "$sid" -le 5 ]; then
    BLOCK+=$'\n'"$sid = 'main'"
  else
    BLOCK+=$'\n'"$sid = ['secondary', 'main']"
  fi
done

NEW=$(BLOCK="$BLOCK" awk '
  /^\[workspace-to-monitor-force-assignment\]$/ { print ENVIRON["BLOCK"]; skip = 1; next }
  skip && /^[[:space:]]*$/ { skip = 0 }
  !skip { print }
' "$CONF")

[ "$NEW" = "$(cat "$CONF")" ] && exit 0
# 같은 파일에 덮어써서 --link 설치의 심볼릭 링크를 유지
printf '%s\n' "$NEW" > "$CONF"
aerospace reload-config
sketchybar --trigger aerospace_workspace_change
