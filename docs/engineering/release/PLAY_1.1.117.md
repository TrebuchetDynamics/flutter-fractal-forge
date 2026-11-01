# Google Play publication: 1.1.117 (117)

## Confirmed production operation

- Existing package: `com.trebuchetdynamics.fractal.forge`.
- Published to the existing **production** track with API status **completed**.
- Uploader receipt timestamp: **2026-11-01T00:41:28.469016+00:00**.
- Committed Play edit: `06727219137645889742`.
- Frozen release source: `89647f3199b9093e19bb567663fc5bbf8106c745` on
  `release/play-117-20261031`.
- AAB SHA-256:
  `782335756605ad0e71d973dfb52528272d009f700edbf95c0542a1239108f710`.

The prebuilt-AAB uploader exited zero after one upload, committed the production
edit, verified the track in a fresh edit and recorded the approved listing icon
`c22c4fde194800588d21ad3ef2047749bb6335ce4b3fff605c00b1a054396c41`.
An independent `scripts/ci/play-readback.sh 117 <exact-aab-sha256>` returned
`found: true`, `conflict: false`, and the exact hash/version/production/completed
identity.

**Google review status, storefront propagation and end-user availability were
not independently observed.**

## What changed

- The viewer Controls panel no longer repeats palette selection (the viewer
  tools own it) and no longer offers fluid mode (toggle and intensity slider).
- A **Transparent background** toggle replaces those rows and drives the
  existing renderer flag.
- Panel padding, header, gaps and effect toggles are tighter, so the panel
  needs less vertical space at the same text scale. Touch targets stay at 48
  logical pixels, or 56 with large targets.
- Localization: new EN/ES string, removed the unused fluid strings.
- Tests: HUD, accessibility, keyboard, semantics audit, mobile layout and
  Spanish coverage updated to the new panel.

## Frozen qualification

Pinned Flutter **3.44.6**, Dart **3.12.2**. Host gate on `cbc3b776`
(the app code is unchanged at `89647f31`; later commits are docs only):

```bash
flutter pub get --offline --enforce-lockfile &&
flutter analyze --no-pub && flutter test --no-pub &&
/usr/bin/python3 -m pytest test/research test/scripts -q &&
bats test/scripts/*.bats
```

Analysis found no issues. Flutter: **3,359 passed, 8 skipped**. Python:
**454 passed, 1 skipped, 148 subtests**. Bats: **25 passed**.

### Device gate

Waydroid `192.168.240.112:5555`, native model `WayDroid x86_64 Device`, Android
13, x86_64. Emulator/container evidence, not physical-device qualification.

- Combined journeys/rendering/performance/accessibility: **12 passed, 8 skipped**.
- Runtime catalog thumbnails: **1 passed**, 117 requests, 5,094 ms.
- Production install, deep link, critical memory trim, process
  death/restoration and offline journey: passed.
- 300-second soak: PSS growth **5,372 KiB**, peak **190,428 KiB**; janky
  **2.94 %** (limit 10 %); thermal **0**; no crash/ANR.

### Incidents

- The Waydroid guest lost its network address mid-release (`IP address:
  UNKNOWN`, no ADB transport). The documented unprivileged session restart
  restored `192.168.240.112` and ADB without a container reset.
- During the release, another writer introduced uncommitted, non-compiling
  edits in the canonical checkout (`fractal_view_controls.dart`). Those edits
  were left untouched. The release was rebuilt and re-gated from a clean
  worktree at the frozen commit, so no uncommitted work entered the artifacts.

## Signed artifact identities

Pinned upload certificate SHA-1:
`1F:01:3D:4F:BE:48:4B:DA:4B:1F:49:3F:DF:0C:F0:37:1D:46:E0:58`.

| Artifact | Version code | SHA-256 |
| --- | --- | --- |
| AAB | 117 | `782335756605ad0e71d973dfb52528272d009f700edbf95c0542a1239108f710` |
| arm64-v8a APK | 1172 | `6c5c01f448435e105d9bcee150972fdd086d6b11de5febc4b1794c65a14fac7c` |
| armeabi-v7a APK | 1171 | `cfb069c01fc4c37db13240d8240c8ff7bc54efb1baba0ca7b2207bd9d9385444` |
| x86_64 split APK | 1173 | `b5b0c759c70ac3650ccd76a1821cc6b0ed899a204aaabe19ed1fc35d47e1fe3b` |

Evidence manifest (`release-artifacts/play-1.1.117/evidence`) was generated and
verified for these four artifacts at the frozen commit before upload.

## Store listing

The same Play edit carried the localized listing update with the approved
open-spiral icon, so the listing icon recorded by the receipt is
`c22c4fde…`. Listing text still matches
`docs/play-store-localized-listings.json` for all 15 locales from the separate
store refresh.

## Retained receipts

In `release-artifacts/play-1.1.117/` (ignored): publication receipt, evidence
manifest and checksums, device-gate logs (integration, thumbnails, restoration,
offline, soak), and artifact provenance sidecars.
