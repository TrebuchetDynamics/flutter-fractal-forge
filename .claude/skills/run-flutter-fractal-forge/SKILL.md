---
name: run-flutter-fractal-forge
description: Run, launch, build, drive or screenshot the Flutter Fractal Forge Linux desktop app headless under Xvfb — open a catalog fractal, change its parameters and capture PNGs of the real app window. Use to see a module, shader or catalog change working in the app, not just in tests.
---

# Run Flutter Fractal Forge (Linux, headless)

The app has no command-line way to open a fractal on Linux (deep links arrive
over a platform method channel), and no window to click on a headless host.
So the agent path is a small **integration-test driver**: `run.sh` boots the
real app (`FlutterFractalsApp`, GPU renderer) under Xvfb, executes a list of
steps (search the catalog, open a card, change parameters, go back) and
screenshots the X screen with ImageMagick after each `shot:` step.

All paths are relative to the repository root. Files:
`.claude/skills/run-flutter-fractal-forge/run.sh` (entry point) and
`.claude/skills/run-flutter-fractal-forge/driver_test.dart` (the steps).

## Prerequisites

Present on the host where this was verified (not installed by this skill):
Flutter on `PATH` (3.47.9, `~/.local/bin/flutter`), `xvfb-run`, ImageMagick
`import`. Check with:

```bash
which flutter xvfb-run import
```

## Run (agent path)

From the repo root:

```bash
.claude/skills/run-flutter-fractal-forge/run.sh build/run-skill-verify 'shot:catalog;open:Mandelbrot|mandelbrot;shot:mandelbrot;back;open:Pascal|pascal_ulam_number_fractals;set:variant=1;shot:pascal-ulam'
```

It builds the Linux debug bundle if needed, runs the steps and prints one
`STEP`/`CAPTURE` line per step, then `exit=<code> log=<OUT_DIR>/run.log`.
Screenshots land in `OUT_DIR/<name>.png` (1280×720, the app window exactly).
**Look at them** — a pass only proves the steps ran.

Steps (`;`-separated, executed in order after the app boots):

| Step | Effect |
| --- | --- |
| `shot:<name>` | pump ~4 s, then `import -window root OUT_DIR/<name>.png` |
| `search:<query>` | type into the catalog search field |
| `open:<query>\|<module id>` | search, tap card `catalogModuleCard_core.<module id>`, wait for `fractalViewerRoot` |
| `set:<param>=<number>` | `FractalController.updateParam` in the open viewer |
| `wait:<seconds>` | keep pumping frames |
| `back` | pop the viewer back to the catalog |

Module ids and parameter ids come from `lib/core/modules/` (for example
`mandelbrot`; `pascal_ulam_number_fractals` with `variant`, `cellScale`).
On `main` the spiral modules are `ulam_spiral` (`startValue`, `pattern`) and
`sacks_spiral` (`marks`).

Timing (this host): about 2 min 50 s for a run including a fresh Linux build;
about 40 s of that is the app run for three screenshots.

## Gotchas

- **The driver must sit under `integration_test/`** for `flutter test -d linux`
  to build the app and for `helpers/ui_test_helpers.dart` to resolve. `run.sh`
  copies it to `integration_test/zz_run_skill_driver_test.dart` and deletes it
  on exit. If the run is killed hard, delete that file by hand — do not commit it.
- **Xvfb renders in software** (~2.4 fps observed). The driver pumps in timed
  250 ms steps instead of `pumpAndSettle`, which never settles on animated
  viewers. Frame rate here says nothing about real GPUs.
- **Screen size:** the Linux runner opens a 1280×720 window. A larger Xvfb
  screen (1600×1000 was tried) leaves a black band right and below the app in
  every screenshot; `run.sh` uses `1280x720x24`.
- **`set:` is not UI input.** It changes parameters through the controller, so
  it shows rendering, not that sliders or chips work. Use the widget tests for
  control behaviour.
- **Catalog card keys** are `catalogModuleCard_core.<module id>`; the driver
  always searches first, then taps the first matching card.
- **`.claude/` is gitignored** in this repo (`.gitignore:88`, `**/.claude/`):
  this skill is local unless that rule is changed.
- **Shared machine:** Orbi workers under `.worktrees/` may be running full
  `flutter test` suites at the same time; expect slower runs then.

## Human path

Not verified headless. On a desktop session `flutter run -d linux` opens the
same window; this skill does not cover it.
