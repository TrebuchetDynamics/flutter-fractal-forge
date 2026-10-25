# Google Play upload: 1.1.111 (111)

## Confirmed publication operation

- Package: `com.trebuchetdynamics.fractal.forge`.
- Committed to existing **production** track with API release status **completed**.
- Publication timestamp: **2026-10-25T00:37:26.647777+00:00**.
- Built from local release commit
  `5f00e5a384faf1b6be1656f17277f5851feeec73` on
  `release/play-1.1.111-20261025`.
- AAB SHA-256:
  `a1e27a4bad1df4ddbdf938badcb35d72f54d61e8ef6c4befbf10400ac9255fee`.
- Existing uploader returned success and verified the committed track in a fresh
  Play edit. A separate `scripts/ci/play-readback.sh 111 <aab-sha256>` then returned
  `found: true`, `conflict: false`, matching the exact bundle hash and
  production/completed identity.

This is a real AAB upload and committed production-track operation, not merely
preparation. **Google review status, storefront propagation and availability to
end users were not independently checked.** API `completed` alone does not prove
those outcomes.

## Qualification and source identity

The full pinned offline gate passed: clean analysis, 2,990 Flutter tests passed
with 8 skipped; 282 Python tests passed with 1 skipped and 103 subtests passed;
25 Bats checks passed. The full Android pre-release gate for 111 passed, including
production-mode APK installation, process/memory-pressure restoration, offline
checks and the default 1,800-second soak. The runtime-thumbnail gate retained its
five-second end-to-end deadline and zero-render-failure requirement.

An isolated clean release worktree committed the tested local fixes. Intervening
main commits touched tests/task records only. All 1,119 tracked runtime/build
inputs under `lib`, `shaders`, `assets`, `android`, `scripts`, `pubspec.yaml` and
`pubspec.lock` were compared byte-for-byte with the tested checkout before the
release build. Their ordered path/NUL/content SHA-256 was
`855e6db82791efeb86a58a085ca8fe4bd7374c29589830ca8fff3df39c773afd`.
This records content equivalence, not a claim that earlier logs ran at the later
local commit. No qualification was inferred from unrelated main changes.

The existing Android build stage produced the AAB and three signed ABI APKs,
verified package/version/ABI identities and the pinned upload certificate, and
verified artifact provenance. The final evidence manifest, checksums, SBOM,
notices, test logs and source-equivalence receipt were verified before upload and
again afterward. Only the Play uploader was invoked; no GitLab, website, GitHub,
F-Droid or Apple publication occurred. No repository push or release tag was made.

Fresh PNG/gallery proof was recreated on the installed signed production-mode
111 APK after older debug-journey scratch receipts had been cleaned up. Its exact
APK SHA-256 was independently verified as
`3fe12e4b8518dec8f10e53e88a4bbe11133c19a9e418eb37b7d44475e46caa9c`.
Mandelbrot and Mandelbulb viewers were panned, exported with selected screen-size
resolution, decoded at **1080×1920**, byte-matched between app exports and actual
MediaStore URIs, and opened in Android Gallery. Both records had `is_pending=0`,
`image/png`, and `Pictures/FractalForge/`. Sampled RGB colors were respectively
6,280 and 4,571 (180×320 sampling).

- Mandelbrot: `fractal_mandelbrot_1792888549382.png`, MediaStore ID `1000000393`,
  SHA-256 `28a871eb6c201b991c2ab9a081c73b7870664aa5e1ccb39ed9f33e12c4afa6e5`.
- Mandelbulb: `fractal_mandelbulb_1792888572876.png`, MediaStore ID `1000000394`,
  SHA-256 `285fc778321366e4a6114406ecd3f202490058bb1d03cae3e92222f93940292f`.

## Retained receipts

Under the local release worktree's ignored
`release-artifacts/play-1.1.111/` directory:

- `play-publication-receipt.json`: uploader's committed-edit/track receipt.
- `play-post-publication-readback.json`: independent bundle/hash/track readback.
- `evidence/release-manifest.json` and `evidence/SHA256SUMS`: verified four-artifact
  manifest plus bound qualification evidence.
- `source-qualification.json`, `common-gate.log`, `device-gate.log`, `build.log`,
  `upload.log`, and pre-upload Play inventory/readback.
- `signed-export-proof/`: readback JSON, decoded PNGs, before/after pan and gallery
  screenshots, export-option UI snapshots and the executed verification script.

These local artifacts contain no signing keys or service-account material and
were not committed. Preserve them before cleaning the worktree. Repository fixes
and this publication record are local commits; canonical-main integration and
remote publication of repository changes are separate outcomes.
