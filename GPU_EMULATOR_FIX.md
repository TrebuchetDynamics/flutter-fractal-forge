# GPU Rendering Fix for Android Emulator (SwiftShader)

**Status:** In Progress
**Issue:** GPU shaders produce 100% black output on Android emulator despite clean compilation
**Platform:** Android emulator with SwiftShader (software GPU)

---

## Problem Analysis

### Current Behavior
```json
{
  "backend": "gpu",
  "lastGpuNonBlackRatio": 0.0,      // 0% non-black pixels
  "lastGpuDarkRatio": 1.0,           // 100% dark/black
  "lastGpuCenterNonBlack": false,    // Center pixel is black
  "lastGpuHistogramSane": false      // Histogram check failed
}
```

Even the simple diagnostic shader `mandelbrot.frag` that should output:
```glsl
fragColor = vec4(uv.x, wobble, uv.y, 1.0);  // UV gradient
```
...produces all black output on emulator.

### Possible Root Causes

1. **FlutterFragCoord() incompatibility** - Flutter's helper function may not work on SwiftShader
2. **Uniform transmission failure** - `shader.setFloat()` calls may not reach shader
3. **Shader compilation issue** - Code compiles but doesn't execute correctly
4. **SwiftShader limitations** - Known issues with GLSL features

---

## Test Shaders Created

### 1. `test_minimal.frag` - Constant Color Test
```glsl
// Simplest possible shader - just output solid red
fragColor = vec4(1.0, 0.0, 0.0, 1.0);
```
**Purpose:** Test if ANY GPU output works
**Expected:** Solid red screen
**If fails:** Fundamental Flutter FragmentShader API issue

### 2. `test_gl_fragcoord.frag` - Standard GLSL Test
```glsl
// Use standard gl_FragCoord instead of FlutterFragCoord()
vec2 uv = gl_FragCoord.xy / max(uResolution, vec2(1.0));
fragColor = vec4(uv.x, 0.5, uv.y, 1.0);
```
**Purpose:** Test standard GLSL without Flutter helpers
**Expected:** UV gradient (pink-green)
**If fails:** Uniform transmission or coordinate issue

### 3. `test_flutter_coord.frag` - Flutter Helper Test
```glsl
// Use Flutter's helper function
vec2 fragCoord = FlutterFragCoord().xy;
vec2 uv = fragCoord / max(uResolution, vec2(1.0));
fragColor = vec4(uv.x, 0.5, uv.y, 1.0);
```
**Purpose:** Test if FlutterFragCoord() is the problem
**Expected:** UV gradient (pink-green)
**If fails:** FlutterFragCoord() incompatible with SwiftShader

---

## Testing Instructions

### 1. Build and Run
```bash
flutter clean
flutter pub get
flutter run -d emulator-5554
```

### 2. Select Test Shaders (Debug Mode Only)

In the fractal catalog (debug builds only), scroll to the bottom to find:
- **Test: Minimal (Solid Red)**
- **Test: gl_FragCoord (UV Gradient)**
- **Test: FlutterFragCoord (UV Gradient)**

### 3. Expected Results

| Shader | Expected Output | If Black = Problem |
|--------|----------------|-------------------|
| test_minimal | Solid RED screen | Flutter FragmentShader API broken |
| test_gl_fragcoord | Pink-green UV gradient | Uniform transmission or gl_FragCoord issue |
| test_flutter_coord | Pink-green UV gradient | FlutterFragCoord() incompatible |

### 4. Check GPU Health Logs

Look for logs in fractal viewer:
```
[renderer] gpu_health_probe ...
[renderer] render_frame_stats backend=gpu ...
[renderer] backend_decision ...
```

Expected after fix:
- `non_black_ratio > 0.01`
- `centerNonBlack = true`
- `histogramSane = true`

---

## Next Steps

### If test_minimal shows RED ✓
- GPU output works! Problem is in coordinate/uniform handling
- Fix: Adjust how uniforms are set or use gl_FragCoord everywhere

### If test_minimal is BLACK ✗
- Fundamental FragmentShader API issue
- Possible fixes:
  1. Update Flutter engine version
  2. Use CPU fallback on emulator (existing behavior)
  3. File Flutter engine bug report
  4. Test with different emulator GPU mode (`-gpu host` vs `swiftshader_indirect`)

### If gl_FragCoord works but FlutterFragCoord doesn't
- Replace `FlutterFragCoord()` with `gl_FragCoord` in all shaders
- Update shader include patterns

---

## Workarounds to Try

### 1. Emulator GPU Mode
```bash
# Try host GPU instead of SwiftShader
emulator -avd fractal_test -gpu host

# Try different SwiftShader mode
emulator -avd fractal_test -gpu swiftshader
```

### 2. Precision Qualifiers
Change shader precision from `mediump` to `highp`:
```glsl
precision highp float;
```

### 3. GLSL Version
Add explicit version directive:
```glsl
#version 300 es
precision mediump float;
```

### 4. Flutter Engine Update
Check Flutter version and update if needed:
```bash
flutter --version
flutter upgrade
```

---

## Files Modified

- ✅ `shaders/test_minimal.frag` - Created
- ✅ `shaders/test_gl_fragcoord.frag` - Created
- ✅ `shaders/test_flutter_coord.frag` - Created
- ✅ `lib/core/modules/test_shaders_module.dart` - Created
- ✅ `lib/core/modules/module_registry.dart` - Updated (added test modules)
- ✅ `pubspec.yaml` - Updated (registered test shaders)

---

## Success Criteria

GPU rendering on emulator is **FIXED** when:
1. ✅ At least one test shader produces non-black output
2. ✅ GPU health check passes: `nonBlackRatio > 0.01`
3. ✅ Production fractal shaders render correctly on emulator
4. ✅ No fallback to CPU unless zoom exceeds precision threshold

---

**Next Action:** Run app on emulator in debug mode and test all three test shaders.
