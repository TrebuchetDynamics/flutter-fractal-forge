# Waydroid export-journey repair and verification

## Scope and verdict

2026-10-24: repaired device-test assumptions, not production export behavior.
The critical export-menu journey and edited Mandelbrot/Mandelbulb PNG journey
passed on the existing headless Waydroid Android 13 x86_64 target. Fresh PNGs were
also read through MediaStore and opened in Android Gallery over SSH.

This is debug/instrumented Waydroid evidence, **not signed production-artifact
qualification, physical-device proof, a full offline-suite pass or Play publication**.
No signing-material use, Play status query or upload occurred.

## Repairs

- [`critical_journey_test.dart`](../../../integration_test/flows/critical_journey_test.dart):
  remove the obsolete `Share & export` heading assertion. The current popup menu
  deliberately has no such heading, as already asserted by
  [`fractal_view_controls_test.dart`](../../../test/fractal/fractal_view_controls_test.dart).
  Retain tapping Export and checking the actual export sheet, Save/Share actions
  and return to catalog.
- [`user_flows_test.dart`](../../../integration_test/flows/user_flows_test.dart):
  keep native Android viewport metrics instead of the synthetic Linux landscape
  surface; preserve the Linux fixture. Search/scroll to each module, drag the view,
  select HD, and require a newly created PNG rather than accepting a preexisting
  file. Decode dimensions for the actual orientation, require more than 16 sampled
  colors, and assert that the edited view and saved preferences/preset survive.
  Emit exact saved paths and retain state sidecars for external readback.
- HD is orientation-aware: this portrait target selects 720×1280. The landscape
  expectation remains 1280×720. This follows
  [`ExportOptions`' existing orientation policy](../../../lib/core/models/export_options.dart),
  not a new production behavior.

An attempted `TestTextInput.hide()` was removed: the live integration binding
uses the real platform text-input connection, not the registered widget-test
text-input double. The final passing test does not use it or force unfocus.

## Device runs

Use the pinned Flutter 3.44.6/Dart 3.12.2 and provisioned package cache as described
in [the local runbook](../runbook.md). The test device was
`192.168.240.112:5555`; discover the current address for future runs.

```bash
flutter test --no-pub integration_test/flows/critical_journey_test.dart \
  -d "$ANDROID_DEVICE" --dart-define=FORCE_GPU_RENDER=true --reporter expanded
flutter test --no-pub --no-uninstall integration_test/flows/user_flows_test.dart \
  -d "$ANDROID_DEVICE" --dart-define=FORCE_GPU_RENDER=true --reporter expanded \
  --plain-name 'Android 2D and 3D journey saves edited mathematical PNG artifacts'
```

Each command passed its selected test. The latter was repeated with
`--no-uninstall` so Flutter would retain the app/export directory for byte-level
readback. Flutter's default integration-test teardown uninstalls the app; a
content URI can survive even after private/app-scoped exports and sidecars vanish.
Do not mistake that teardown for an export-write failure. See the
[setup guide's app-data warning](waydroid-headless.md#run-tests-without-confusing-setup-with-qualification).

Logs and decoded PNGs/screenshots were retained in execution-host scratch, not
committed binary assets:

- `/tmp/fractal-waydroid-critical-fixed.log`
- `/tmp/fractal-waydroid-export-readback.log`
- `/tmp/fractal-waydroid-gallery-evidence/readback.json`
- `/tmp/fractal-waydroid-gallery-evidence/{mandelbrot,mandelbulb}.png`
- `/tmp/fractal-waydroid-gallery-evidence/{mandelbrot,mandelbulb}.state.json`
- `/tmp/fractal-waydroid-gallery-evidence/{mandelbrot,mandelbulb}-gallery.png`

Scratch is not permanent storage; preserve these artifacts with the actual
candidate before any later release qualification or cleanup.

## Fresh MediaStore and Gallery readback

The successful run's exact outputs were:

| Module | Filename | MediaStore ID | PNG dimensions | Sampled RGB colors |
| --- | --- | --- | --- | --- |
| Mandelbrot | `fractal_mandelbrot_1792880055951.png` | `1000000387` | 720×1280 | 3,037 |
| Mandelbulb | `fractal_mandelbulb_1792880066685.png` | `1000000388` | 720×1280 | 4,185 |

Both records reported `mime_type=image/png`, `is_pending=0` and
`relative_path=Pictures/FractalForge/`. A separate Python/Pillow readback fully
decoded each content URI, compared its bytes with the app-scoped export, and
confirmed dimensions and nontrivial colors (sampled at 180×320). SHA-256:

- Mandelbrot: `4b04f06b6dbc1057a0da13afd8db2c498a46fa9cb93a25d18dd19241a796d83a`
- Mandelbulb: `bd80b5ffe1507d3323138464c2133eae2cb9f61fa9cc91c73581f5cd902e539d`

For each exact URI, `am start -W` with `ACTION_VIEW`, `image/png`, a read grant and
`com.android.gallery3d/.app.GalleryActivity` returned `Status: ok`.
After UI-idle detection, activity inspection confirmed Gallery was resumed and
screenshots showed the saved image. Gallery's first-use media-access dialog was
accepted through its actual Allow button, not by disabling permission checks.
Mandelbrot appeared as a black set with a cyan boundary on pink; Mandelbulb as an
orange, detailed 3D form on a dark background. This is agent screenshot inspection,
not an attributable human mathematical-composition approval.

Example readback commands (use each new run's exact filename/ID, never these
historical IDs to qualify a later candidate):

```bash
adb -s "$ANDROID_DEVICE" shell content query \
  --uri content://media/external/images/media \
  --projection _id:_display_name:width:height:is_pending:mime_type:relative_path \
  --where "\"_display_name='fractal_mandelbrot_1792880055951.png'\""
adb -s "$ANDROID_DEVICE" exec-out content read \
  --uri content://media/external/images/media/1000000387 > /tmp/mediastore-readback.png
adb -s "$ANDROID_DEVICE" shell am start -W \
  -n com.android.gallery3d/.app.GalleryActivity \
  -a android.intent.action.VIEW \
  -d content://media/external/images/media/1000000387 \
  -t image/png --grant-read-uri-permission
```

Decode the downloaded PNG and compare it with that run's original export; a row
or successful launch alone is insufficient. For screenshots on this host, write
`screencap -p` to an Android file and pull it. Direct `exec-out screencap -p`
contained a vendor `amdgpu.ids` warning mixed into the PNG stream. Do not weaken
PNG decoding to accept that polluted stream.

## Other checks and remaining release limits

- Pinned offline dependency resolution: passed, lockfile unchanged.
- `flutter analyze --no-pub`: no issues.
- Two targeted viewer widget-test files: **233 passed**.
- `python3 -m pytest test/research test/scripts -q` with provisioned `/usr/bin/python3`:
  **282 passed, 1 skipped, 103 subtests passed**.
- `bats test/scripts/*.bats`: **25 passed**.
- Full common offline command: **timed out after 900 seconds** during Flutter
  tests, last recorded aggregate **1,636 passed, 1 skipped**. No complete suite
  success is claimed. Python/Bats were run independently afterward, not reached
  by that timed-out `&&` chain. Full log:
  `/tmp/fractal-waydroid-fix-offline-gate.log`; targeted log:
  `/tmp/fractal-waydroid-targeted.log`.
- Independent read-only review found no actionable defects in the two test diffs;
  it did not rerun the device tests. Only the current portrait orientation was
  exercised; Android landscape remains unverified.

## Subsequent Play release attempt (2026-10-24)

The later authorized production attempt completed the common offline command with
exit 0: clean analysis, **2,986 Flutter tests passed with 8 skipped**, **282 Python
tests passed with 1 skipped and 103 subtests passed**, and **25 Bats tests passed**.
This supersedes the earlier timeout as the current common-gate result for these
unchanged inputs. Log: `/tmp/fractal-play-release-common-gate.log`.

A live Android Publisher API inventory found production
**Fractal Forge 1.1.107 (107), status `completed`**, with highest visible bundle/APK/
track version code **107**. The temporary inventory edit was deleted without
uploading or committing changes. Redacted inventory:
`/tmp/fractal-play-preflight.json`. This checks API track state, not every Play
Console review-status field or a permanent reservation of a version code.

The attempted next identity was **1.1.111 (111)**, above the repository's existing
110 identity. The mandatory device gate was invoked with the pinned SDK:

```bash
bash scripts/pre-release-gate.sh --skip-host --device "$ANDROID_DEVICE" \
  --build-name 1.1.111 --build-number 111 \
  --log-dir /tmp/fractal-play-111-device-gate
```

`--skip-host` reused the just-passed common checks; no device requirement was
removed. The combined integration suite passed **12 tests with 8 skipped**.
The following mandatory rapid-scroll runtime-thumbnail test **failed**:
`catalog_thumbnail_performance_test.dart` could not find `Barnsley Fern` after
its bounded unfiltered scroll, and reported a **135-pixel vertical card-caption
overflow**. The gate exited 1 before the signed production artifact, restoration,
offline and soak stages. Logs: `/tmp/fractal-play-111-device-gate.log` and
`/tmp/fractal-play-111-device-gate/`.

That attempt stopped before upload. The following repair/rerun supersedes its
thumbnail/layout and unreached-device-stage blockers, not its historical verdict.
No AAB upload, production-track update or Play edit commit was attempted.

## Thumbnail/layout repair and complete gate rerun (2026-10-25 UTC)

The compact Fibonacci summary was rendering the full long legend into the fixed
catalog caption. EN/ES regression tests reproduced excessive height and real-card
overflow at 3× text before the fix. Compact presentation now uses three ellipsized
lines at the existing caption text size; the complete string remains in Text
semantics and noncompact viewer details remain unabridged. Both sizing/semantics
and narrow-card overflow regressions pass.

The old benchmark assumed a fixed Barnsley entry would appear within twenty
unfiltered drags. It now asserts a catalog-size-independent **three-viewport
traversal**, using twenty gestures only as a safety bound. It snapshots all
partially/fully visible **preview bounds**, excluding sliver cache-extent children,
and requires each snapshotted preview to become cached. At least two previews,
zero render failures, first-thumbnail/full-grid telemetry, and the original
**five-second end-to-end limit** remain required. The wait loop uses that same
remaining budget rather than adding another five seconds. A trial with twenty
unconditional gestures expanded the original workload and failed the deadline;
it was replaced with this explicit distance-based workload, not a higher timeout.

Independent read-only review found no blocking defect and reran the twenty
caption/accessibility widget tests and forced-runtime visibility test successfully.
Its nonblocking suggestion to align widget-test selection with preview rather
than card bounds was applied and verified in the final full run.

Final validation:

- Pinned common offline command: **exit 0**, clean analysis; **2,990 Flutter tests
  passed with 8 skipped**; **282 Python tests passed with 1 skipped and 103 subtests
  passed**; **25 Bats checks passed**. The forced-runtime thumbnail visibility
  widget test additionally passed. `pubspec.lock` remained unchanged.
  Log: `/tmp/fractal-thumbnail-repair-full-gate.log`.
- Full `pre-release-gate.sh --skip-host` rerun for **1.1.111 (111)**: **exit 0**.
  Combined device suite, runtime thumbnail performance, production APK build and
  installation, process/memory-pressure restoration, offline journey, production
  reinstallation and default **1,800-second soak** completed. The prior host result
  was reused for `--skip-host`; the updated full offline command above was then
  rerun after the production-code change.
- In that full gate, thumbnails traversed **5,280 pixels** against a **4,952-pixel**
  target; **20 visible previews** completed in **4,544 ms**, zero render failures.
  The telemetry's session-relative visible-grid time was 6,016 ms; it includes
  startup, unlike the separately asserted gesture-to-completion stopwatch.
- Soak peak PSS **346,207 KiB**, growth **214,060 KiB**, final mature janky-frame
  sample **1.82%**, thermal status **0**. The gate's crash/ANR check passed.
- Production-mode x86_64 APK SHA-256:
  `3fe12e4b8518dec8f10e53e88a4bbe11133c19a9e418eb37b7d44475e46caa9c`.
  This identifies the tested device artifact, not a Play AAB or all ABI builds.
- Device log: `/tmp/fractal-play-111-device-gate-fixed.log`; detailed soak and
  device evidence: `/tmp/fractal-play-111-device-gate-fixed/`.

No AAB upload or release publication occurred during the repair. Next, freeze the
release source/artifact identity, build and verify the signed Play AAB and required
ABI artifacts, recheck consumed live version codes, publish through the existing
approved uploader, and read back its exact version/hash/production status.
Retain debug-journey, signed-device-APK and AAB evidence as distinct identities;
none is an automatic substitute for another. The [release policy](../release/MULTIPLATFORM.md)
and existing task verdicts are not waived or marked complete by this note.
