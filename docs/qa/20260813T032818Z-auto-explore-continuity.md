# Auto-Explore Continuity Verification — Android

- **Timestamp (UTC):** 2026-08-13T03:28:18Z
- **Device:** Samsung SM-S928B, Android 16 / API 36, arm64
- **Module:** `alternated_iteration`
- **Build:** Flutter debug from local `main` after `e8424beb`
- **Behavior exercised:** restored viewer auto-explore control, start/pause state, active GPU rendering, non-overlap with module title

## Results

- The viewer exposed `Start auto-explore` through Android accessibility semantics.
- Activating the control changed its visible icon from compass/explore to pause.
- The control and `Alternated Iteration` title remained visibly separate and legible.
- Runtime GPU logs sustained approximately 60 FPS during active rendering; representative snapshots included 60.1 FPS with no long frames in a 300-frame window, and 56.9 FPS during a transient heavier window.
- Planner/unit verification covered elapsed-time progress and geometric midpoint pacing for `1 → 120`, `1e6 → 1e9`, and `1e9 → 1e12`.

## Evidence

- Inactive/non-overlapping control screenshot SHA-256: `1a075da02d399c668bf9789426468d6e2fe7119ae9bbe3ff9f643fc8e577f53e`
- Active pause-control screenshot SHA-256: `203cf36dcdf643ac80ec3ef613e6ddb760dc4e76819e28ffb37cadb4fdba675d`
- Screenshots were temporary runtime evidence under `/home/xel/.cache/hermes-tmp/fractal-next-p0/` and are not shipped assets.

## Linux status

Linux runtime launch is blocked on this host because `ffmpeg_kit_flutter_new_min` requires the missing system package `json-glib-1.0` / `libjson-glib-dev`. Installing it requires interactive sudo credentials unavailable to the agent. Automated Linux widget tests and analyzer pass; Android provided the real-device behavioral verification.
