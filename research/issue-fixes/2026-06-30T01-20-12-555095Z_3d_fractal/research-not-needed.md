# Research not needed

Local rendering/catalog bug. The issue is `3d_fractal` with `Bad Thumbnail`.

Source/test evidence:
- `3d_fractal` already had a curated normal-map relief preset (`colorScheme: 59`) in `lib/core/modules/builders/escape_time_catalog/mandlebrot_sfml_batch_2.dart`.
- Default thumbnail/controller path uses the module default preset, so the default color scheme needed to match that curated high-detail look.
- Added native CPU formula/iterator coverage for `3d_fractal` so thumbnail/render fallback tests exercise the real `|z|²·z+c` recurrence instead of the synthetic fallback.
- Focused test: `/home/xel/flutter/bin/flutter test test/modules/three_d_fractal_thumbnail_test.dart`.
