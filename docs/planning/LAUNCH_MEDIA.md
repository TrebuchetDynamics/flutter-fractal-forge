# Featured Launch Set — Media Runbook

> Companion to `LAUNCH_LADDER.md` (what to launch) and `SOCIAL_LAUNCH.md` (where
> to post). This is the **how to produce the visuals** doc: the curated set,
> exact capture commands, target sizes per platform, and the acceptance gate.

## The curated set

The app already ships a deterministic featured set in
`lib/features/catalog/featured_launch_set.dart` (`kFeaturedLaunchSetModuleIds`).
These are the launch-critical first-impression fractals:

| Module ID | Family | One-line caption (for X / store) |
|---|---|---|
| `mandelbrot` | escape-time (2D) | The original — infinite detail at every zoom. |
| `julia` | escape-time (2D) | Twist one constant, get a whole new universe. |
| `burning_ship` | escape-time (2D) | Jagged, alien, unmistakable. |
| `phoenix` | escape-time (2D) | Fractals with memory — each step remembers the last. |
| `nova` | relaxation | Relaxation dynamics blooming into petals. |
| `newton_z3` | Newton | Where root-finding turns into art. |
| `koch_snowflake` | IFS / geometric | Infinite perimeter, finite area. |
| `barnsley_fern` | IFS attractor | Chaos that grows a leaf. |
| `lorenz_2d` | strange attractor | The butterfly effect, drawn. |

### Coverage gap to close for marketing

`LAUNCH_LADDER.md` wants variety including **tiling** and **one 3D** example.
The QA featured set has neither. For marketing visuals (a broader scope than the
QA set), add these two via `CATALOG_THUMB_ONLY` — they are the biggest wow:

- **3D:** `mandelbulb` (the headline 3D fractal)
- **Tiling:** `spectre_monotile` or `hat_monotile` (aperiodic monotile — topical)

```bash
CATALOG_THUMB_ONLY=mandelbulb,spectre_monotile ./scripts/capture-launch-media.sh
```

Pick the final **6–8 hero stills by taste** from the rendered candidates — this
is a human judgment call (`LAUNCH_LADDER.md`: "select manually by taste").

## Capture commands

### 1. High-res stills (clean, full-frame) — the workhorse

```bash
# Whole featured set @ 1080x1080 → build/test_output/launch_media/<id>.png
./scripts/capture-launch-media.sh

# Larger, or a different palette seed:
LAUNCH_MEDIA_SIZE=1440 CATALOG_THUMB_SEED=launch-2 ./scripts/capture-launch-media.sh
```

Under the hood this runs the GPU thumbnail harness in launch mode
(`LAUNCH_MEDIA_SIZE=<px>`), which renders `kFeaturedLaunchSetModuleIds` at the
requested square size with the existing quality gates (luminance variance, edge
density, color uniqueness) and writes a `thumbnail_report.json` next to the PNGs.

> **Run this on a machine with a real GPU.** Headless/xvfb falls back to
> software GL — usable as a smoke, but not launch-quality, and some shaders may
> render differently. This is the `LAUNCH_LADDER.md` "hardware GPU" gate.

### 2. Hero zoom GIF — simplest path is in-app

The app already has a camera **Looper** + GIF export. For the headline motion
clip:

1. Open `mandelbrot` (or `mandelbulb` for 3D), find a striking spot.
2. Tap the **Looper** FAB, set a slow zoom loop.
3. Export as **GIF** (the share caption auto-carries `@FractalForge #fractalforge`
   and the reproducible deep link).

This avoids new code and produces a genuine interactive-zoom clip. For a longer
15–30s "catalog → viewer → zoom" walkthrough (`LAUNCH_LADDER.md` Stage 1), screen
-record the running app/web preview.

### 3. UI-context screenshots (for the Play Store)

Play Store phone screenshots need app chrome, not bare fractals:

```bash
flutter test integration_test/screenshots/full_screenshots_test.dart -d linux
# or headless:
./scripts/desktop-screenshots.sh   # → ./screenshots/
```

### 4. Web-preview gallery + quality analysis

```bash
flutter build web --release --dart-define=PLAYWRIGHT_CATALOG_SMOKE=true
CATALOG_SMOKE_FILTER="mandelbrot|julia|burning_ship|phoenix|nova|newton_z3|koch_snowflake|barnsley_fern|lorenz_2d" \
  npx playwright test test/playwright/catalog-smoke.spec.mjs --workers=1
# → test/results/catalog-smoke-visual-*/ (PNGs + an HTML gallery + metrics)
```

## Target sizes per platform

| Use | Size | Source |
|---|---|---|
| X / social, square | 1080×1080 | `capture-launch-media.sh` (default) |
| X / social, landscape | 1600×900 (crop from 1440) | crop a 1440 still |
| GitHub README stills | ≤1280 wide | downscale stills |
| GitHub README / X GIF | ≤1280 wide, <15 MB | in-app Looper GIF |
| Play feature graphic | 1024×500 | compose from a hero still (`store_listing/ASSET_SPECS.md`) |
| Play phone screenshots | 1080×1920 (portrait, with UI) | `full_screenshots_test.dart` |
| Web hero | 1920×1080 | compose / crop |

## Branding

- **Clean versions** (no watermark) for the website hero and Play Store.
- **Watermarked versions** for loose social reshare: enable the **Watermark**
  toggle (Export → Advanced, off by default) to stamp `@FractalForge`. Keep both.
- Every in-app share already carries `@FractalForge #fractalforge` + a deep link
  that reopens the exact view (see `SOCIAL_LAUNCH.md`).

## Acceptance checklist (per candidate)

From `LAUNCH_LADDER.md`, gate every pick before it ships as launch media:

- [ ] Rendered on **real GPU hardware** (not software/headless).
- [ ] Opens without crash / blank / obvious render failure.
- [ ] No `failed` entry and no `qualityWarnings` in `thumbnail_report.json`.
- [ ] Launch-worthy framing (recolor with `CATALOG_THUMB_SEED` if flat).
- [ ] One-line caption written (see table above).
- [ ] Variety across the final 6–8: 2D escape-time, Newton, IFS, attractor,
      tiling, and one 3D.
