# Release: 1.1.127 (127)

Independent-lane campaign `./release.sh --best-effort` on clean source `8edc42a6089fd02528d637a0e3262c10eac1ed78`, Flutter 3.47.9, frozen artifact directory `release-artifacts/lanes-1.1.127-e/`. Git tag `v1.1.127` points at that commit.

| Lane | Qualification | Publication |
|---|---|---|
| Google Play | verified | published, production, status `completed` |
| Web | verified | live; tool readback `publication-unknown`, manual readback exact (below) |
| F-Droid | verified | submitted, not published: fdroiddata !46920 updated; maintainer build and merge pending |
| Linux | not verified: journey passed; edited-view PNG comparisons, EN/ES and inspired-entry coverage and human review missing | not attempted |
| iOS, macOS, Windows | no host | not attempted |

## Google Play

`com.trebuchetdynamics.fractal.forge` was uploaded once to production, status `completed`. Receipt time: `2026-11-27T01:05:46.373506Z`; edit `08507484386802680723`; post-commit readback verified.

The signed AAB is 75,531,196 bytes, SHA-256 `2bb60103b91bcc7785bae1a761c9db44968a4a9e89a382a4863ad9888ba86296`. Upload certificate SHA-1: `1F:01:3D:4F:BE:48:4B:DA:4B:1F:49:3F:DF:0C:F0:37:1D:46:E0:58`.

## Web

Cloudflare Pages project `flutter-fractal-forge`, deployment `https://30953089.flutter-fractal-forge.pages.dev`. The campaign readback did not confirm the publication. A manual readback at 2026-11-27 showed `release-identity.json` at 1.1.127/127/`8edc42a6` on that deployment and on `https://fractal.trebuchetdynamics.com`. All 606 listed files matched their SHA-256 on the deployment, except `_headers`, which Pages does not serve. On the custom domain, `index.html`, `landing.html` and `privacy-policy.html` redirect (308) to `/`, `/landing` and `/privacy-policy`, and those pages match.

## F-Droid

The signed Play APKs cannot be reference binaries: their `lib/<abi>/libapp.so` differs from the F-Droid source build in all three ABIs. The reference APKs are therefore the reproducible F-Droid unsigned builds (codes 1271/1272/1273), signed with the upload key (certificate SHA-256 `8d5f69b91dd44476ceaad141f1fa9f6abeccdfa20cd3f7bcdfe709df623878fd`, scheme v2 only, `apksigner --alignment-preserved true`). Without `--alignment-preserved`, `apksigner` rewrites the archive and `apksigcopier compare` fails. With it, the comparison passed for all three ABIs.

They are on the GitHub release [v1.1.127](https://github.com/TrebuchetDynamics/flutter-fractal-forge/releases/tag/v1.1.127) with the fdroiddata archive. A download from the `binary:` URLs matched these SHA-256 values:

```
859498201eb707f557f9bd282dd509afca60a72568773a22006833d803d937fd  fractal-forge-android-armeabi-v7a-v1.1.127.apk
f90ffc6745e92edc0c01dba0240d378858ccbe805fe78543d9ba638661943bfb  fractal-forge-android-arm64-v8a-v1.1.127.apk
3153974a1ff77e11a6247c2f3edaca5c7bad1fc030fe8250240cdd83680f122a  fractal-forge-android-x86_64-v1.1.127.apk
```

[!46920](https://gitlab.com/fdroid/fdroiddata/-/merge_requests/46920) now has head `7d1c4b85` with the 1.1.127 metadata, which builds from the GitHub repository. Its description now names 1.1.127, and note 4336473275 asks a maintainer to run the pipeline and the original reviewer to retest KIFS Menger Sponge on Adreno 610. Fork pipelines fail at creation with no jobs (also in 2026-09). The `v1.1.127` tag is on GitHub only: the GitLab mirror rejected the stored git credential.

## Qualification

Shared checks passed: analyzer, privacy policy, source integrity and host tests (3783 passed, 9 skipped; 1742 s). Android Play device gate on Waydroid passed in 864 s: 12 passed with 8 skipped, then 1 and 1 passed; the soak ended at 2.94% janky frames (10% limit). The F-Droid gate passed the same suites, plus two reproducible builds and the source scan. The web browser journey and saved-data restoration passed. Waydroid is container evidence, not hardware qualification.

Four earlier prepares were not published. They failed on stale journeys (fixed in #94, #99, #100), a host-test timeout under load, and a second Waydroid session on the desktop display. That session put `kit-waydroid.service` in a restart loop (1815 restarts) and removed Android's package service mid-run. Stopping it fixed both Android lanes.
