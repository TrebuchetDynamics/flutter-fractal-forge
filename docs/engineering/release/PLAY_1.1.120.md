# Google Play publication: 1.1.120 (120)

## Confirmed production operation

- Existing package: `com.trebuchetdynamics.fractal.forge`.
- Published to the existing **production** track with API status **completed**.
- Committed Play edit: `06011138170110074829`.
- Receipt timestamp: `2026-11-03T22:56:22.999089+00:00`.
- Release source: `17e13595` (`chore(release): prepare 1.1.120`) on `main`,
  whose application code is `7a6daf28`.
- AAB SHA-256:
  `d94f29a65cf68b22550344bfa7fabc69ceeea8e7661346ad6bcacb6cb174597f`.
- Live track readback (fresh edit): release name `Fractal Forge 1.1.120 (120)`,
  `versionCodes: ["120"]`, status `completed`; the stored bundle hash equals the
  uploaded AAB.

An independent `scripts/ci/play-readback.sh 120 d94f29a6…` returned
`{"found": true, "conflict": false, "versionCode": "120", "track": "production",
"status": "completed", "aabSha256": "d94f29a6…"}`.

No listing payload was sent by this upload; the existing listing was not changed
by this edit. **Google review status, storefront propagation and end-user
availability were not independently observed.**

## Why 1.1.120, not 1.1.119

Play production already carried **1.1.119 (119)** (receipt `2026-11-02T06:11:15Z`,
AAB `4cc1fa2d…`, built at Flutter 3.44.6 from `3b9f8f7e`). Version code 119 is
consumed, so this release takes 120 from `main`. The stored 120 bundle hash
(`d94f29a6…`) differs from the stored 119 hash, so this is a new artifact rather
than a repeat upload. The committed release identity
(`fdroid/version.properties`) is now `1.1.120`/`120`.

## What changed since the published 1.1.119

- One shader per fractal family with a power control: Mandelbar, Multibrot,
  Tricorn, Celtic, Buffalo and Perpendicular merges behind the controls.
- New three-term mix and affine-plane slice families.
- Translucent glass HUD derived from declarations and owning its geometry; the
  live transparent-fractal toggle is gone.
- Viewer list rows no longer paint a second, centred tool circle.
- Root-finding order-16 rename and regrouped formula pins.
- Toolchain: Flutter **3.47.9** / Dart **3.13.7** (published 119 used 3.44.6).

## Qualification

Pinned Flutter **3.47.9**, Dart **3.13.7**, unchanged lockfile
`d759c63037e4d4f29a7c09b14886854fb8caa832c41f1172ec684a5cdcb7145b`.

- Shared offline gate from the execution checkout root:
  `flutter pub get --offline --enforce-lockfile` regenerated only local metadata
  and left `pubspec.lock` unchanged; `flutter analyze --no-pub` clean;
  `flutter test --no-pub` **3,471 passed, 9 skipped**.
- Separate Python/Bats gate: **454 passed, 1 skipped, 148 subtests**; Bats
  **25 passed**.
- Device gate (`scripts/pre-release-gate.sh --skip-host --device
  192.168.240.112:5555 --disposable-device 192.168.240.112:5555
  --build-name 1.1.120 --build-number 120`), Waydroid Android 13, x86_64,
  container evidence: combined integration suite **12 passed, 8 skipped**;
  rapid-scroll runtime thumbnail performance **1 passed**; production-mode APK
  built and installed; deep link, `RUNNING_CRITICAL` trim, process death,
  restoration to `MainActivity` with the Julia viewer, offline journey and
  300-second soak all passed. Soak PSS first **134,685 KiB**, last
  **171,388 KiB**, peak **183,855 KiB**, growth **36,703 KiB**, janky frames
  **3.12%**, thermal status **0**, no crash/ANR marker.

One earlier device-gate attempt aborted with four `did not complete` results in
`integration_test/flows/user_flows_test.dart` after the semantics narrative, with
no app crash, ANR or connection error in logcat or the gate log. The identical
combined invocation then passed standalone (**12 passed, 8 skipped**) and the full
gate passed on its rerun; the first attempt is retained as a flake, not as a pass.

## Signed artifacts

| Artifact | Bytes | SHA-256 |
| --- | ---: | --- |
| AAB | 73,425,478 | `d94f29a65cf68b22550344bfa7fabc69ceeea8e7661346ad6bcacb6cb174597f` |

Upload certificate SHA-1:
`1F:01:3D:4F:BE:48:4B:DA:4B:1F:49:3F:DF:0C:F0:37:1D:46:E0:58`.

Retained under `release-artifacts/play-1.1.120/`: the AAB and its `.sha256`, plus
`play-publication-receipt.json`.

## Limits

This is a Play-only release. No GitHub tag/release, web deployment, Linux
tarball, F-Droid submission or Apple/Windows artifact was produced or revalidated
by this operation, and the 1.1.119 lane record still governs those lanes.
Waydroid results are container evidence, not physical-device or hardware-GPU
proof. Storefront propagation, Google review outcome and installed-user
availability remain external outcomes. This document does not authorize a new
destination, paid capacity or credential change.
