# Super Halley no-shader issue

External research not needed: this is a local catalog/rendering regression.

Local evidence:
- Issue `issues/2026-06-26T18-56-29-322785Z_super_halley.json` reports module `super_halley` with note `no shader`.
- `lib/core/modules/builders/escape_time_catalog.dart` maps `super_halley` to `shaders/root_finding/super_halley_gpu.frag`.
- `pubspec.yaml` declares `shaders/root_finding/super_halley_gpu.frag` under `flutter.shaders`.
- The shader file exists locally.
- Regression risk is the shader's iteration-cap fallback looking like a missing shader; the focused test asserts the cap branch continues to root coloring instead of returning a black/transparent fragment.
