#!/bin/bash
# AI 사용량 항목 클릭 → 팝업 토글 + 즉시 갱신 / 마우스가 벗어나면 닫기
case "$SENDER" in
  mouse.clicked)
    # 다른 AI 항목의 팝업은 닫기
    for item in $(sketchybar --query bar | jq -r '.items[] | select(test("^ai\\.[a-z0-9-]+$"))'); do
      [ "$item" != "$NAME" ] && sketchybar --set "$item" popup.drawing=off
    done
    sketchybar --set "$NAME" popup.drawing=toggle --trigger ai_usage_refresh ;;
  mouse.exited.global)
    sketchybar --set "$NAME" popup.drawing=off ;;
esac
