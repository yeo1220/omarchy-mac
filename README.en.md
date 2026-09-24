# omarchy-mac

**An [Omarchy](https://omarchy.org)-style top bar and tiling setup for macOS**

A bundle of [SketchyBar](https://github.com/FelixKratz/SketchyBar) and
[AeroSpace](https://github.com/nikitabobko/AeroSpace) configs that brings Omarchy's clean Waybar look and
keyboard-driven window management to the Mac — plus a live **AI coding subscription usage** readout
for Claude, Codex and Cursor.

[한국어 README](README.md) (more detailed)

## Features

- **Tokyo Night SketchyBar** — workspaces, front app, clock (centered, or right-aligned on narrow screens via `CLOCK_POSITION`), Wi-Fi, CPU, volume, battery
- **AI subscription usage** — usage % and time until reset for Claude (5h / weekly), Codex (5h / weekly,
  `↺N` = rate-limit reset credits left) and Cursor (monthly / third-party models). Color-coded
  (green < 50%, yellow < 80%, red ≥ 80%). Click an item for a popup with the plan name and every sub-limit.
  Data comes from the [CodexBar](https://codexbar.app) CLI; no tokens or cookies are read by these scripts.
- **Menu bar swap** — SketchyBar is shown normally; rest the cursor at the very top edge for ~0.6 s and it
  hides so you can use the macOS menu bar. Move down and it comes back.
- **AeroSpace config** — workspaces 1–9 pinned, auto-split 1–5 / 6–9 across two monitors,
  `⌥ hjkl` focus, `⌥ 1–9` workspaces, `⌘ Enter` terminal. `⌘`+arrows and `⌘`+numbers are left to macOS.
- **JankyBorders** focus border.

## Install

Requires Homebrew and Xcode Command Line Tools (`xcode-select --install`).

```bash
git clone https://github.com/yeo1220/omarchy-mac.git ~/omarchy-mac
cd ~/omarchy-mac
./install.sh            # --link | --no-aerospace | --no-ai | --no-brew
```

Existing `~/.config/sketchybar` and `~/.aerospace.toml` are backed up to `*.bak-<timestamp>`.
After installing, grant AeroSpace Accessibility permission and sign in to your providers in CodexBar's settings.

`./uninstall.sh` removes the config and restores the latest backup.

## Customize

Top of `sketchybar/sketchybarrc`:

```bash
SPLIT=5                            # workspaces 1..SPLIT on main display when 2+ monitors
AI_PROVIDERS="claude codex cursor" # any CodexBar provider id; empty = hide AI items
AI_REFRESH=300                     # seconds
```

Menu bar swap timing lives in `sketchybar/helpers/menubar_swap.swift` (`dwell`, `revealEdge`,
`restoreBelow`); rebuild with `swiftc -O` afterwards. The clock and labels are in Korean — edit
`plugins/clock.sh` and the titles in `plugins/ai_usage.sh` to localize.

`⌘ Enter` runs `open -na Ghostty`, which starts a new Ghostty instance each time. Ghostty on macOS keeps
running after its last window closes, so add `quit-after-last-window-closed = true` to
`~/.config/ghostty/config` to stop empty instances from piling up in the Dock.

If bar items show labels but no values, the plugins can't find `sketchybar`: make sure its location
(`which sketchybar`) is in `[exec.env-vars]` `PATH` in `aerospace.toml`, then relaunch AeroSpace from
Launchpad rather than a terminal.

## License

MIT
