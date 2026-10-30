# Google Play publication: 1.1.115 (115)

## Confirmed production operation

- Existing package: `com.trebuchetdynamics.fractal.forge`.
- Published to the existing **production** track with API status **completed**.
- Uploader receipt timestamp: **2026-10-30T17:52:41.981141+00:00**.
- Committed Play edit: `06249394947947202396`.
- Frozen release source: `f9c7e1a7911e868e7439940ce4170c2faec4f8c8` on
  `release/play-115-waydroid-20261030`.
- AAB SHA-256:
  `1247cd81a60956abe9f631a3ed3cd01f72cb6f172d1f00d5a7a29357fa3ea5b7`.

The existing prebuilt-AAB uploader exited zero after one upload, committed the
production edit and verified the track in a fresh edit. An independently invoked
`scripts/ci/play-readback.sh 115 <exact-aab-sha256>` returned `found: true`,
`conflict: false`, and the exact hash/version/production/completed identity.
Immediately before upload, all-track/bundle/APK inventory still had maximum
consumed code **112**, and exact-115 readback found no existing version/conflict.

**Google review status, storefront propagation and end-user availability were
not independently observed.** API `completed` does not establish those outcomes.
No website, GitLab, GitHub release, F-Droid, desktop or Apple publication was
attempted: this request and execution were Play-only. The existing website was
not changed. No source push, release tag or canonical-main integration was made.
This report is a subsequent documentation-only commit, not the tested source.

## Frozen qualification

Pinned Flutter **3.44.6**, Dart **3.12.2**, and the existing provisioned package
cache were selected. Python imports were revalidated using `/usr/bin/python3`.
The complete unchanged offline gate passed:

```bash
flutter pub get --offline --enforce-lockfile &&
flutter analyze --no-pub && flutter test --no-pub &&
/usr/bin/python3 -m pytest test/research test/scripts -q &&
bats test/scripts/*.bats
```

Analysis found no issues. Flutter: **3,163 passed, 8 skipped**. Python:
**454 passed, 1 skipped, 148 subtests passed**. Bats: **25 passed**.
`pubspec.lock` was unchanged, SHA-256
`22b29dbd8f71276012a54b9bdc62ba88408f967a86b34075986c17e1c4506ec3`.
Source remained clean and at the frozen identity through qualification and
publication. The metadata-only freeze changed the version properties and matching
115 changelog; no app, shader or qualification code changed.

The existing `android_play` lane built the signed AAB and three ABI APKs, verified
provenance and the pinned upload certificate, then ran `pre-release-gate.sh
--skip-host` with build name/code 1.1.115/115. The just-passed complete host gate
was the basis for `--skip-host`; no device stage was waived. A genuine allocated
100-port lease was held through each qualification invocation, with private
scratch outside the checkout. Matching device/disposable-device IDs encoded the
standing Waydroid test consent.

Device: `192.168.240.112:5555`, native model `WayDroid x86_64 Device`, Android 13,
x86_64. This is **Waydroid emulator/container evidence, not physical-device or
hardware-GPU qualification**.

- Combined journeys/rendering/performance/accessibility: **12 passed, 8 skipped**.
- Runtime thumbnails: **1 passed**, 28 visible previews in **4,247 ms**, zero render
  failures; the five-second limit was unchanged.
- Production build/install, Julia deep-link session, real critical-memory signal,
  process death/restoration and UI/foreground assertions: passed.
- Offline critical journey with Wi-Fi/mobile data disabled: **1 passed**; network
  settings restored by the gate. No standalone lifecycle-restoration test file
  exists in this source, so that conditional stage did not run; the production
  process/trim-memory restoration checks above actually ran.
- Production reinstall and real default **300-second soak**: passed. Peak PSS
  **183,692 KiB**, growth **50,773 KiB**, final janky frames **9.68%** (limit 10%),
  thermal status **0**; crash/ANR gate checks passed.

The initial builder stopped before compilation because the isolated checkout
lacked ignored `android/key.properties`. Its failure is retained. A checkout-local
ignored symlink to the authorized canonical config fixed resolution; its existing
absolute keystore reference was retained. No signing secrets were copied into
source/evidence or credentials changed. The resumed builder and gate passed.

## Signed artifact identities

Independent inspection rechecked the four receipt hashes, sidecars, source/lock,
package, version, ABI codes and pinned signing certificate, then generated and
verified checksums, CycloneDX SBOM, native inventory, notices and bound raw
qualification evidence before upload and verified the manifest again afterward.
Pinned upload certificate SHA-1: `1F:01:3D:4F:BE:48:4B:DA:4B:1F:49:3F:DF:0C:F0:37:1D:46:E0:58`.

| Artifact | Version code | SHA-256 |
| --- | --- | --- |
| AAB | 115 | `1247cd81a60956abe9f631a3ed3cd01f72cb6f172d1f00d5a7a29357fa3ea5b7` |
| arm64-v8a APK | 1152 | `266ebbf88ac0254aaa1dc32eacb6ca8d00d64ea61aa285b4e557e7456b497c6b` |
| armeabi-v7a APK | 1151 | `69cef44cc944fac74d8477793c8496468087488e58bac704686def858ebb5b4e` |
| x86_64 split APK | 1153 | `c99d8ac238045cf084daa54922cb555e7e9e8b17538092967dad9de5d64b9c6a` |

The separately built **production-mode device APK**, version code 115, SHA-256
`0f49e5d6ef20a695d7ddabc9816ff4575382efe5d58b797a2fde8a73d6223718`,
was pulled from the actual installed package and byte-compared to the gate's
`app-release.apk`; package/version/x86_64 ABI and pinned certificate matched.
It is not the 1153 split APK or the uploaded AAB. Export proof below ran on this
installed signed production candidate after the complete gate.

## Fresh production Save / MediaStore / Gallery proof

Actual UI gestures edited Mandelbrot x/y and Mandelbulb rx/ry. Before/after view
links, UI dumps and canvas screenshots retain the real state and formula identity.
Mean absolute canvas RGB differences after the gestures were respectively
**40.77** and **8.72** (0–255 scale, fixed interior crop). No stored session was
rewritten to simulate the journey. The actual export sheet showed PNG, Screen
size **1080×1920**, and the real **Save image** action was used.

| Module | Fresh filename | MediaStore ID | Sampled RGB colors | PNG SHA-256 |
| --- | --- | --- | --- | --- |
| Mandelbrot | `fractal_mandelbrot_1793382525884.png` | 1000000411 | 6,167 | `ecb0183603fe56f20095da8228b5bfb92a8ea854256ab2887eaada89508d3314` |
| Mandelbulb | `fractal_mandelbulb_1793382574340.png` | 1000000412 | 4,794 | `a6238f0713ced4341f4c3b5b1e3da28db866fda30891c484f621de6e68da5c11` |

Both PNGs fully decoded at **1080×1920**, were byte-identical between that run's
app-private export and exact MediaStore content URI, and reported `is_pending=0`,
`mime_type=image/png`, `relative_path=Pictures/FractalForge/`. Colors were counted
at 180×320 sampling. Both exact URIs opened with a read grant in real Android
Gallery, with resumed-activity readback and decoded screenshots. Agent screenshot
inspection showed a black Mandelbrot set with cyan boundary on pink, and an
orange detailed 3D Mandelbulb on a dark background; this is not attributable human
composition approval. Only the current portrait orientation was directly tested
by this retained signed-PNG proof.

The first proof reader assumed app-private `Pictures`; the actual directory is
`files/pictures/FlutterFractals`. Save had succeeded. That attempt/error is
retained separately, and the corrected read-only path reader recreated both
fresh outputs and passed. No production export code or assertion was changed.

## Retained receipts

In this worktree's ignored `release-artifacts/play-1.1.115/`:

- `play-publication-receipt.json`, `play-post-publication-readback.json`,
  `publication-result.json`, `upload.log`, pre-upload inventories/readback and
  single-attempt marker; `PUBLICATION_SHA256SUMS` verifies these and binds the
  qualification manifest/checksum file.
- `evidence/release-manifest.json`, `evidence/SHA256SUMS`, SBOM, notices, native
  inventory, source qualification, independent artifact verification and raw
  qualification archive. Manifest verification passed for all four artifacts.
- `stage-logs/` (offline checks and original signing-path failure),
  `stage-logs-build-resume/`, `final-device-gate/`, host/Python/Bats logs, exact
  artifact sidecars, `frozen-identity.json` and `android-play-candidate.json`.
- `signed-export-proof/`: executed verifier/command log, pulled installed APK,
  certificate/badging, before/after state and screenshots, actual Save options,
  decoded app/MediaStore PNGs, MediaStore rows and Gallery readback/screenshots.
  `signed-export-proof-attempt1/` retains the path-reader failure.

Private execution scripts/logs are also retained at the canonical repository's
`.git/release-play-20261030/ready/`; they are not tracked source. Preserve these
local artifacts before cleaning the worktree. Source integration and any remote
source publication remain separate from the completed Play production operation.
