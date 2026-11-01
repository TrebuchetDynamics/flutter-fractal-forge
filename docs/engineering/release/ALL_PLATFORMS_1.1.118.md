# All-platform release 1.1.118 — partial

## Result

Google Play production publication succeeded for **1.1.118 (118)**. The other six
lanes did not qualify or had no configured publication path. No GitHub release,
web deployment, F-Droid submission or Apple/Windows artifact was published.

Frozen source: `f3929fd8a9ca0b37e4c89fc3dfb8316209ccd221`.
Pinned Flutter **3.44.6**, Dart **3.12.2**, lock SHA-256
`22b29dbd8f71276012a54b9bdc62ba88408f967a86b34075986c17e1c4506ec3`.

The release ran in a detached clean worktree so concurrent Autowork commits could
not enter the artifacts. A first prepare on the canonical checkout was rejected
because an Autowork merge changed `HEAD` after the campaign froze its identity:
the artifacts recorded `f3929fd8`, while the campaign expected `8624efcc`. It was
retained as failed evidence and published nothing. The clean worktree rerun
passed.

## Android / Google Play

- Existing package `com.trebuchetdynamics.fractal.forge`.
- Production track, API status **completed**.
- Play edit: `13806417788945048590`.
- Receipt timestamp: `2026-11-01T18:01:51.087671+00:00`.
- Exact AAB readback: `found: true`, `conflict: false`, version code `118`,
  production/completed, SHA-256
  `90a7ef353cb34729c810acaadd13a284b0c835508f55c61e7eaa5b078126fd3a`.

| Artifact | Bytes | SHA-256 |
| --- | ---: | --- |
| AAB | 73,128,139 | `90a7ef353cb34729c810acaadd13a284b0c835508f55c61e7eaa5b078126fd3a` |
| arm64-v8a APK (1182) | 21,710,405 | `7b29ddd85125d18431db3d23d9d65e3329c7b3a3e7253da9a85ca7420dd02fd1` |
| armeabi-v7a APK (1181) | 21,449,487 | `c865a62c327cdf77aeb4dc6b76662e0ef7e81078b644e1ea16ff1c8680bc05c0` |
| x86_64 APK (1183) | 21,905,700 | `08d1416a7d4c77e8fae00f92810b819e282ebaf86dd3f123c3c03b38a8daa0d2` |

The upload certificate matched the pinned SHA-1
`1F:01:3D:4F:BE:48:4B:DA:4B:1F:49:3F:DF:0C:F0:37:1D:46:E0:58`.
The campaign did not send a listing payload, so this edit did not change the
existing store listing.

### Android device gate

Waydroid `192.168.240.112:5555`, model `WayDroid x86_64 Device`, Android 13,
x86_64. This is container evidence, not physical-device or hardware-GPU proof.

- Combined integration/rendering/accessibility: **12 passed, 8 skipped**.
- Runtime catalog thumbnails: **1 passed**.
- Production install, deep link, process restoration and offline journey passed.
- 300-second soak: PSS growth **42,865 KiB**, peak **180,719 KiB**; janky
  **3.12%** (limit 10%); thermal status **0**; no crash or ANR.
- Host WM size `1080x1888` with override `1080x1920`, font scale `1.0` remained
  unchanged.

## Other lanes

| Lane | Artifact | Qualification | Publication |
| --- | --- | --- | --- |
| F-Droid | Not built | Official `fdroid` CLI unavailable | Not attempted; `skipped-unavailable` |
| Web | `fractal-forge-web-v1.1.118.tar.gz`, 22,726,525 bytes, `a6e234fe904cae480c1f973c8e475ccafd8b12fdbc1a8711337078417abc2e0b` | Archive/manifest asset validation passed. Browser and saved-data checks need a current `AUTOWORK_PORT_BASE` allocation; none was available. No Wrangler/Cloudflare publication credential was configured. | Not published; `skipped-unavailable` |
| Linux | `fractal-forge-linux-x64-v1.1.118.tar.gz`, 21,877,477 bytes, `089b0bf22adc17d735242353f2c1b975ad8eafbb68c34123fd37f81256ce284c` | Native journey/export adapter requires a current `AUTOWORK_PORT_BASE`; retained image, EN/ES/inspired-entry and human review also remain open | No GitHub release; `skipped-unavailable` |
| Windows | Not built | No supported Windows host | `skipped-unavailable` |
| macOS | Not built | No Darwin/Xcode host, signing or notarization | `skipped-unavailable` |
| iOS | Not built | No Darwin/Xcode host or approved store publisher | `skipped-unavailable` |

GitLab remained excluded. No new destination, runner, credential or paid capacity
was added.

## Verification

- Shared release gate: source integrity and privacy passed; analyzer clean;
  Flutter **3,387 passed, 9 skipped**.
- Separate full offline gate on the same source tree: Python **454 passed,
  1 skipped, 148 subtests**; Bats **25 passed**.
- Evidence: retained campaign, stage logs, release manifest, SBOM, notices,
  provenance sidecars and device logs under
  `.worktrees/release-118-20261101/release-artifacts/all-platform-1.1.118/`
  (ignored, not committed).

**Limits:** Google review status, storefront propagation and end-user availability
were not observed. Waydroid results are not physical-device qualification. The web
and Linux archives are built evidence, not published releases. The frozen source
branch `release/play-118-20261101` was pushed to GitHub `origin` and read back at
`f3929fd8a9ca0b37e4c89fc3dfb8316209ccd221`; canonical `main` remains a separate
integration target.
