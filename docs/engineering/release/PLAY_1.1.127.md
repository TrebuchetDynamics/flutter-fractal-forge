# Release: 1.1.127 (127)

Independent-lane campaign `./release.sh --best-effort` on clean source `8edc42a6089fd02528d637a0e3262c10eac1ed78`, Flutter 3.47.9, frozen artifact directory `release-artifacts/lanes-1.1.127-e/`. Git tag `v1.1.127` points at that commit.

| Lane | Qualification | Publication |
|---|---|---|
| Google Play | verified | published, production, status `completed` |
| Web | verified | live; tool readback `publication-unknown`, manual readback exact (below) |
| F-Droid | verified | not published: no publication API; needs fdroiddata !46920 |
| Linux | not verified: journey passed; edited-view PNG comparisons, EN/ES and inspired-entry coverage and human review missing | not attempted |
| iOS, macOS, Windows | no host | not attempted |

## Google Play

`com.trebuchetdynamics.fractal.forge` was uploaded once to production, status `completed`. Receipt time: `2026-11-27T01:05:46.373506Z`; edit `08507484386802680723`; post-commit readback verified.

The signed AAB is 75,531,196 bytes, SHA-256 `2bb60103b91bcc7785bae1a761c9db44968a4a9e89a382a4863ad9888ba86296`. Upload certificate SHA-1: `1F:01:3D:4F:BE:48:4B:DA:4B:1F:49:3F:DF:0C:F0:37:1D:46:E0:58`.

## Web

Cloudflare Pages project `flutter-fractal-forge`, deployment `https://30953089.flutter-fractal-forge.pages.dev`. The campaign readback did not confirm the publication. A manual readback at 2026-11-27 showed `release-identity.json` at 1.1.127/127/`8edc42a6` on that deployment and on `https://fractal.trebuchetdynamics.com`. All 606 listed files matched their SHA-256 on the deployment, except `_headers`, which Pages does not serve. On the custom domain, `index.html`, `landing.html` and `privacy-policy.html` redirect (308) to `/`, `/landing` and `/privacy-policy`, and those pages match.

## Qualification

Shared checks passed: analyzer, privacy policy, source integrity and host tests (3783 passed, 9 skipped; 1742 s). Android Play device gate on Waydroid passed in 864 s: 12 passed with 8 skipped, then 1 and 1 passed; the soak ended at 2.94% janky frames (10% limit). The F-Droid gate passed the same suites, plus two reproducible builds and the source scan. The web browser journey and saved-data restoration passed. Waydroid is container evidence, not hardware qualification.

Four earlier prepares were not published. They failed on stale journeys (fixed in #94, #99, #100), a host-test timeout under load, and a second Waydroid session on the desktop display. That session put `kit-waydroid.service` in a restart loop (1815 restarts) and removed Android's package service mid-run. Stopping it fixed both Android lanes.
