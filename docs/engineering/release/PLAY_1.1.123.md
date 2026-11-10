# Google Play publication: 1.1.123 (123)

## Confirmed production operation

- Package: `com.trebuchetdynamics.fractal.forge`.
- Destination: existing **production** track, API status **completed**.
- Committed edit: `00842459079742566729`.
- Receipt timestamp: `2026-11-10T03:53:32.268425+00:00`.
- Release source: `cddb3881aa6b06d8fd61c0e2b6e43df13b4fab3e`, based on
  canonical `5e48feb573cdfbad203bbd9818e47b23df1c7a04`. Release identity was
  prepared in `93a44d87`; the gate-label repair is `cddb3881`.
- Signed AAB: 73,471,067 bytes, SHA-256
  `565a8075ee54ff539972f942f4643e6b6d34b5ac7d4b801bcbd9d7dda9eaf793`.
- Upload certificate SHA-1:
  `1F:01:3D:4F:BE:48:4B:DA:4B:1F:49:3F:DF:0C:F0:37:1D:46:E0:58`.

Independent fresh-edit readback:

```json
{"found": true, "conflict": false, "versionCode": "123", "track": "production", "status": "completed", "aabSha256": "565a8075ee54ff539972f942f4643e6b6d34b5ac7d4b801bcbd9d7dda9eaf793"}
```

A separate Play status query confirmed release `123 completed` and latest
consumed code `123`. This is not a Google review or end-user availability claim.

## Changes since published 1.1.122

The previous Play release was [1.1.122](PLAY_1.1.122.md), source `63fd0d6a`.

- Viewer tools stay in one labeled row with horizontal scrolling.
- Catalog search layout accounts for theme density and larger touch targets.
- Burning Ship rendering avoids undefined `atan(0, 0)` at the origin.
- The release gate now checks the current **Edit fractal** semantic label instead
  of obsolete **Controls**. It still requires both the Julia viewer and its edit
  control after process death. Negative tests reject missing route/control and
  the stale label. Independent source review approved this scoped repair.
- The source includes default-off Rust bridge work. This publication does not
  switch the Flutter viewer to a Rust backend or qualify that migration.

## Qualification

Final candidate: `cddb3881`. Flutter 3.47.9 / Dart 3.13.7, provisioned isolated
pub cache, `/usr/bin/python3` 3.12.3. Python prerequisite imports passed. Locked
dependency preparation regenerated this working copy's package metadata.
`pubspec.lock` stayed unchanged at SHA-256
`d919ab7eb6ad10b5939c81092b6f1657ba84642109ca677684184ccf30c55451`.

- Full offline gate: passed. Analyzer: no issues. Flutter: **3,478 passed,
  9 skipped**. Python: **504 passed, 1 skipped, 148 subtests passed**.
  Bats: **30 passed**. Skips remain recorded gaps, not executed coverage.
- Focused repair checks: **51 Python tests**, **2 Bats tests**, shell syntax and
  `git diff --check` passed before the full final-candidate runs.
- Device: designated Waydroid `192.168.240.112:5555`, native model
  `WayDroid x86_64 Device`, boot complete. No container reset or unrelated device
  operation was used. Matching device/disposable-device flags encoded standing
  consent for the documented test-app replacement cycle.
- Complete Android gate: passed on retry. Combined integration: **12 passed,
  8 skipped**. Runtime catalog thumbnails: **1 passed**. Lifecycle restoration
  and offline critical journey completed. Production-mode Julia process-death
  restoration retained screenshot, foreground and current toolbar semantics.
- Full **300-second** interaction soak: first PSS **183,275 KiB**, last
  **234,639 KiB**, peak **235,378 KiB**, growth **51,364 KiB**. Final mature
  janky-frame sample: **1.96%** (51 frames, limit 10%). Thermal status **0**.
  The gate's timestamp-bounded crash/ANR check passed.
- Signed AAB structure/package/version checks passed. Builder verified the
  declared shader bundle inventory before upload. Publication and independent
  hash readback used the exact retained AAB, not a rebuild.

### Failed attempts and recovery

1. The wrapper's default checkout-local evidence path was rejected by the offline
   gate. Retried with an external evidence directory; no gate was skipped.
2. Initial device gate failed its obsolete Controls assertion. Raw semantics
   already showed Julia and Edit fractal. The scoped repair and rejection tests
   were committed and independently reviewed, then full gates were rerun.
3. First repaired-candidate soak had only four Android frames, below the required
   ten-frame minimum. It remains a failure. The unchanged candidate's complete
   rerun passed without lowering the sample minimum or performance limits.
4. That successful pipeline exceeded the 1,800-second command deadline during
   bundle upload, before any commit was logged. No publisher remained running.
   Fresh Play status still showed 122 with 123 absent. After reconciliation,
   the supported prebuilt uploader validated and uploaded the same AAB, committed
   production/completed, and verified it in a fresh edit. Independent readback
   then confirmed code/hash/track/status. No gate-skip flag was used.

## Evidence and post-publication limits

External evidence root: `/var/tmp/ffr-play-123/`.

- Successful gate logs, archived AAB, `release-play-evidence.json`, publication
  receipt and independent readback: `retry-artifacts/`.
- Successful pipeline through interrupted upload: `pipeline-retry.log`.
- Reconciled publication: `upload-resume.log`.
- Failed attempts: `pipeline.log`, `pipeline-external.log`, `pipeline-final.log`,
  `artifacts/` and `final-artifacts/`. They were not relabeled as passes.
- Storefront observation: `retry-artifacts/play-observe.json`, observed
  `2026-11-10T03:54:08+00:00`. All 12 probed storefronts list the app, but still
  expose **1.1.122**, updated Nov 6. None yet exposes 1.1.123.
- `play-live-check.json` exits **1**: production/code checks pass; propagation
  and required direct review checks do not pass. No authorized Console review
  page was supplied, so review is **not observable**, not approved or rejected.

Waydroid evidence is container/emulator evidence, not physical-device or hardware
GPU qualification. Per-account/device installation and Google review remain
unobserved. Do not announce full storefront availability from the completed track.

This was **Play only**. F-Droid, web, Linux, Windows, macOS and iOS were not
requested, requalified or republished. GitLab CI/mirroring/releases remain excluded.
