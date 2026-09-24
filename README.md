# omarchy-mac

**macOS를 [Omarchy](https://omarchy.org) 스타일로 쓰기 위한 상단 바 + 타일링 설정 모음**

Omarchy(DHH가 만든 Arch Linux + Hyprland 배포판)의 깔끔한 Waybar와 키보드 중심 창 관리를 Mac에서
비슷하게 쓸 수 있도록 [SketchyBar](https://github.com/FelixKratz/SketchyBar)와
[AeroSpace](https://github.com/nikitabobko/AeroSpace) 설정을 묶었습니다. 여기에 요즘 개발자에게
필요한 **AI 코딩 도구 구독 사용량(Claude · Codex · Cursor)** 표시를 더했습니다.

[English README](README.en.md)

```
┌───────────────────────────────────────────────────────────────────────────────────────────────────────────┐
│ 1 2 3  Ghostty            9월 23일 (화)  10:12          Claude 17% 26m·40% 4d19h  Codex 99% 3d15h ↺1       │
│                                                         Cursor 12%·3P 92% 10d5h  󰖩  󰍛 12%  󰕾 45%  󰂄 100% │
└───────────────────────────────────────────────────────────────────────────────────────────────────────────┘
  워크스페이스 · 현재 앱           가운데 시계                AI 구독 사용량 · Wi-Fi · CPU · 볼륨 · 배터리
```
> 실제로는 한 줄로 표시됩니다. 위 그림은 폭 때문에 두 줄로 나눴습니다.

---

## 목차

- [무엇이 들어 있나요](#무엇이-들어-있나요)
- [필요한 것](#필요한-것)
- [설치](#설치)
- [사용법](#사용법)
  - [상단 바 읽는 법](#상단-바-읽는-법)
  - [AI 구독 사용량](#ai-구독-사용량)
  - [macOS 메뉴바 쓰기](#macos-메뉴바-쓰기)
  - [단축키 (AeroSpace)](#단축키-aerospace)
- [내 입맛에 맞게 바꾸기](#내-입맛에-맞게-바꾸기)
- [문제 해결](#문제-해결)
- [제거](#제거)
- [파일 구조](#파일-구조)
- [감사의 말](#감사의-말)

---

## 무엇이 들어 있나요

| 구성 | 설명 |
|---|---|
| **SketchyBar 상단 바** | Tokyo Night 색상의 Omarchy(Waybar) 스타일 바. 워크스페이스, 현재 앱, 시계, Wi-Fi, CPU, 볼륨, 배터리 |
| **AI 구독 사용량** | Claude · Codex · Cursor의 한도 사용률과 **초기화까지 남은 시간**. 클릭하면 플랜·세부 한도 팝업 |
| **메뉴바 자동 전환** | 평소엔 SketchyBar, 마우스를 화면 맨 위에 잠시 대면 macOS 메뉴바로 전환 (작은 Swift 헬퍼) |
| **AeroSpace 설정** | i3/Hyprland 같은 타일링. 워크스페이스 1~9 고정, 모니터 2대면 1~5 / 6~9로 자동 분배 |
| **JankyBorders** | 포커스된 창에 파란 테두리 |
| **설치·제거 스크립트** | 기존 설정 자동 백업, 한 줄 설치, 한 줄 되돌리기 |

## 필요한 것

- macOS 14 이상 (Apple Silicon, Intel 모두 가능)
- [Homebrew](https://brew.sh)
- Xcode Command Line Tools — 메뉴바 전환 헬퍼를 빌드할 때 필요합니다
  ```bash
  xcode-select --install
  ```
- (선택) AI 사용량을 보려면 Claude / ChatGPT(Codex) / Cursor 중 하나 이상의 구독

아래 패키지는 설치 스크립트가 알아서 설치합니다.

| 패키지 | 용도 |
|---|---|
| `sketchybar` | 상단 바 |
| `borders` | 포커스 창 테두리 |
| `jq` | JSON 처리 |
| `font-caskaydia-mono-nerd-font` | 바 글꼴과 아이콘 |
| `aerospace` | 타일링 창 관리자 (`--no-aerospace`로 건너뛰기 가능) |
| `codexbar` | AI 구독 사용량 조회 (`--no-ai`로 건너뛰기 가능) |

## 설치

```bash
git clone https://github.com/yeo1220/omarchy-mac.git ~/omarchy-mac
cd ~/omarchy-mac
./install.sh
```

설치 스크립트가 하는 일:

1. 필요한 Homebrew 패키지 설치 (이미 있으면 건너뜀)
2. 기존 `~/.config/sketchybar`, `~/.aerospace.toml`을 `*.bak-날짜시간`으로 **백업**
3. 새 설정 복사, 메뉴바 전환 헬퍼 빌드
4. macOS 메뉴바 **자동 숨김** 켜기
5. SketchyBar · AeroSpace · CodexBar 실행

### 설치 옵션

| 옵션 | 설명 |
|---|---|
| `--link` | 복사 대신 이 저장소로 심볼릭 링크를 겁니다. `git pull`만 하면 바로 최신 설정이 됩니다 |
| `--no-aerospace` | 이미 다른 창 관리자(yabai, Rectangle 등)를 쓴다면 바만 설치합니다 |
| `--no-ai` | AI 사용량 표시를 빼고 설치합니다 |
| `--no-brew` | 패키지 설치를 건너뜁니다 |

### 설치 후 꼭 해야 할 것

1. **AeroSpace 권한 허용** — 처음 실행하면 *시스템 설정 → 개인정보 보호 및 보안 → 손쉬운 사용*에서
   AeroSpace를 켜 주세요. 권한이 없으면 창이 정렬되지 않습니다.
2. **CodexBar 계정 연결** — 메뉴바의 CodexBar 아이콘 → 설정에서 Claude · Codex · Cursor를 켜고 로그인합니다.
   연결 전에는 바에 `?`가 표시됩니다. (CodexBar는 이미 로그인된 브라우저 쿠키나 CLI 로그인 정보를 이용합니다)

## 사용법

### 상단 바 읽는 법

**왼쪽 — 워크스페이스와 현재 앱**

| 모양 | 의미 |
|---|---|
| 파란 배경 숫자 | 지금 보고 있는 워크스페이스 |
| 어두운 배경 숫자 | 다른 모니터에 떠 있는 워크스페이스 |
| 글자만 있는 숫자 | 창이 있는 워크스페이스 |
| (안 보임) | 비어 있는 워크스페이스 |

숫자를 클릭하면 그 워크스페이스로 이동합니다. 숫자 옆 흐린 글자는 지금 앞에 있는 앱 이름입니다.

**가운데 — 시계**: `9월 23일 (화)  10:12`
(13·14인치 노트북처럼 화면이 좁으면 오른쪽 항목과 겹치지 않도록 시계가 **오른쪽 끝**으로 갑니다. `CLOCK_POSITION` 참고)

**오른쪽 — 시스템 상태**: Wi-Fi(유선이면 이더넷 아이콘), CPU 사용률, 볼륨, 배터리(충전 중이면 번개)

### AI 구독 사용량

```
Claude 17% 26m·40% 4d19h     Codex 99% 3d15h ↺1     Cursor 12%·3P 92% 10d5h
       ─┬─ ─┬─ ─┬─ ──┬──           ─┬─ ──┬── ─┬           ─┬─  ──┬──── ──┬──
        │   │   │    └ 주간 한도 초기화까지 4일 19시간        │     │        └ 월간 한도 초기화까지
        │   │   └ 주간 한도 40% 사용                         │     └ 서드파티(Claude·GPT 등) 모델 92%
        │   └ 5시간 한도 초기화까지 26분                      └ Cursor 월간 전체 12%
        └ 5시간 한도 17% 사용
```

| 서비스 | 표시 내용 |
|---|---|
| **Claude** | `5시간 한도%  남은시간 · 주간 한도%  남은시간` |
| **Codex** | 같은 형식. 플랜에 5시간 한도가 없으면 주간만 표시. `↺N`은 **한도 재설정 크레딧**이 N회 남았다는 뜻 |
| **Cursor** | `월간 전체% · 3P 서드파티 모델% 남은시간` |

- **남은 시간 형식**: `4d19h`(4일 19시간), `5h9m`(5시간 9분), `26m`(26분)
- **색상**: 가장 높은 사용률 기준 — 🟢 50% 미만 · 🟡 50~79% · 🔴 80% 이상. 조회 실패는 회색 `?`
- **갱신**: 5분마다 자동. **항목을 클릭하면 즉시 갱신**됩니다.

**클릭하면 뜨는 팝업** — 플랜 이름과 모든 세부 한도를 한눈에 볼 수 있습니다. 마우스를 떼면 닫힙니다.

```
Claude Max 20x                    ChatGPT Pro Lite                  Cursor Pro+
5시간       17%  26m 후 초기화      주간         99%  3d15h 후 초기화   전체         12%  10d5h 후 초기화
주간        40%  4d19h 후 초기화    재설정 크레딧 1회 남음 · 10/23 만료   Cursor 모델   6%   10d5h 후 초기화
Fable 전용  15%  4d19h 후 초기화                                       서드파티      92%  10d5h 후 초기화
                                                                     Grok Bot     34%  5h3m 후 초기화
```

> 사용량 데이터는 [CodexBar](https://codexbar.app)의 CLI(`codexbar usage --json`)에서 가져옵니다.
> 이 저장소의 스크립트는 로그인 토큰이나 쿠키를 직접 읽지 않습니다.

### macOS 메뉴바 쓰기

SketchyBar가 macOS 메뉴바 자리를 차지하므로, 앱 메뉴(파일·편집 등)가 필요할 때는
**마우스를 화면 맨 위 끝에 0.6초쯤 대고 있으면** SketchyBar가 사라지고 macOS 메뉴바가 나타납니다.
마우스를 아래로 내리면(메뉴가 열려 있지 않을 때) SketchyBar가 다시 돌아옵니다.

- 바 항목을 가리키다 잠깐 맨 위에 닿는 정도로는 전환되지 않습니다.
- SketchyBar 팝업이 열려 있는 동안에는 전환되지 않습니다.
- 키보드로는 언제든 `⌃F2`(메뉴 막대로 포커스 이동)를 쓸 수 있습니다.

### 단축키 (AeroSpace)

Omarchy의 Super 키 자리에 `⌘`와 `⌥`을 나눠 썼습니다. `⌘`+화살표, `⌘`+숫자처럼 macOS와 앱에서
자주 쓰는 단축키는 건드리지 않았습니다.

**앱 실행**

| 단축키 | 동작 |
|---|---|
| `⌘ Enter` | 터미널(Ghostty) 새 창 |
| `⌘⇧ B` | Chrome 새 창 |

**창 이동·포커스**

| 단축키 | 동작 |
|---|---|
| `⌥ H / J / K / L` | 왼쪽 / 아래 / 위 / 오른쪽 창으로 포커스 |
| `⌥⇧ H / J / K / L` | 창을 그 방향으로 옮기기 |
| `⌘⇧ -` / `⌘⇧ =` | 창 크기 줄이기 / 늘리기 |
| `⌘⇧ W` | 창 닫기 |
| `⌘⇧ F` | 전체 화면 |
| `⌘⇧ T` | 플로팅 ↔ 타일 전환 |
| `⌘⇧ J` | 타일 배치(가로 ↔ 세로) |
| `⌘⇧ A` | 아코디언 배치 |

**워크스페이스·모니터**

| 단축키 | 동작 |
|---|---|
| `⌥ 1 ~ 9` | 워크스페이스 이동 |
| `⌥⇧ 1 ~ 9` | 현재 창을 그 워크스페이스로 보내기 |
| `⌥ Tab` | 직전 워크스페이스로 |
| `⌥ ,` | 다른 모니터로 포커스 |
| `⌥⇧ ,` | 창을 다른 모니터로 보내고 따라가기 |

**서비스 모드** — `⌘⇧ ;`를 누른 뒤

| 키 | 동작 |
|---|---|
| `Esc` | 설정 다시 불러오기 |
| `R` | 레이아웃 초기화 |
| `F` | 플로팅 ↔ 타일 |
| `Backspace` | 현재 창만 남기고 모두 닫기 |

시스템 설정, Finder, 활성 상태 보기는 자동으로 플로팅 창이 됩니다.

## 내 입맛에 맞게 바꾸기

설정 파일은 설치 후 `~/.config/sketchybar/`와 `~/.aerospace.toml`에 있습니다.
(`--link`로 설치했다면 이 저장소 파일을 바로 고치면 됩니다)

### 바 설정 — `sketchybar/sketchybarrc` 맨 위

```bash
SPLIT=5                           # 모니터 2대일 때 1~5는 메인, 6~9는 보조 모니터에 표시
AI_PROVIDERS="claude codex cursor" # 표시할 AI 서비스와 순서. 비우면 AI 항목을 표시하지 않음
AI_REFRESH=300                    # AI 사용량 갱신 주기(초)
CLOCK_POSITION=auto               # 시계 위치: center | right | auto
CLOCK_CENTER_MIN=1800             # auto일 때 가장 좁은 화면 폭이 이 값(pt) 이상이면 가운데, 아니면 오른쪽 끝
BG=0xf01a1b26                     # 색상 (0xAARRGGBB)
```

바꾼 뒤 `sketchybar --reload`로 적용합니다.

- **AI 서비스 줄이기** — Cursor를 안 쓴다면 `AI_PROVIDERS="claude codex"`
- **다른 AI 서비스 추가** — CodexBar가 지원하는 이름(`gemini`, `copilot`, `windsurf` 등,
  `codexbar usage --help` 참고)을 넣으면 기본 형식으로 표시됩니다.
- **시계 형식** — `plugins/clock.sh`의 `date` 형식을 바꿉니다. 영어로 쓰려면 `LC_TIME=ko_KR.UTF-8`을 지우세요.
- **색상 기준** — `plugins/ai_usage.sh`의 `color()` 함수에서 50/80 기준을 바꿉니다.

### 메뉴바 전환 감도 — `sketchybar/helpers/menubar_swap.swift`

```swift
let revealEdge: CGFloat = 2      // 화면 맨 위 몇 px 안에 들어오면 전환 대기
let restoreBelow: CGFloat = 44   // 이 아래로 내려가면 SketchyBar 복귀
let dwell: TimeInterval = 0.6    // 맨 위에 이만큼 머물러야 전환
```

바꾼 뒤 다시 빌드합니다.

```bash
swiftc -O ~/.config/sketchybar/helpers/menubar_swap.swift -o ~/.config/sketchybar/helpers/menubar_swap
sketchybar --reload
```

### 단축키 — `aerospace/aerospace.toml`

`[mode.main.binding]` 아래를 고친 뒤 `⌘⇧ ;` → `Esc`로 다시 불러옵니다. 터미널을 Ghostty 대신
다른 것으로 쓰려면 `cmd-enter` 줄의 앱 이름을 바꾸세요.

## 문제 해결

<details>
<summary><b>SketchyBar가 사라진 뒤 돌아오지 않아요</b></summary>

메뉴가 열려 있다고 판단되면 복귀하지 않습니다. 열린 메뉴를 `Esc`로 닫고 마우스를 아래로 내려 보세요.
그래도 안 되면 헬퍼를 다시 시작합니다.

```bash
sketchybar --bar hidden=off
sketchybar --reload
```
</details>

<details>
<summary><b>macOS 메뉴바가 항상 떠서 SketchyBar와 겹쳐요</b></summary>

메뉴바 자동 숨김 설정이 제대로 적용되지 않은 경우입니다. 껐다가 다시 켜면 해결됩니다.

```bash
osascript -e 'tell application "System Events" to set autohide menu bar of dock preferences to false'
osascript -e 'tell application "System Events" to set autohide menu bar of dock preferences to true'
```
</details>

<details>
<summary><b>앱 메뉴를 전혀 누를 수 없어요</b></summary>

`sketchybarrc`의 `topmost`가 `window`인지 확인하세요. `on`으로 두면 SketchyBar가 모든 창 위에 올라와
macOS 메뉴바를 가립니다. 참고로 `sketchybar --query bar`는 `window` 모드도 `"on"`으로 표시하니 헷갈리지 마세요.
</details>

<details>
<summary><b>AI 사용량이 <code>?</code>로 나와요</b></summary>

터미널에서 직접 확인해 보세요.

```bash
codexbar usage --provider claude
```

로그인 안내가 나오면 CodexBar 앱 설정에서 해당 서비스를 켜고 로그인하세요. 정상으로 나오는데 바만 `?`라면
`sketchybar --trigger ai_usage_refresh`로 즉시 갱신해 보세요.
</details>

<details>
<summary><b>가운데 시계가 오른쪽 항목과 겹쳐요</b></summary>

기본값(`CLOCK_POSITION=auto`)은 가장 좁은 화면 폭이 1800pt보다 작으면 시계를 오른쪽 끝에 둡니다.
그래도 겹치면 `sketchybarrc`에서 `CLOCK_POSITION=right`로 고정하거나 `AI_PROVIDERS`를 줄이고
`sketchybar --reload`를 실행하세요. 모니터를 연결·해제한 뒤에도 `--reload`로 위치를 다시 정합니다.
</details>

<details>
<summary><b>아이콘이 네모(□)로 깨져 보여요</b></summary>

Nerd Font가 없는 경우입니다.

```bash
brew install --cask font-caskaydia-mono-nerd-font
sketchybar --reload
```
</details>

<details>
<summary><b>워크스페이스 숫자가 엉뚱한 모니터에 떠요</b></summary>

`sketchybarrc`의 `SPLIT` 값과 `aerospace.toml`의 `[workspace-to-monitor-force-assignment]`가 같은
기준인지 확인하세요. 기본값은 둘 다 1~5 메인, 6~9 보조입니다. 모니터를 새로 연결했다면
`sketchybar --reload`로 모니터 수를 다시 감지합니다.
</details>

<details>
<summary><b>창이 타일로 정렬되지 않아요</b></summary>

AeroSpace에 손쉬운 사용 권한이 없는 경우입니다. *시스템 설정 → 개인정보 보호 및 보안 → 손쉬운 사용*에서
AeroSpace를 껐다 켠 뒤 AeroSpace를 다시 실행하세요.
</details>

<details>
<summary><b>창을 닫아도 Ghostty가 Dock에 계속 쌓여요</b></summary>

`⌘ Enter`는 `open -na Ghostty`로 매번 새 Ghostty 인스턴스를 띄웁니다. 그런데 macOS의 Ghostty는 기본적으로
마지막 창을 닫아도 종료되지 않아서 빈 인스턴스가 남습니다. `~/.config/ghostty/config`에 다음 줄을 추가하세요.

```
quit-after-last-window-closed = true
```

이미 쌓인 인스턴스는 Dock에서 종료하거나 `pkill -x ghostty`로 정리합니다(열린 터미널도 모두 닫힙니다).
</details>

<details>
<summary><b>바에 항목 이름만 있고 값이 비어 있어요</b></summary>

플러그인이 `sketchybar` 명령을 찾지 못하는 경우입니다. 터미널에서 AeroSpace를 띄웠을 때는 셸의 PATH를
물려받아 잘 되다가, Launchpad나 로그인 시 자동 실행에서만 비어 보이기도 합니다. `aerospace.toml`의
`[exec.env-vars]` `PATH`에 `sketchybar`가 설치된 경로(`which sketchybar`)가 들어 있는지 확인하고,
AeroSpace를 종료한 뒤 Launchpad에서 다시 실행하세요.

같은 이유로 AeroSpace는 터미널보다 Launchpad·Spotlight에서 실행하는 편이 좋습니다. 터미널에서 띄우면
그 셸의 환경 변수가 AeroSpace로 여는 모든 앱에 그대로 전달됩니다.
</details>

## 제거

```bash
cd ~/omarchy-mac
./uninstall.sh
```

설치한 설정을 지우고 설치 전에 백업해 둔 설정을 되돌립니다. 백업이 없으면 SketchyBar를 끄고
macOS 메뉴바를 항상 표시로 되돌립니다. Homebrew 패키지는 지우지 않으니 필요하면 안내된 명령으로 지우세요.

## 파일 구조

```
omarchy-mac/
├── install.sh                  설치 (백업 → 복사/링크 → 헬퍼 빌드 → 실행)
├── uninstall.sh                제거 (백업 복원)
├── sketchybar/
│   ├── sketchybarrc            바 구성과 설정값
│   ├── plugins/
│   │   ├── aerospace.sh        워크스페이스 표시 (한 번에 갱신)
│   │   ├── front_app.sh        현재 앱 이름
│   │   ├── clock.sh            시계
│   │   ├── battery.sh · volume.sh · cpu.sh · wifi.sh
│   │   ├── ai_usage.sh         AI 구독 사용량 조회·표시 (CodexBar CLI)
│   │   └── ai_popup.sh         AI 항목 클릭 → 팝업 열기/닫기
│   └── helpers/
│       └── menubar_swap.swift  SketchyBar ↔ macOS 메뉴바 전환 헬퍼
└── aerospace/
    └── aerospace.toml          타일링·단축키 설정
```

### 동작 원리 (궁금한 분을 위해)

- **워크스페이스 표시**: 숨은 항목 `spaces_ctl` 하나가 AeroSpace 이벤트를 받아 9개 숫자를 한 번에 갱신합니다.
  숫자마다 스크립트를 돌리는 방식보다 가볍습니다.
- **AI 사용량**: 숨은 항목 `ai_ctl`이 서비스별 `codexbar usage --json`을 **동시에** 호출해 2초 안팎에
  갱신합니다. 팝업 행은 미리 7줄씩 만들어 두고 쓰는 줄만 보이게 합니다.
- **메뉴바 전환**: Swift 헬퍼가 0.1초마다 커서 위치를 보고 `sketchybar --bar hidden=on/off`를 호출합니다.
  macOS 메뉴가 열려 있는지는 화면의 팝업 메뉴 레벨 창으로 판단합니다. 이때 SketchyBar 자신의 팝업 창은
  같은 레벨로 화면 밖에 늘 떠 있어서 판단에서 뺍니다.

## 감사의 말

- [Omarchy](https://omarchy.org) — 디자인과 사용감의 원본
- [SketchyBar](https://github.com/FelixKratz/SketchyBar), [JankyBorders](https://github.com/FelixKratz/JankyBorders) — Felix Kratz
- [AeroSpace](https://github.com/nikitabobko/AeroSpace) — Nikita Bobko
- [CodexBar](https://codexbar.app) — Peter Steinberger
- [Tokyo Night](https://github.com/folke/tokyonight.nvim) 색상

## 라이선스

[MIT](LICENSE)

이슈와 PR 모두 환영합니다. 사용하시다 불편한 점이나 아이디어가 있으면 편하게 [이슈](https://github.com/yeo1220/omarchy-mac/issues)로 남겨 주세요.
