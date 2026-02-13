# GPU Emulator Validation Results

**Date:** 2026-02-12
**Emulator:** fractal_test (emulator-5554), swiftshader_indirect GPU mode
**Build:** debug APK with `SKIP_EMULATOR_GUARD=true` (bypasses androidEmulator policy guard)

## Summary

**GPU shader compilation succeeds on emulator, but all renders produce black output.**
The backend policy's emulator guard is correctly protecting users from broken GPU rendering.

## Results

| Fractal | Category | Shader Compile | Render Visible | Backend Decision | render_check |
|---|---|---|---|---|---|
| mandelbrot | Escape-Time | ✅ Yes | ❌ No (all black) | gpu, reason=none | pass=false, non_black_ratio=0.0000 |
| burning_ship | Escape-Time | ✅ Yes | ❌ No (all black) | gpu, reason=none | pass=false, non_black_ratio=0.0000 |
| tricorn | Escape-Time | ✅ Yes | ❌ No (all black) | gpu, reason=none | pass=false, non_black_ratio=0.0000 |

## Key Findings

1. **Shaders compile without errors** — no shader compilation failures in logcat
2. **All GPU renders are completely black** — center pixel is (0,0,0), non_black_ratio is 0.0000
3. **Frame progression check fails** — consecutive frames are identical (both black)
4. **The render_validation system correctly detects the failure** — `pass=false` for all checks

## Conclusion

The `androidEmulator` guard in `RendererBackendPolicy` is essential and correct:
- GPU shader compilation works on emulator (SwiftShader)
- However, the actual pixel output is all zeros (black)
- This is a known SwiftShader limitation with Flutter's FragmentShader API
- CPU fallback produces correct, colorful renders (validated in Phase 1-2)

**Real device GPU validation** requires a physical Android device to be connected.
The `SKIP_EMULATOR_GUARD=true` dart-define is available for future testing.

## Impeller Warning

The app has Impeller explicitly disabled in AndroidManifest.xml. Flutter warns this opt-out is deprecated. This should be addressed in a future release — Impeller may fix the GPU rendering on emulators.
