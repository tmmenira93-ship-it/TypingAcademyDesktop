# Typing Academy Desktop

Offline Flutter desktop tutor for touch typing. Original lessons, local SQLite progress, and no account.

## Platforms

- Windows 10 (21H2+) and Windows 11
- macOS 10.14+
- Linux: Debian 12, Ubuntu 22.04+, Fedora 38+

This repository was developed and tested on Linux. Windows and macOS binaries must be built on those operating systems.

## Quick start

```bash
cd typing_academy_desktop
flutter pub get
flutter analyze
flutter test
flutter run -d linux
```

## What is included

- Splash, home, lesson map, language, practice, results, statistics, achievements, settings, and help
- Independent typing engine with WPM, accuracy, pause, and Backspace
- 150+ generated lessons in 13 stages, modelled on the Typing Jungle plan: score-free key introductions, practice, reviews, sentences, capitals, common patterns, numbers, symbols
- Redesigned interface: one card style everywhere, wide labelled navigation rail, daily goal ring and practice streak, collapsible colour-coded lesson stages, trend charts, animated star results, grouped settings, badge gallery
- Hands guide, optional key sounds, playback of your last attempt, per-key and per-finger statistics
- Six typing games (Word Rain, Letter Pop, Speed Race, Word Sprint, Key Hunt, Magic Tiles piano game), stored replays, voice-over of lesson instructions, stories and extra word/sentence drills (~420 lessons in 22 stages)
- Word Rain game (type the falling words), plus extra badges (speed ladder, five-star lessons, practice time)
- 5-star scoring with minimum speed and accuracy per lesson, optional block-on-error, and a weak-keys practice lesson built from your own mistakes
- Local SQLite storage, backup, restore, and history delete
- Light and dark themes, English and Arabic UI (full right-to-left layout in Arabic)
- Practice screen with an on-screen keyboard: keys coloured by finger, next key outlined, Shift hint, finger name
- Lesson map grouped by stage with per-stage progress, star ratings and an "up next" marker

## Docs

- `docs/USER_GUIDE.md`
- `docs/BUILD.md`

## Formulas

- WPM = (correct characters / 5) / minutes
- Accuracy = (correct characters / target length) * 100
