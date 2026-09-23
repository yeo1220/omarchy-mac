// 마우스가 화면 맨 위에 잠시 머물면 SketchyBar를 숨겨 macOS 메뉴바를 쓰게 하고,
// 커서가 내려가고 열린 메뉴가 없으면 다시 보여준다.
import CoreGraphics
import Foundation

// sketchybar 실행 파일 위치 (Homebrew Apple Silicon / Intel / 직접 설치)
let sketchybar = [
  "/opt/homebrew/bin/sketchybar",
  "/usr/local/bin/sketchybar",
  NSHomeDirectory() + "/.local/bin/sketchybar",
].first { FileManager.default.isExecutableFile(atPath: $0) } ?? "sketchybar"
let revealEdge: CGFloat = 2      // 이 높이(px) 안으로 들어오면 메뉴바 모드
let restoreBelow: CGFloat = 44   // 이 아래로 내려가면 SketchyBar 복귀
let dwell: TimeInterval = 0.6    // 맨 위에 이만큼 머물러야 전환 (SketchyBar 항목을 가리키다 스친 경우 무시)
let popUpMenuLevel = Int(CGWindowLevelForKey(.popUpMenuWindow))

func setHidden(_ hidden: Bool) {
  let p = Process()
  p.executableURL = URL(fileURLWithPath: sketchybar)
  p.arguments = ["--bar", "hidden=\(hidden ? "on" : "off")"]
  try? p.run()
  p.waitUntilExit()
}

// 커서가 있는 디스플레이의 위쪽 끝에서 얼마나 떨어져 있는지
func distanceFromTop(_ pt: CGPoint) -> CGFloat? {
  var ids = [CGDirectDisplayID](repeating: 0, count: 8)
  var n: UInt32 = 0
  CGGetDisplaysWithPoint(pt, 8, &ids, &n)
  guard n > 0 else { return nil }
  return pt.y - CGDisplayBounds(ids[0]).minY
}

// 메뉴바 메뉴 등 팝업 메뉴가 열려 있는지
// (sketchybar 팝업 창도 같은 레벨이고 숨겨진 상태로 화면 밖에 늘 떠 있으므로 제외)
func menuOpen() -> Bool {
  guard let l = CGWindowListCopyWindowInfo([.optionOnScreenOnly], kCGNullWindowID) as? [[String: Any]] else { return false }
  return l.contains {
    ($0[kCGWindowLayer as String] as? Int) == popUpMenuLevel
      && ($0[kCGWindowOwnerName as String] as? String) != "sketchybar"
  }
}

// SketchyBar 팝업(바 아래쪽에 뜨는 sketchybar 창)이 열려 있는지
func sketchybarPopupOpen() -> Bool {
  guard let l = CGWindowListCopyWindowInfo([.optionOnScreenOnly], kCGNullWindowID) as? [[String: Any]] else { return false }
  return l.contains {
    guard ($0[kCGWindowOwnerName as String] as? String) == "sketchybar",
          let b = $0[kCGWindowBounds as String] as? [String: Any],
          let y = b["Y"] as? CGFloat, let pt = CGEvent(source: nil)?.location else { return false }
    var ids = [CGDirectDisplayID](repeating: 0, count: 8)
    var n: UInt32 = 0
    CGGetDisplaysWithPoint(pt, 8, &ids, &n)
    return n > 0 && y - CGDisplayBounds(ids[0]).minY > 10
  }
}

var hidden = false
var atTopSince: Date? = nil
setHidden(false)
while true {
  if let pt = CGEvent(source: nil)?.location, let d = distanceFromTop(pt) {
    if !hidden && d <= revealEdge {
      if atTopSince == nil { atTopSince = Date() }
      if Date().timeIntervalSince(atTopSince!) >= dwell && !sketchybarPopupOpen() {
        hidden = true; atTopSince = nil; setHidden(true)
      }
    } else if !hidden {
      atTopSince = nil
    } else if hidden && d > restoreBelow && !menuOpen() {
      hidden = false; setHidden(false)
    }
  }
  usleep(hidden ? 150_000 : 100_000)
}
