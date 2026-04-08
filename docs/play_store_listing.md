# Play Store Listing Metadata — Flutter Fractals

**Date:** 2026-02-13
**Package:** com.trebuchetdynamics.fractal.forge
**Developer:** ComplexChaos

---

## App Title (max 30 chars)
Flutter Fractals

## Short Description (max 80 chars)

## Full Description (max 4000 chars)

Dive into the infinite beauty of mathematics with Flutter Fractals — a free, real-time fractal explorer featuring 200+ fractals rendered with high-performance GPU shaders.

🔬 MASSIVE FRACTAL CATALOG
Browse 200+ fractals across 10 categories:
• Classic escape-time: Mandelbrot, Julia, Burning Ship, Tricorn, Celtic, Buffalo
• Newton fractals: Newton z³, Halley, Householder, Schroeder
• Chaotic attractors: Lorenz, Rössler, Clifford, Hénon, Tinkerbell, Ikeda
• IFS geometric: Sierpinski, Koch, Barnsley Fern, Dragon Curve, Pythagorean Tree
• Space-filling curves: Hilbert, Peano, Gosper, Moore, Z-order
• Tilings: Penrose, Ammann-Beenker, Hat monotile, Spectre monotile
• Lyapunov maps, cellular automata, buddhabrot variants, and more
• 3D Mandelbulb with real-time rotation

🎨 INTERACTIVE EXPLORATION
• Pinch to zoom deep into fractal boundaries
• Pan and rotate with smooth momentum gestures
• Real-time parameter sliders: iterations (up to 5000), bailout, color scheme
• Auto-explore mode finds interesting regions automatically
• Deep zoom with automatic CPU precision at extreme magnification

📸 POWERFUL EXPORT
• High-resolution PNG up to 4K with transparent background option
• Batch export with contact sheet
• Wallpaper-ready formats (home screen, lock screen)

🎯 PRESETS & DISCOVERY
• Built-in presets for every fractal
• One-tap randomize with parameter locking
• Save your own presets
• Exploration history and statistics
• Minimap for orientation during deep zoom

♿ ACCESSIBLE
• High-contrast theme
• Screen reader support with semantic labels
• Touch targets meet accessibility guidelines
• English and Spanish localization

🔧 TECHNICAL
• 214 GLSL fragment shaders with GPU acceleration
• Deterministic CPU fallback for device compatibility
• Double-precision deep zoom beyond GPU float32 limits
• Frame-pair render validation
• Local-only crash reporting (no data leaves your device)

Free. No ads. No tracking. Just math.

---

## Category
Education > Educational Games
(Alternative: Tools > Art & Design)

## Content Rating Questionnaire

| Question | Answer |
|---|---|
| Violence | None |
| Sexual content | None |
| Language | None |
| Controlled substances | None |
| User-generated content | No (only locally saved presets) |
| Data sharing | No data collected or shared |
| Ads | No ads |
| In-app purchases | None |
| Target audience | General / All ages |

**Expected rating:** PEGI 3 / Everyone

## Feature Graphic
- Resolution: 1024 x 500 px
- Content: Mandelbrot zoom with vibrant coloring, app name overlay
- File: needs creation (not yet generated)

## Screenshots (6 required, 1080x1920 or 1080x2400)
Available in `docs/store_screenshots/`:
1. `01_catalog_grid.png` — Catalog grid with real fractal thumbnails
2. `02_mandelbrot_viewer.png` — Mandelbrot viewer with CPU render
3. `03_context_menu.png` — Context menu (reset, controls, presets, export)
4. `04_catalog_scrolled.png` — Catalog scrolled showing variety
5. `05_julia_viewer.png` — Julia set viewer
6. `06_fractal_variety.png` — Additional fractal viewer

**Note:** Screenshots are from emulator. Real-device screenshots recommended before final submission for higher visual quality (GPU renders vs CPU fallback).

## App Icon
- File: `assets/icon/ic_launcher.png`
- Adaptive icon background: #0A0520
- Adaptive icon foreground: same image

## Privacy Policy URL
- Required for Play Store. Needs to be hosted (e.g., GitHub Pages or simple static page).
- Content: No data collected, no analytics, no network requests, all processing local.

## Signing
- Release APK builds successfully (28.2 MB)
- **Needs:** Upload signing key configuration for Play Store (AAB format preferred over APK)
- Command: `flutter build appbundle --release` for AAB

## Pre-Launch Checklist
- [x] App title and descriptions
- [x] Screenshots (6, emulator quality)
- [x] Content rating answers
- [ ] Feature graphic (1024x500)
- [ ] Privacy policy URL
- [ ] Upload signing key (AAB)
- [ ] Real-device screenshots (higher quality)
- [ ] App Bundle build (`flutter build appbundle`)
