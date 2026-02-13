# APK Size Analysis — Release Build

**Date:** 2026-02-12
**APK:** `app-release.apk` — 28.2 MB (compressed), 64.3 MB (uncompressed)
**Commit:** post-79eba5d (l10n fix applied)

## Breakdown by Category

| Category | Size (MB) | % of APK | Notes |
|---|---|---|---|
| Native libs (libflutter.so) | 31.5 | 49% | 3 ABIs: arm64, armeabi-v7a, x86_64 |
| Native libs (libapp.so) | 24.2 | 38% | App Dart AOT code, 3 ABIs |
| Shaders (214 .frag) | 4.94 | 7.7% | Largest: mandelbulb.frag (113KB) |
| Thumbnails (197 PNGs) | 1.09 | 1.7% | 128x128 CPU-rendered previews |
| classes.dex | 1.42 | 2.2% | Android runtime |
| CupertinoIcons.ttf | 0.26 | 0.4% | iOS icon font (unused on Android) |
| Other (res, resources, etc.) | 0.89 | 1% | Launcher icons, manifests |

## Key Findings

1. **87% is native libraries** — Flutter engine + AOT Dart for 3 ABIs. Normal for Flutter.
2. **Shaders are 4.94 MB** — reasonable for 214 GLSL files. Largest is mandelbulb (113KB, 3D raymarcher). Most are 20-32KB.
3. **Thumbnails are only 1.09 MB** — negligible impact.
4. **CupertinoIcons.ttf (258KB)** is unused on Android-only app. Could remove.

## Optimization Options

| Action | Savings | Effort |
|---|---|---|
| Build per-ABI APKs (`--split-per-abi`) | ~18 MB per APK | Low (build flag) |
| Remove CupertinoIcons dependency | ~0.26 MB | Low |
| Compress shader source (minify comments/whitespace) | ~1-2 MB | Medium |
| Deferred shader loading (asset bundles) | Variable | High |

## Recommendation

Use `--split-per-abi` for Play Store upload — each user downloads only their ABI (~10 MB APK instead of 28 MB). This is the single biggest win with zero code changes.
