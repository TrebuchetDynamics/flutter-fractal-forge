# Thumbnail Integrity Report
**Generated:** 2026-02-13 16:55 CST  
**Commit:** (current working tree)

## Summary
- **CPU thumbnails (assets/catalog_thumbs/):** 199 files, valid fractal content
- **GPU thumbnails (emulator attempt):** 197 files, 99.8% black pixels (SwiftShader rendering failure)
- **Shipped:** CPU thumbnails (GPU blocked on emulator)

## CPU Thumbnails (Current Assets)
```
Total files: 199
Sample color counts:
  mandelbrot: 243 unique colors
  burning_ship: 443 unique colors
  tricorn: 204 unique colors
  phoenix: 198 unique colors
```

**Status:** ✅ Valid, rendering correctly in app after catalogId prefix fix (commit e926c16)

**Known limitation:** CPU renderer supports ~8 distinct formulas; remaining fractals render as variants with different color palettes.

## GPU Thumbnails (Emulator Generation Attempt)
```
Total files: 197
Sample color counts:
  mandelbrot: 21 unique colors (65381/65536 black pixels = 99.8%)
  burning_ship: 21 unique colors (65381/65536 black pixels = 99.8%)
  tricorn: 21 unique colors (65381/65536 black pixels = 99.8%)
```

**Status:** ❌ Invalid — emulator GPU (SwiftShader) compiles shaders but produces all-black output

**Root cause:** Documented in `docs/gpu_emulator_validation.md` — SwiftShader indirect mode does not produce valid fractal renders despite clean shader compilation.

**Workaround:** Requires real Android device with hardware GPU or alternative thumbnail generation strategy.

## Integration Test Results
```
Command: flutter test integration_test/generate_gpu_thumbnails_test.dart -d emulator-5554
Result: 197/197 generated, 0 failures
Runtime: 6min 30s
Output: /sdcard/Download/catalog_thumbs/*.png

Issue: Screenshots captured successfully but shader output is black (not a screenshot API failure).
```

## Catalog Coverage
Expected catalog entries: 197  
CPU thumbnails present: 199 (includes 2 extra)  
Missing: 0  
Corrupt: 0  
Duplicate groups: (not analyzed — many CPU thumbnails intentionally similar due to formula coverage limit)

## Conclusion
**Shipping decision:** Use existing CPU-generated thumbnails in `assets/catalog_thumbs/`.

**Future work:** Generate GPU thumbnails on real Android device when available.
