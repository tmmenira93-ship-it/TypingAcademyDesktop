# TypingClub - reverse-engineering analysis (REA)

Source: TypingClub's official "Typing Jungle Teacher Handbook" and public product descriptions.
Scope: behaviour, structure and UX only. No code, lesson text or artwork is copied - everything here is an original re-implementation of the *ideas*.

## 1. Curriculum model
- One linear course of lessons, completed in order ("don't skip around"). Sections follow the keyboard:
  home row -> top row -> bottom row -> sentences (lowercase) -> Shift/capitals -> sentences with capitals -> numbers -> symbols -> more symbols -> content-based advanced levels.
- Fingers travel along diagonals and always return to the home row. Opposite-hand Shift is used for capitals/symbols.
- Each section has a rising speed requirement (early lessons: minimum 3 WPM, goal 10 WPM; late lessons: minimum ~50, goal ~75).

## 2. Lesson types
Key introduction (score-free, written finger instructions) - review - practice - anchoring (one hand holds F or J) - travel (diagonals) - common letter patterns - "tricky words" (homophones, misspellings) - content/story lessons - dynamic lesson generated from the learner's weak characters - games - short videos.

## 3. Requirements and stars
- Every lesson has a minimum speed, a goal speed and a minimum accuracy; passing is not the goal, mastery (5 stars) is.
- The results screen shows performance on one side and the requirements on the other (done here: "Your result vs. requirements").
- Intro lessons earn a check mark instead of stars; maximum score earns a special top star.

## 4. Student settings
Virtual keyboard guide - hand guides (both / left / right) - keyboard skins - 5 font sizes + high-contrast themes - voice-over (letters or words, finger instructions) - typewriter key sounds - live WPM/accuracy toggle - per-word speed - "block on error" (after the 1st/2nd/3rd error) - Backspace on/off (recommended on for beginners).

## 5. Feedback and motivation
Attempt playback - stats (speed, accuracy, keyboard coverage, strongest/weakest characters and fingers) - practice calendar and punch card - milestone badges with ladders (WPM, attempts per day, practice minutes, day streaks, five-star lessons) - optional scoreboard - five arcade-style games (single characters or whole words) - animated story typing.

## 6. Gap analysis for Typing Academy
| Area | Status |
|---|---|
| Colour-coded keyboard, next-key highlight, opposite Shift, F/J bumps | Added |
| Finger name hint | Added |
| Keyboard / live stats / Backspace options | Added (Settings > Practice options, DB v2) |
| Requirements vs. performance on results | Added |
| RTL Arabic UI | Fixed |
| Hands guide drawing (both hands, active finger filled) | Added (shown when the window is tall enough) |
| 5-star scale, minimum WPM per lesson, score-free intro lessons | Added (own thresholds, see TypingEngine.starCount) |
| Block on error with per-key-press accuracy | Added (Settings; always on in intro lessons) |
| Per-character stats and weak-key dynamic lesson | Added (key_stats table, DB v3) |
| Course structure: sections, key pairs, reviews, patterns, tricky words | Added (lib/data/curriculum.dart, ~150 lessons) |
| Attempt playback | Added, stored for the newest 200 attempts and playable from Statistics > Recent attempts |
| Key / error / success sounds | Added (audioplayers, synthesised tones; off by default) |
| Voice-over | Added for lesson instructions, using the system voice (Windows SAPI, macOS say, Linux spd-say/espeak); needs a voice for the chosen language |
| Per-key and per-finger statistics, more badges | Added |
| Games | Six added (Word Rain, Letter Pop, Speed Race, Word Sprint, Key Hunt, Magic Tiles) |
| Stories | Added: 6 short original stories in 3 chapters (Stories stage) |
| Videos | Missing - video lessons cannot be produced here |
| Content volume: ~420 lessons (Word Drills, Sentence Builder, Speed Drills, More Patterns, Real-Life Numbers, Code and Email, Everyday Sentences, 12 stories, Typing Tests) vs. 600+ | Largest remaining gap |

## 7. Suggested order of work
1. Lesson content generator (sections above) with min/goal WPM and a `type` field (intro / practice / review / patterns / test).
2. Per-key statistics + dynamic "weak keys" lesson + stats screen with finger/character breakdown.
3. Keystroke log + playback; block-on-error with keystroke-based accuracy; 5-star scale.
4. Hand guide, key sounds, one game (falling words).
