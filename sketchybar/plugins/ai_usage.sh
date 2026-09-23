#!/bin/bash
# CodexBar CLI로 Claude · Codex · Cursor 구독 사용량을 가져와 표시
# 막대: 사용률 + 초기화까지 남은 시간 (Claude/Codex: 5시간창·주간, Cursor: 월간·서드파티, ↺N = Codex 재설정 크레딧)
# 팝업: 플랜 이름 + 세부 한도 전체 / 색상은 사용률 기준 (막대는 가장 높은 값)
export PATH="$HOME/.local/bin:/opt/homebrew/bin:/usr/local/bin:$PATH"
GREEN=0xff9ece6a; YELLOW=0xffe0af68; RED=0xfff7768e; DIM=0xff565f89; FG=0xffc0caf5

color() { # 사용률 → 색상
  if [ "$1" -ge 80 ]; then echo $RED; elif [ "$1" -ge 50 ]; then echo $YELLOW; else echo $GREEN; fi
}

# sketchybarrc가 만든 ai.<서비스> 항목 목록 (AI_PROVIDERS 설정을 따름)
PROVIDERS=$(sketchybar --query bar | jq -r '.items[] | select(test("^ai\\.[a-z0-9-]+$")) | sub("^ai\\."; "")')
[ -z "$PROVIDERS" ] && exit 0

TMP=$(mktemp -d)
for p in $PROVIDERS; do
  codexbar usage --provider "$p" --json --no-credits >"$TMP/$p.json" 2>/dev/null &
done
wait

# 출력 1행: "최대사용률<TAB>막대 라벨"
#      2행: "플랜 이름"
#      3행~: "제목<TAB>사용률<TAB>값" (세부 한도, 사용률 -1은 색상 없음)
JQ='
def left($t): ($t | sub("\\.[0-9]+Z$"; "Z") | fromdateiso8601) - now
  | if . <= 0 then "0m"
    elif . >= 86400 then "\(. / 86400 | floor)d\(. % 86400 / 3600 | floor)h"
    elif . >= 3600 then "\(. / 3600 | floor)h\(. % 3600 / 60 | floor)m"
    else "\(. / 60 | floor)m" end;
def pct: .usedPercent | floor | tostring + "%";
def win: if . == null then empty else "\(pct) \(left(.resetsAt))" end;
def row($title): if . == null then empty
  else "\($title)\t\(.usedPercent | floor)\t\(pct | .[0:4] | . + " " * (5 - length))\(left(.resetsAt)) 후 초기화" end;
.[0] as $r | $r.usage as $u
| ($r.codexResetCredits // $u.codexResetCredits // {availableCount: 0}) as $rc
| ({claude: ["5시간", "주간", "주간(추가)"],
    codex:  ["5시간", "주간", "추가"],
    cursor: ["전체", "Cursor 모델", "서드파티"]}[$p] // ["기본", "2차", "3차"]) as $t
| [$u.primary, $u.secondary, $u.tertiary | select(. != null) | .usedPercent] as $all
| (if $p == "cursor" then
     [($u.primary | pct), ($u.tertiary // empty | "3P " + pct)] | join("·")
     + " " + left($u.primary.resetsAt)
   else
     [$u.primary, $u.secondary | win] | join("·")
   end
   + (if $rc.availableCount > 0 then " ↺\($rc.availableCount)" else "" end)) as $bar
| "\($all | max | floor)\t\($bar)",
  ($u.loginMethod // "?" | if $p == "codex"
     then "ChatGPT " + ({prolite: "Pro Lite", pro: "Pro", plus: "Plus", team: "Team"}[.] // .)
     else . end),
  ($u.primary | row($t[0])), ($u.secondary | row($t[1])), ($u.tertiary | row($t[2]))
'
# extraRateWindows는 제목이 제각각이라 별도 처리
JQX='
def left($t): ($t | sub("\\.[0-9]+Z$"; "Z") | fromdateiso8601) - now
  | if . <= 0 then "0m"
    elif . >= 86400 then "\(. / 86400 | floor)d\(. % 86400 / 3600 | floor)h"
    elif . >= 3600 then "\(. / 3600 | floor)h\(. % 3600 / 60 | floor)m"
    else "\(. / 60 | floor)m" end;
.[0] as $r
| ($r.usage.extraRateWindows // [])[]
| (.title | sub(" only$"; " 전용")) as $title | .window
| "\($title)\t\(.usedPercent | floor)\t\(.usedPercent | floor | tostring + "%" | . + " " * (5 - length))\(left(.resetsAt)) 후 초기화"
'
# Codex 재설정 크레딧 행
JQC='
.[0] as $r | ($r.codexResetCredits // $r.usage.codexResetCredits // {availableCount: 0})
| select(.availableCount > 0)
| ([.credits[]? | select(.status == "available") | .expires_at] | min) as $exp
| "재설정 크레딧\t-1\t\(.availableCount)회 남음"
  + (if $exp then " · \($exp | sub("\\.[0-9]+Z$"; "Z") | fromdateiso8601 | strflocaltime("%-m/%-d")) 만료" else "" end)
'

for p in $PROVIDERS; do
  F="$TMP/$p.json"
  MAIN=$(jq -r --arg p "$p" "$JQ" "$F" 2>/dev/null )
  if [ -z "$MAIN" ]; then
    sketchybar --set "ai.$p" label="?" label.color=$DIM
    continue
  fi
  FIRST=$(sed -n 1p <<<"$MAIN"); PLAN=$(sed -n 2p <<<"$MAIN")
  MAX=${FIRST%%$'\t'*}
  ARGS=(--set "ai.$p" label="${FIRST#*$'\t'}" label.color="$(color "$MAX")"
        --set "ai.$p.r0" drawing=on icon="$PLAN" icon.color=$FG icon.width=dynamic label.drawing=off)
  i=1
  while IFS=$'\t' read -r TITLE PCT VAL; do
    [ -z "$TITLE" ] && continue
    [ "$i" -gt 6 ] && break
    C=$FG; [ "$PCT" -ge 0 ] && C=$(color "$PCT")
    ARGS+=(--set "ai.$p.r$i" drawing=on icon="$TITLE" label="$VAL" label.color="$C")
    i=$((i + 1))
  done < <(sed -n '3,$p' <<<"$MAIN"; jq -r "$JQX" "$F" 2>/dev/null; jq -r "$JQC" "$F" 2>/dev/null)
  while [ "$i" -le 6 ]; do ARGS+=(--set "ai.$p.r$i" drawing=off); i=$((i + 1)); done
  sketchybar "${ARGS[@]}"
done
rm -rf "$TMP"
