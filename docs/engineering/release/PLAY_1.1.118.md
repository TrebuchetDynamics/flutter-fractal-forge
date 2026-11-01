# Google Play publication: 1.1.118 (118)

## Confirmed production operation

- Existing package: `com.trebuchetdynamics.fractal.forge`.
- Production track, API status **completed**.
- Play edit: `13806417788945048590`.
- Receipt timestamp: `2026-11-01T18:01:51.087671+00:00`.
- Frozen source: `f3929fd8a9ca0b37e4c89fc3dfb8316209ccd221`.
- AAB SHA-256:
  `90a7ef353cb34729c810acaadd13a284b0c835508f55c61e7eaa5b078126fd3a`.

An independent `scripts/ci/play-readback.sh 118 <exact-aab-sha256>` returned
`found: true`, `conflict: false`, and the exact version/production/completed
identity.

**Google review status, storefront propagation and end-user availability were
not independently observed.** No listing payload was sent by this upload; the
existing listing was not changed by this edit.

## What changed

- Seven-action viewer rail with compact icon-only phone layout.
- Rapid palette, controls, random and previous-fractal actions, with long-press
  settings surfaces.
- Random-fractal category filter.
- Responsive catalog header for Spanish/narrow screens.
- Centered, width-limited settings content on larger screens.

## Qualification

Pinned Flutter **3.44.6**, Dart **3.12.2**, unchanged lockfile
`22b29dbd8f71276012a54b9bdc62ba88408f967a86b34075986c17e1c4506ec3`.

- Shared release gate: analyzer clean; Flutter **3,387 passed, 9 skipped**.
- Separate Python/Bats gate: **454 passed, 1 skipped, 148 subtests**; Bats
  **25 passed**.
- Waydroid `192.168.240.112:5555`, Android 13, x86_64, container evidence:
  combined integrations **12 passed, 8 skipped**; thumbnails **1 passed**;
  production install/deep link/restoration/offline passed; 300-second soak PSS
  growth **42,865 KiB**, peak **180,719 KiB**, janky **3.12%**, thermal **0**,
  no crash/ANR.

## Signed artifacts

| Artifact | Bytes | SHA-256 |
| --- | ---: | --- |
| AAB | 73,128,139 | `90a7ef353cb34729c810acaadd13a284b0c835508f55c61e7eaa5b078126fd3a` |
| arm64-v8a APK | 21,710,405 | `7b29ddd85125d18431db3d23d9d65e3329c7b3a3e7253da9a85ca7420dd02fd1` |
| armeabi-v7a APK | 21,449,487 | `c865a62c327cdf77aeb4dc6b76662e0ef7e81078b644e1ea16ff1c8680bc05c0` |
| x86_64 APK | 21,905,700 | `08d1416a7d4c77e8fae00f92810b819e282ebaf86dd3f123c3c03b38a8daa0d2` |

Upload certificate SHA-1:
`1F:01:3D:4F:BE:48:4B:DA:4B:1F:49:3F:DF:0C:F0:37:1D:46:E0:58`.

See [all-platform record](ALL_PLATFORMS_1.1.118.md) for omitted lanes.
