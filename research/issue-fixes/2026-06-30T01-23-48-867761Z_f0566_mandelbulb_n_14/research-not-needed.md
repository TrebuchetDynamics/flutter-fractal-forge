# Mandelbulb n=14 low deep-zoom issue

External research was not needed. The issue share URL includes a panned 3D view for `f0566_mandelbulb_n_14`, but the shared Mandelbulb builder was not passing pan into the shader target.

Fix evidence:

- `lib/core/modules/builders/shared_catalogs/shared_3d_catalog.dart` now sends `state.view.pan.x/y` through uniform slots 3-4 for shared Mandelbulb modules.
- `shaders/3d_and_hypercomplex/raymarched_volumes/mandelbulb_time_modulated_gpu.frag` uses those slots as a raymarch target, so deep-zoom panned views render the intended region.
- `test/modules/mandelbulb_shared_pan_target_test.dart` locks the pan-target wiring and compiles the shader.

Validation:

```sh
/home/xel/flutter/bin/flutter test --reporter expanded test/modules/mandelbulb_shared_pan_target_test.dart
git diff --check
```

Result: pass.
