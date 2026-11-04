# All-platform release 1.1.120 — Play and web published

## Result

**Google Play production** and the **production website** are live at **1.1.120
(120)**. The Play publication is recorded in
[PLAY_1.1.120.md](PLAY_1.1.120.md); this record adds the independent web
verification, the F-Droid lane result and the lanes that did not publish.

Frozen source: `17e13595c5aff73bca27200f6d7a72fb33c86a56`
(`chore(release): prepare 1.1.120`), whose application code is `7a6daf28`.
Pinned Flutter **3.47.9**, lockfile SHA-256
`d759c63037e4d4f29a7c09b14886854fb8caa832c41f1172ec684a5cdcb7145b`.

1.1.119 could not be reused: Play production already carried
**1.1.119 (119)** (`2026-11-02T06:11:15Z`, AAB `4cc1fa2d…`, Flutter 3.44.6 from
`3b9f8f7e`). Version code 119 is consumed, so 1.1.120 was cut from `main`.

A parallel release campaign in a clean worktree rebuilt the same 1.1.120
identity and then **correctly refused to write**: the Play readback found the
version code already consumed by a different AAB, and the Pages readback found
the deployment already present. That campaign's verified artifacts and campaign
record are retained under
`.worktrees/release-120-final/release-artifacts/lanes-1.1.120-final/` (ignored);
nothing from it was published twice.

## Google Play

- Production track, API status **completed**; committed edit
  `06011138170110074829`; receipt timestamp `2026-11-03T22:56:22.999089+00:00`.
- AAB SHA-256 `d94f29a65cf68b22550344bfa7fabc69ceeea8e7661346ad6bcacb6cb174597f`.
- Independent `scripts/ci/play-readback.sh 120 d94f29a6…` returned
  `{"found": true, "conflict": false, "versionCode": "120", "track":
  "production", "status": "completed"}`.
- Upload certificate SHA-1 unchanged (pinned
  `1F:01:3D:4F:BE:48:4B:DA:4B:1F:49:3F:DF:0C:F0:37:1D:46:E0:58`).

## Web

- Deployment `61cd48f9`, Production, branch `main`, source `17e1359`,
  `https://61cd48f9.flutter-fractal-forge.pages.dev`.
- Both origins serve `release-identity.json` for **1.1.120 / 120 / `17e13595`**
  with 598 manifest entries (597 files plus the `_headers` control).
- Deployment origin: **597/597** non-control files hash-match the manifest;
  `_headers` matches.
- `https://fractal.trebuchetdynamics.com` serves the same identity. The custom
  domain redirects `*.html` to the extensionless route with HTTP 308 (for
  example `/landing.html` → `/landing`), so a pre-redirect fetch returns an
  empty body rather than the file. Following the redirect, all three HTML entry
  points (`index.html` at `/`, `landing.html`, `privacy-policy.html`) hash-match
  the manifest too: the production origin is **597/597**.
- Archive `fractal-forge-web-v1.1.120.tar.gz`, 22,483,704 bytes, SHA-256
  `b6b4a39bc62d67bf978dfd423eb741db29858b3f056e0ddd142015be7b88ea09`
  (parallel campaign build; the live deployment carries its own manifest
  identity).

## Other lanes

| Lane | Result | Detail |
| --- | --- | --- |
| F-Droid | verified, not published | Reproducible unsigned APKs plus official `fdroid` scan passed in the parallel campaign: arm64-v8a 21,488,463 B `6b0d75bf…`, armeabi-v7a 21,226,341 B `cbd5842e…`, x86_64 21,692,562 B `ad4bcd47…`. F-Droid has no APK upload API; maintainer acceptance is external |
| Linux | built, unknown | `fractal-forge-linux-x64-v1.1.120.tar.gz`, 21,200,546 B `f9a61458…`; native journey completed, but retained edited-view PNG comparisons, EN/ES and inspired-entry coverage and human review remain open |
| Windows | skipped-unavailable | no supported Windows host |
| macOS | skipped-unavailable | no Darwin/Xcode host, signing or notarization |
| iOS | skipped-unavailable | no Darwin/Xcode host or approved store publisher |

**No GitHub release or tag was created.** The GitHub publisher runs only for a
verified native lane; Linux remains unknown, so the latest GitHub release is
still **v1.1.112**. GitLab stayed excluded.

## Verification

- Shared gate: analyzer clean; host tests **3,471 passed, 9 skipped**; source
  integrity and privacy policy passed.
- Android/Play: build, certificate check, artifact provenance and the Waydroid
  device gate passed (`192.168.240.112:5555`, container evidence only); live
  upload read back as above.
- Web: asset validation, browser journey and saved-data checks passed.
- Play and web readbacks above were repeated independently of the publishing
  process.

## Limits

Google review status, storefront propagation and end-user availability were not
observed. Waydroid results are not physical-device or hardware-GPU proof. Edge
caching of the three HTML entry points must be re-checked before claiming the
production site is byte-identical at every edge. F-Droid acceptance and Apple
store outcomes remain external. No new destination, paid capacity or credential
change was added.
