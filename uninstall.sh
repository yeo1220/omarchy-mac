#!/bin/bash
# omarchy-mac 제거 스크립트
# 설치한 설정을 지우고, install.sh가 만든 가장 최근 백업(*.bak-날짜)을 되돌립니다.
# Homebrew 패키지는 지우지 않습니다 (맨 아래 안내 참고).
set -uo pipefail

ok() { printf '  \033[32m✓\033[0m %s\n' "$*"; }
REMOVED=0

restore() {
  local target="$1" latest
  latest=$(ls -d "$target".bak-* 2>/dev/null | sort | tail -1)
  if [ -e "$target" ] || [ -L "$target" ]; then
    rm -rf "$target"; ok "삭제: $target"; REMOVED=1
  fi
  if [ -n "$latest" ]; then
    mv "$latest" "$target"; ok "복원: $latest → $target"
  fi
}

pkill -f "$HOME/.config/sketchybar/helpers/menubar_swap" 2>/dev/null
restore "$HOME/.config/sketchybar"
restore "$HOME/.aerospace.toml"
restore "$HOME/.config/aerospace/aerospace.toml"

# 복원된 설정이 있으면 다시 불러오고, 없으면 SketchyBar를 끔
if [ "$REMOVED" = 0 ]; then
  echo "설치된 omarchy-mac 설정이 없습니다."
elif [ -f "$HOME/.config/sketchybar/sketchybarrc" ]; then
  sketchybar --reload 2>/dev/null && ok "sketchybar 이전 설정 다시 불러옴"
else
  brew services stop sketchybar >/dev/null 2>&1; pkill -x sketchybar 2>/dev/null
  osascript -e 'tell application "System Events" to set autohide menu bar of dock preferences to false' >/dev/null
  ok "sketchybar 중지, macOS 메뉴바 항상 표시로 되돌림"
fi
pgrep -x AeroSpace >/dev/null && aerospace reload-config 2>/dev/null

cat <<'EOF'

제거 완료.
패키지까지 지우려면:
  brew uninstall sketchybar borders
  brew uninstall --cask aerospace codexbar font-caskaydia-mono-nerd-font
EOF
