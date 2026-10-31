# Google Play publication: 1.1.116 (116)

## Confirmed production operation

- Existing package: `com.trebuchetdynamics.fractal.forge`.
- Published to the existing **production** track with API status **completed**.
- Uploader receipt timestamp: **2026-10-31T17:03:45.132725+00:00**.
- Committed Play edit: `12062026837263632486`.
- Frozen release source: `dc1fe27f4746d0cc3b1e4aad9e9eaf6b402a31d4` on
  `release/play-116-20261031`.
- AAB SHA-256:
  `9ec92f168346f87a76fc85fbe2c56731b5fb2b3dc53a20a4ab04d90b0e8d2d72`.

The prebuilt-AAB uploader exited zero after one upload, committed the production
edit and verified the track in a fresh edit. An independently invoked
`scripts/ci/play-readback.sh 116 <exact-aab-sha256>` returned `found: true`,
`conflict: false`, and the exact hash/version/production/completed identity.

**Google review status, storefront propagation and end-user availability were
not independently observed.** API `completed` does not establish those outcomes.
No website, GitLab, GitHub release, F-Droid, desktop or Apple publication was
attempted: this request and execution were Play-only. No source push happened
from the publication step; the freeze and repair commits below were delivered
separately.

## Frozen qualification

Pinned Flutter **3.44.6**, Dart **3.12.2**, and the provisioned package cache.
Python imports were revalidated with `/usr/bin/python3` before the release.

Host gate, run on the app source tree before the release fix:

```bash
flutter pub get --offline --enforce-lockfile &&
flutter analyze --no-pub && flutter test --no-pub &&
/usr/bin/python3 -m pytest test/research test/scripts -q &&
bats test/scripts/*.bats
```

Analysis found no issues. Flutter: **3,359 passed, 8 skipped**. Python:
**454 passed, 1 skipped, 148 subtests passed**. Bats: **25 passed**. The only
later source change is `integration_test/flows/user_flows_test.dart`, which
`flutter test` does not execute.

### Device gate

Waydroid `192.168.240.112:5555`, native model `WayDroid x86_64 Device`, Android 13,
x86_64. This is **Waydroid emulator/container evidence, not physical-device or
hardware-GPU qualification**.

- Combined journeys/rendering/performance/accessibility: **12 passed, 8 skipped**.
- Runtime catalog thumbnails: **1 passed**, 117 requests, 5,486 ms; real GPU
  readback enabled with `FORCE_RUNTIME_CATALOG_THUMBNAILS`/`FORCE_GPU_RENDER`.
- Production install, deep-link viewer session, critical memory trim, process
  death/restoration foreground and UI assertions: passed.
- Offline critical journey with Wi-Fi and mobile data disabled: **1 passed**;
  the gate restored networking.
- Production reinstall and real **300-second soak**: passed. PSS first
  **120,799 KiB**, last **172,952 KiB**, peak **187,542 KiB**, growth
  **52,153 KiB** (limits 1,048,576 / 393,216 KiB); final janky frames
  **9.68 %** (limit 10 %); thermal status **0**; crash/ANR checks passed.

### Failures and repairs retained

- The first device-gate run failed `controls sheet actions are interactive`.
  Cause: the controls hierarchy rework renamed the HUD reset icon, while the
  journey still searched `Icons.home_filled`. Repaired in `42a879bb`
  (test-only: find the reset actions by their localized tooltip). The single
  journey then passed on the device, followed by the full gate above.
- The first soak attempt ended with "Soak did not produce a mature janky-frame
  percentage sample" after `dumpsys gfxinfo` reported only 2-3 view frames.
  The existing Waydroid session had run for days. The documented unprivileged
  session restart (`waydroid session stop`, then
  `WAYLAND_DISPLAY=waydroid-headless waydroid session start`) restored sampling;
  the container was not restarted and sudo was not available or needed. The
  soak then passed with the metrics above.

## Signed artifact identities

Pinned upload certificate SHA-1:
`1F:01:3D:4F:BE:48:4B:DA:4B:1F:49:3F:DF:0C:F0:37:1D:46:E0:58`.

| Artifact | Version code | SHA-256 |
| --- | --- | --- |
| AAB | 116 | `9ec92f168346f87a76fc85fbe2c56731b5fb2b3dc53a20a4ab04d90b0e8d2d72` |
| arm64-v8a APK | 1162 | `1b8b716e156125ed564c900868097a351a9bf1b521e5d3f39ce6af01c5ee1fbc` |
| armeabi-v7a APK | 1161 | `8c93bfb6e5e1976986291094795e3f3ef5ed27065e332a75c82d17f526b3ccda` |
| x86_64 split APK | 1163 | `ad7a907021c27d3a98d48f2379da512e7779020f617da90ea5cf2fe3328f79d6` |

The gate's production-mode device APK (version code 116, x86_64) has SHA-256
`e4e587c1befa4e649635627afdf2abc44bf2e783db2d8280c3a5bfe07b773def`. It is not
the uploaded AAB or the 1163 split APK.

## Store listing, icon pin drift

The bundle was uploaded without a listing edit, so the existing store icon,
title and localized listings are unchanged.

`scripts/release.sh` pins the Play icon to
`bcb7ccc833272f090541e7b7b825f63a21753248a4023370198e2dbb84b4437f`, which is the
icon from `da11e148`. The approved open-spiral icon landed later in `924cb17d`
and is now `c22c4fde194800588d21ad3ef2047749bb6335ce4b3fff605c00b1a054396c41`.
The pin was never refreshed, and the uploader correctly refused the listing
update for this release. Refreshing that pin is a separate artwork-approval
decision.

## Retained receipts

In `release-artifacts/play-1.1.116/` (ignored):

- `play-publication-receipt.json`, `evidence/release-manifest.json` and
  `evidence/SHA256SUMS` (4 artifacts, verified before upload).
- `final-device-gate/` (gate, soak, memory, frames, battery, thermal and
  logcat evidence; process restoration screenshot and activity readback).
- `host-gate/host-test-tail.log` (host suite tail).

Artifact paths and hashes are bound to the frozen commit by their
`.provenance` sidecars. The release branch `release/play-116-20261031` retains
the exact published source.
