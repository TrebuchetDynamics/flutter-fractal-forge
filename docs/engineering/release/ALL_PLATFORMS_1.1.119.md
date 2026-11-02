# All-platform release 1.1.119 — partial

## Result

Google Play production publication succeeded for **1.1.119 (119)**. The other six
lanes did not qualify or had no configured publication path. No GitHub release,
web deployment, F-Droid submission or Apple/Windows artifact was published.

Frozen source: `3b9f8f7e462b6353a057ce0c9d4a72ae3050023a` on branch
`release/all-119-20261101-231609`, one metadata commit above `d4538a2a`.
Pinned Flutter **3.44.6**, Dart **3.12.2**, lock SHA-256
`22b29dbd8f71276012a54b9bdc62ba88408f967a86b34075986c17e1c4506ec3`.

The campaign ran in a detached worktree so concurrent Autowork commits could not
enter the artifacts. One prepare attempt failed before publication because the
fresh worktree had no `android/key.properties`; `build-play-console.sh` refused
with `Missing android/key.properties`. Its stage logs are retained as failed
evidence. The rerun copied the existing local signing properties into the
ignored worktree path and passed.

## Android / Google Play

- Existing package `com.trebuchetdynamics.fractal.forge`.
- Production track, API status **completed**.
- Play edit: `17256434855804013630`.
- Exact AAB readback: `found: true`, `conflict: false`, version code `119`,
  production/completed, SHA-256
  `4cc1fa2d663eef02eebfbb878f21690e7b14e0e1324cf15fd2e4e23a0bde7136`.
- `postCommitVerified: true` in the publication receipt.
- Release notes come from `fastlane/metadata/android/en-US/changelogs/119.txt`.

| Artifact | Bytes | SHA-256 |
| --- | ---: | --- |
| AAB | 73,159,342 | `4cc1fa2d663eef02eebfbb878f21690e7b14e0e1324cf15fd2e4e23a0bde7136` |
| arm64-v8a APK (1192) | 21,723,348 | `97da2dc61fd49bcd6734f49b8b10ee664c841b6e3a51abf9710091f13010ca02` |
| armeabi-v7a APK (1191) | 21,461,582 | `adca0ebd4899db34990bbc22b008136637c7ef3ac49dc50af760f41c619ed1d1` |
| x86_64 APK (1193) | 21,915,843 | `849a17eeeec9e5ef9e31bbdc28072ff077b56b0cf93a62392bbcdf2957d7d039` |

The upload certificate matched the pinned SHA-1
`1F:01:3D:4F:BE:48:4B:DA:4B:1F:49:3F:DF:0C:F0:37:1D:46:E0:58`.

### Android device gate

Waydroid `192.168.240.112:5555`, model "WayDroid x86_64 Device", Android 13,
x86_64. This is container evidence, not physical-device or hardware-GPU proof.

- Combined integration/rendering/accessibility: **12 passed, 8 skipped**.
- Runtime catalog thumbnails: **1 passed**.
- Production install, deep link, process restoration and offline journey passed.
- 300-second soak: PSS growth **65,392 KiB**, peak **193,646 KiB**; janky
  **6.25%** (limit 10%); thermal status **0**; no crash or ANR.
- Host WM size `1080x1888` with override `1080x1920`, font scale `1.0` remained
  unchanged.
- The gate replaced the previously installed 118 build under the standing
  disposable-device consent.

## Other lanes

| Lane | Artifact | Qualification | Publication |
| --- | --- | --- | --- |
| F-Droid | Not built | Official `fdroid` CLI unavailable | Not attempted; `skipped-unavailable` |
| Web | `fractal-forge-web-v1.1.119.tar.gz`, 22,724,099 bytes, `0e56f7f89ab790b4c9f25cab8fd0eee6c8553a0520ebaba38234d7d3b671d3c6` | Archive/manifest asset validation passed. Browser and saved-data checks need a current `AUTOWORK_PORT_BASE` allocation; none was available. | Not published; `skipped-unavailable` |
| Linux | `fractal-forge-linux-x64-v1.1.119.tar.gz`, 21,894,818 bytes, `5d790482f7698d0cab2da77f973409be6367bf4e126b047e05d048cba744fa73` | Native journey/export adapter requires a current `AUTOWORK_PORT_BASE`; retained image, EN/ES/inspired-entry and human review also remain open | No GitHub release; `skipped-unavailable` |
| Windows | Not built | No supported Windows host | `skipped-unavailable` |
| macOS | Not built | No Darwin/Xcode host, signing or notarization | `skipped-unavailable` |
| iOS | Not built | No Darwin/Xcode host or approved store publisher | `skipped-unavailable` |

GitLab remained excluded. No new destination, runner, credential or paid capacity
was added.

## Verification

- Shared release gate: source integrity and privacy passed; analyzer clean;
  Flutter **3,423 passed, 9 skipped**.
- Release-manifest evidence generation and verification passed.
- Separate full offline gate on the frozen tree: Python **454 passed, 1 skipped,
  148 subtests**; Bats **25 passed**.
- Evidence: retained campaign, stage logs, release manifest, SBOM, notices,
  provenance sidecars and device logs under
  `release-artifacts/` in the frozen worktree (ignored, not committed).
- Independent post-publication readback with the existing `play-readback.sh`
  lifecycle confirmed the exact AAB on production/completed.

**Limits:** Google review status, storefront propagation and end-user
availability were not observed. Waydroid results are not physical-device
qualification. The web and Linux archives are built evidence, not published
releases.
