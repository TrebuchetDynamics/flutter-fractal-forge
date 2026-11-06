# Google Play publication: 1.1.121 (121)

## Confirmed production operation

- Existing package: `com.trebuchetdynamics.fractal.forge`.
- Published to the existing **production** track with API status **completed**.
- Committed Play edit: `14075801753851487859`.
- Receipt timestamp: `2026-11-06T06:16:04.138380+00:00`.
- Release source: `d2046cf7` (`chore(release): prepare 1.1.121`) on `main`,
  based on `b1e51d4d` (`docs(tasks): close MAIN-VIEWER-LOOPER-GESTURE-REPAIR-01`).
- AAB: 73,425,108 bytes, SHA-256
  `57629f73851c471e0c9fae65c774da7a8eeec74c2e07b0fc42771461d8206f76`.

An independent readback returned:

```json
{"found": true, "conflict": false, "versionCode": "121", "track": "production",
 "status": "completed",
 "aabSha256": "57629f73851c471e0c9fae65c774da7a8eeec74c2e07b0fc42771461d8206f76"}
```

A fresh `scripts/ci/play-status.sh` lists release `121 completed` and latest
consumed version code `121`.

Google review status, storefront propagation and end-user availability were not
observed. No listing payload was sent by this upload; the existing listing was
not changed by this edit.

## Why 1.1.121

Play production already carried **1.1.120 (120)** (receipt
`2026-11-03T22:56:22Z`, AAB `d94f29a6…`, source `17e13595`). Version code 120 is
consumed, so this release takes 121 from the then-current `main`. The stored 121
bundle hash differs from the stored 120 hash, so it is a new artifact, not a
repeat upload. `fdroid/version.properties` now carries `1.1.121`/`121`.

## What changed since the published 1.1.120

- Export, Copy view link, Share image and Wallpaper sit behind one primary
  **Save & share** button. The four rows left the More sheet.
- Play runs the camera looper; hold Play to build or edit the path. The
  parameter-breathing animation is gone.
- The rail, the Save & share sheet and the More sections read one declarative
  viewer-tool table, so an action cannot drift between surfaces.

## Qualification

Pinned Flutter **3.47.9**, Dart **3.13.7**, lockfile SHA-256
`d759c63037e4d4f29a7c09b14886854fb8caa832c41f1172ec684a5cdcb7145b`.

- **Shared offline gate**: passed on `d2046cf7` in an earlier invocation of the
  same pipeline (pub get, analyzer, Flutter host tests, Python tests, Bats).
  The publishing invocation skipped the rerun with `--skip-gate` so a fresh
  device connection would not expire during the 18-minute host gate. The
  evidence file therefore records `shared_offline_gate: skipped`, not passed.
  Retained logs:
  `/tmp/release-play-artifacts-121-release/pre-release-offline-gate-run1.log`
  and `pre-release-offline-gate-run3.log`.
- **Device gate**: passed on Waydroid `192.168.240.112:5555`, Android 13,
  x86_64. Container evidence, not physical-device or hardware-GPU proof.
  - Combined integration suite: **12 passed, 8 skipped**.
  - Rapid-scroll catalog thumbnail performance: **1 passed**
    (first thumbnail 4,008 ms, under the 5-second budget).
  - Production-mode device artifact: built, installed and exercised;
    critical-memory, process-death/restoration and offline journeys passed.
  - 300-second soak: PSS first 129,115 KiB, last 189,780 KiB, peak 194,543 KiB,
    growth 60,665 KiB; final janky frames **0 %** (limit 10 %); thermal status
    **0**; no crash or ANR.

## Host contention during the release

Earlier attempts failed the device gate under host load above 35 (the same
thumbnail placeholder test, and once a lost `critical_journey` test). The host
was oversubscribed by other repositories' work and several agent gates. The
publishing run completed at load near 6. This is an environment condition, not
a product change.

## Evidence

- `release-play-evidence.json` and `PLAY_RECORD_STUB.md` under
  `/tmp/release-play-artifacts-121-release/`.
- Device-gate logs and soak/thermal/crash evidence under
  `/tmp/release-play-artifacts-121-release/gates/`.
- AAB retained at
  `/tmp/release-play-artifacts-121-release/fractal-forge-v1.1.121-build121-2026-11-06.aab`.

## Limits

- Google review, storefront propagation and end-user availability are not
  observed.
- Waydroid results are container evidence. They do not replace physical-device
  or hardware-GPU qualification.
- The shared offline gate was not rerun inside the publishing invocation; the
  skip is recorded. The pass on the same immutable commit is cited above.
- Commits merged to `main` after `d2046cf7` are not part of this Play artifact.
