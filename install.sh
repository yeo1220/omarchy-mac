#!/bin/bash
# omarchy-mac 설치 스크립트
# https://github.com/yeo1220/omarchy-mac
#
# 사용법: ./install.sh [옵션]
#   --link           설정 파일을 복사하지 않고 이 저장소로 심볼릭 링크 (git pull로 바로 업데이트)
#   --no-aerospace   AeroSpace(타일링 창 관리자) 설치·설정을 건너뜀
#   --no-ai          AI 구독 사용량 표시용 CodexBar 설치를 건너뜀
#   --no-brew        Homebrew 패키지 설치를 건너뜀 (이미 모두 설치된 경우)
#   -h, --help       도움말
set -euo pipefail

REPO="$(cd "$(dirname "$0")" && pwd)"
STAMP="$(date +%Y%m%d-%H%M%S)"
LINK=0; AEROSPACE=1; AI=1; BREW=1

for arg in "$@"; do
  case "$arg" in
    --link) LINK=1 ;;
    --no-aerospace) AEROSPACE=0 ;;
    --no-ai) AI=0 ;;
    --no-brew) BREW=0 ;;
    -h|--help) sed -n '2,11p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) echo "알 수 없는 옵션: $arg (./install.sh --help 참고)"; exit 1 ;;
  esac
done

blue()  { printf '\033[34m==>\033[0m \033[1m%s\033[0m\n' "$*"; }
ok()    { printf '  \033[32m✓\033[0m %s\n' "$*"; }
warn()  { printf '  \033[33m!\033[0m %s\n' "$*"; }

[ "$(uname)" = "Darwin" ] || { echo "macOS 전용입니다."; exit 1; }

# 1. 패키지 설치 ----------------------------------------------------------
if [ "$BREW" = 1 ]; then
  blue "Homebrew 패키지 설치"
  command -v brew >/dev/null || { echo "Homebrew가 필요합니다: https://brew.sh"; exit 1; }

  need_formula() { command -v "$1" >/dev/null && ok "$1 이미 있음" || brew install "$2"; }
  # 두 번째 인자는 tap 경로가 필요한 cask용 (예: aerospace는 nikitabobko/tap에 있음)
  need_cask()    { brew list --cask "$1" >/dev/null 2>&1 && ok "$1 이미 있음" || brew install --cask "${2:-$1}"; }

  brew tap FelixKratz/formulae >/dev/null
  need_formula sketchybar FelixKratz/formulae/sketchybar
  need_formula borders    FelixKratz/formulae/borders
  need_formula jq         jq
  need_cask font-caskaydia-mono-nerd-font
  [ "$AEROSPACE" = 1 ] && need_cask aerospace nikitabobko/tap/aerospace
  [ "$AI" = 1 ] && need_cask codexbar
fi

command -v swiftc >/dev/null || {
  echo "Swift 컴파일러가 없습니다. 먼저 'xcode-select --install'을 실행하세요."; exit 1; }

# 2. 기존 설정 백업 -------------------------------------------------------
backup() {
  if [ -e "$1" ] || [ -L "$1" ]; then
    mv "$1" "$1.bak-$STAMP"
    ok "기존 $1 → $1.bak-$STAMP"
  fi
}

blue "기존 설정 백업"
mkdir -p "$HOME/.config"
backup "$HOME/.config/sketchybar"
if [ "$AEROSPACE" = 1 ]; then
  backup "$HOME/.aerospace.toml"
  # AeroSpace는 두 위치에 설정이 모두 있으면 오류를 내므로 함께 백업
  backup "$HOME/.config/aerospace/aerospace.toml"
fi

# 3. 설정 설치 ------------------------------------------------------------
blue "설정 설치 ($([ "$LINK" = 1 ] && echo 심볼릭 링크 || echo 복사))"
if [ "$LINK" = 1 ]; then
  ln -s "$REPO/sketchybar" "$HOME/.config/sketchybar"
  [ "$AEROSPACE" = 1 ] && ln -s "$REPO/aerospace/aerospace.toml" "$HOME/.aerospace.toml"
else
  cp -R "$REPO/sketchybar" "$HOME/.config/sketchybar"
  [ "$AEROSPACE" = 1 ] && cp "$REPO/aerospace/aerospace.toml" "$HOME/.aerospace.toml"
fi
chmod +x "$HOME/.config/sketchybar/sketchybarrc" "$HOME/.config/sketchybar/plugins/"*.sh
ok "~/.config/sketchybar"
[ "$AEROSPACE" = 1 ] && ok "~/.aerospace.toml"

blue "메뉴바 전환 헬퍼 빌드"
swiftc -O "$HOME/.config/sketchybar/helpers/menubar_swap.swift" \
       -o "$HOME/.config/sketchybar/helpers/menubar_swap"
ok "helpers/menubar_swap"

# 4. macOS 메뉴바 자동 숨김 -------------------------------------------------
blue "macOS 메뉴바 자동 숨김 켜기"
# 꺼졌다 다시 켜야 메인 모니터 메뉴바가 확실히 숨겨짐
osascript -e 'tell application "System Events" to set autohide menu bar of dock preferences to false' >/dev/null
osascript -e 'tell application "System Events" to set autohide menu bar of dock preferences to true' >/dev/null
ok "메뉴바는 화면 맨 위에 마우스를 잠시 대면 나타납니다"

# 5. 실행 ----------------------------------------------------------------
blue "실행"
if brew services list 2>/dev/null | grep -q '^sketchybar'; then
  brew services restart sketchybar >/dev/null && ok "sketchybar (brew services, 로그인 시 자동 실행)"
elif pgrep -x sketchybar >/dev/null; then
  sketchybar --reload && ok "sketchybar 설정 다시 불러옴"
else
  brew services start sketchybar >/dev/null 2>&1 && ok "sketchybar (brew services)" || {
    nohup sketchybar >/dev/null 2>&1 & ok "sketchybar"; }
fi

if [ "$AEROSPACE" = 1 ]; then
  if pgrep -x AeroSpace >/dev/null; then
    aerospace reload-config && ok "AeroSpace 설정 다시 불러옴"
  else
    open -a AeroSpace && ok "AeroSpace 실행 (처음이면 손쉬운 사용 권한을 허용하세요)"
  fi
fi

if [ "$AI" = 1 ] && [ -d /Applications/CodexBar.app ]; then
  pgrep -x CodexBar >/dev/null || open -a CodexBar
fi

cat <<EOF

$(printf '\033[1m설치 완료!\033[0m')

다음 단계
  1. AeroSpace를 처음 실행했다면
     시스템 설정 → 개인정보 보호 및 보안 → 손쉬운 사용에서 AeroSpace를 허용하세요.
  2. AI 사용량을 보려면 CodexBar 앱 설정에서 Claude · Codex · Cursor 계정을 연결하세요.
     연결 전에는 바에 '?'가 표시됩니다.
  3. 단축키와 사용법은 README.md를 참고하세요.

되돌리기: ./uninstall.sh (백업해 둔 설정을 복원합니다)
EOF
