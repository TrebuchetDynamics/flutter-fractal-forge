# Flutter Fractal Forge — Refactor & Enhancement Plan

**Based on**: Analysis of 8 open-source fractal projects (see `opensource-tools-fractals.md`)
**Current state**: ~200 shaders, escape-time catalog pattern, Mandelbulb 3D, Provider state management
**Dart SDK**: 3.10.7 · **Platforms**: Linux desktop, Android (Impeller/GLES), iOS (Impeller/Metal)
**Hard constraints**: `provider` only · GLSL ES 3.0 · no new pub.dev deps without justification

---

## 0. Immediate: Diagnostic Return in mandelbrot_et.frag

`shaders/mandelbrot_et.frag` line ~78 has:
```glsl
fragColor = vec4(uv01_diag.x, 0.25, uv01_diag.y, 1.0);
return;   // ← BLOCKS ALL MANDELBROT RENDERING
```
This was a debug diagnostic that was never removed. **Fix before anything else.**

**File**: `shaders/mandelbrot_et.frag` — delete the two lines above.
**Verify**: `flutter run` → Mandelbrot renders colored pixels, not a pink-ish gradient.

---

## 1. Bug Fixes (prerequisite to all new features)

### Bug 1 — `ProviderNotFoundException` for `FractalController`

**Root cause**: `FractalController` is created and provided per-tab inside the `_AppTabs` widget
tree. When a route (e.g. `FractalViewerScreen`) is pushed via `Navigator.push`, it exits the tab
widget subtree and loses the `FractalController` ancestor.

**Fix**: In `fractal_viewer_screen.dart`, read the controller from the nearest ancestor *before*
pushing, then re-provide it on the new route:

```dart
// In the calling widget (e.g. FractalCatalogScreen) — before Navigator.push:
final ctrl = context.read<FractalController>();

Navigator.push(context, MaterialPageRoute(
  builder: (_) => ChangeNotifierProvider<FractalController>.value(
    value: ctrl,
    child: const FractalViewerScreen(),
  ),
));
```

Alternatively, lift the `ChangeNotifierProvider<FractalController>` above `MaterialApp` in
`main.dart` (if a single global controller is the intent — confirm with current architecture).
The route-level `.value` wrapper is the safer option because it preserves the existing per-tab
pattern.

**Files to change**:
- Every call site that pushes `FractalViewerScreen` (search: `FractalViewerScreen(`)
- No changes to `FractalViewerScreen` itself or `FractalController`

**Verify**: `flutter test test/widget/fractal_viewer_screen_test.dart` — no `ProviderException`.

---

### Bug 2 — `_isTest` assert trick / black screen in debug builds

**Current state**: `fractal_renderer.dart` line 135 already uses `RuntimeModeService.isAutomatedTest`
(the assert trick has been replaced). Verify that `RuntimeModeService.useRendererPlaceholderSurface`
returns `false` in normal debug builds:

```dart
// lib/core/services/runtime_mode_service.dart — confirm this logic:
static bool get useRendererPlaceholderSurface =>
    isAutomatedTest && !_forcedGpuRender;

static bool get _forcedGpuRender =>
    const bool.fromEnvironment('FORCE_GPU_RENDER');
```

If the service already works correctly, Bug 2 is resolved. If the renderer still shows black
in debug builds without `--dart-define=FORCE_GPU_RENDER=true`:
- Check that `isAutomatedTest` is `false` when running `flutter run` (not a test runner)
- The service should only return `true` when launched by `flutter test`

**Files**: `lib/core/services/runtime_mode_service.dart`, `lib/features/renderer/fractal_renderer.dart`
**Verify**: `flutter run -d linux` → fractal renders without `--dart-define=FORCE_GPU_RENDER=true`

---

### Bug 3 — image v4.x residual call sites

**Scan**: `grep -r "copyInto\|Animation()\|addFrame\|encodeGif\|Format\.bgra\|ChannelOrder" lib/`

Check `lib/features/export/` and `lib/features/ar/` for any remaining pre-v4 API usage.
The known fixes (`copyInto` → `compositeImage`, `Animation()` → frame list, `Format.bgra` →
`ChannelOrder.bgra`) must be present in all callers.

**Verify**: `flutter analyze` → zero errors in export and AR feature directories.

---

## 2. Shader Quality — Highest Impact, Lowest Risk

These are purely additive changes inside existing shader files. They do not affect the uniform
layout or Dart-side code.

### 2.1 Remove debug diagnostic from mandelbrot_et.frag

Already described in §0 above.

### 2.2 sRGB Gamma Correction (all shaders)

**Problem**: All shaders output linear RGB. Without gamma, dark regions are too dark and bright
bands are clipped. The `builtinPalette()` cosine formula outputs perceptually even colours only
if the display applies sRGB. Impeller passes output through without correction.

**Fix**: Add a `linearToSRGB()` helper to each shader and apply it as the last step before writing
`fragColor`.

```glsl
// Add near the top of every shader (after precision declaration):
vec3 linearToSRGB(vec3 lin) {
    // IEC 61966-2-1 piecewise transfer function
    bvec3 lo = lessThan(lin, vec3(0.00304));
    return mix(
        1.055 * pow(max(lin, vec3(0.00304)), vec3(1.0 / 2.4)) - 0.055,
        12.92 * lin,
        vec3(lo)
    );
}

// In main(), last line before fragColor assignment:
col = linearToSRGB(col);
fragColor = vec4(col, alpha);
```

**Source**: Psychtoolbox-3 `SRGBGammaCorrect.m`; IEC 61966-2-1.

**Scope**: `mandelbrot_et.frag`, `mandel_step_smooth.frag`, `mandel_step_escape.frag`,
`mandelbulb.frag`, and all `*_gpu.frag` escape-time shaders. Add to a shared header include
(`shaders/lib/color_utils.glsl`) and `#include` it — but note Flutter's shader compiler does
not support arbitrary includes; copy-paste the 8-line function into each shader.

**Dart-side change**: None.
**Effort**: Low (copy 8 lines per shader, can be scripted).
**Priority**: High — affects every rendered frame.

---

### 2.3 Smooth Iteration Coloring — Unified Formula

**Problem**: Some shaders use `float(iter) / float(maxIter)` (banded), others use the
log-log formula. Standardise on the FractalShark/Mandelbulber2 formula:

```glsl
// Replace any naive t = float(it) / float(maxIter):
float smoothT(int it, vec2 z, float power) {
    float mag2 = max(1e-12, dot(z, z));
    float smooth = float(it) + 1.0 - log2(log2(sqrt(mag2)));
    // power != 2: divide by log2(power) for generalised fractals
    return smooth;
}
float t = fract(smoothT(it, z, 2.0) / 64.0);
```

The `fract(... / 64.0)` creates a cycling palette. Replace `64.0` with a `uColorCycles` uniform
(default 64) for user control without recompilation.

**Source**: FractalShark `LowPrecisionKernels.cuh`, Fractals-Explorer `mandel.glsl`,
Psychtoolbox-3 `MandelbrotShader.frag.txt`.

**Files**: `mandel_step_smooth.frag`, `mandelbrot_et.frag` (already partially correct; tighten).
**Dart-side change**: Add `colorCycles` float to `UniformSchema` for shaders that expose it.
**Priority**: High.

---

### 2.4 Cosine Palette Unification

**Current state**: `mandelbrot_et.frag` already implements cosine palette as `scheme == 0`:
```glsl
0.5 + 0.5 * cos(6.28318 * (1.0 * t + vec3(0.00, 0.33, 0.67)))
```

This is correct and matches the best formula from Fractals-Explorer (Case 6) and giulia
(scheme 4). **Action**: Ensure all `*_gpu.frag` escape-time shaders use this same formula for
scheme 0 (Fire) rather than ad-hoc per-shader colour logic. Extract the function:

```glsl
vec3 cosinePalette(float t, vec3 phase) {
    return 0.5 + 0.5 * cos(6.28318 * (t + phase));
}

// Built-in palettes:
if (scheme == 0) return cosinePalette(t, vec3(0.00, 0.33, 0.67)); // Fire/default
if (scheme == 1) return cosinePalette(t, vec3(0.50, 0.60, 0.70)); // Ocean
if (scheme == 2) return cosinePalette(t, vec3(0.00, 0.10, 0.20)); // Midnight
if (scheme == 3) return cosinePalette(t, vec3(0.80, 0.50, 0.40)); // Sunset
// Grayscale fallback
return vec3(t);
```

**Source**: Fractals-Explorer Case 6, giulia scheme 4, Mandelbulber2 palette system.
**Dart-side change**: Expose `uColorPhase` as `vec3` uniform for runtime phase control (optional
advanced feature — can defer to Phase 3).
**Priority**: Medium (cosmetic but unifying).

---

### 2.5 Compact Branchless HSV → RGB

Replace any branching HSV→RGB in shaders with the compact form from giulia:

```glsl
vec3 hsv2rgb(vec3 c) {
    vec4 K = vec4(1.0, 2.0/3.0, 1.0/3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}
```

No branching → better GPU pipeline utilisation.
**Files**: Any shader that calls a branching `hsv_to_rgb()` or HSV case-switch.
**Priority**: Medium.

---

### 2.6 Separable Gaussian Glow (Post-Processing Pass)

**Design**: Two-pass blur (horizontal then vertical) rendered to FBO, then composited:

```glsl
// shaders/post_glow_h.frag — horizontal pass
uniform sampler2D uSceneTexture;
uniform float uSigma;          // 1.0 – 10.0
uniform vec2  uResolution;

void main() {
    vec2 uv = FlutterFragCoord().xy / uResolution;
    vec3 col = vec3(0.0);
    float weight = 0.0;
    int radius = int(uSigma * 2.0);
    for (int i = -radius; i <= radius; i++) {
        float w = exp(-float(i*i) / (2.0 * uSigma * uSigma));
        col += texture(uSceneTexture, uv + vec2(float(i)/uResolution.x, 0.0)).rgb * w;
        weight += w;
    }
    fragColor = vec4(col / weight, 1.0);
}
// shaders/post_glow_v.frag — vertical pass (same, swap x/y offset)
```

**Dart-side**: `FractalPainter` renders scene to `ui.Picture`, converts to `ui.Image`, passes
as `setImageSampler(0, sceneImage)` to glow shader. Two Canvas draw calls per frame when
`glowEnabled`.

**Architecture**: Add `glowEnabled` and `glowSigma` to `FractalController`. `FractalPainter`
checks `controller.glowEnabled` and executes the two extra passes.

**Source**: glChAoS.P `filtersFrag.glsl` — O(2σ) separable, not O(σ²) naive 2D.
**Priority**: Medium (visually dramatic, moderate complexity).
**Effort**: ~4h (two new shaders + FractalPainter multi-pass logic).

---

### 2.7 Escape Radius: Use 4.0 Instead of 2.0

**Insight from giulia**: Escape radius 4.0 produces smoother smooth-iteration values because
`log(log(4)) / log(2) = 1.0` exactly, making the fractional part of the smooth iteration
start at a cleaner position. With radius 2.0, `log(log(2)) / log(2) ≈ 0`, which can produce
a faint banding artefact at the first escape band.

```glsl
// Change: float bailoutSq = uBailout * uBailout;
// Default uBailout: change from 2.0 to 4.0 in EscapeTimeConfig
```

**Files**: `escape_time_catalog.dart` — update `defaultBailout` from `2.0` to `4.0` for
Mandelbrot and Julia family. No shader change needed (bailout is already a uniform).
**Priority**: Low-Medium (subtle quality improvement).

---

## 3. Double-Float Precision Shader Tier

**Goal**: Extend interactive zoom from ~10^7 (float32 artifacts) to ~10^14 without CPU fallback.

### 3.1 GLSL Double-Float Structs

Add `shaders/lib/dblflt.glsl`:

```glsl
// Double-float: two float32 values with Knuth 2-sum / Dekker split
// Gives ~14 decimal digits from two float32 values.
// Source: FractalShark HpSharkFloatLib/dblflt.cuh

struct df2 { float hi; float lo; };

df2 df2_add(df2 a, df2 b) {
    float s = a.hi + b.hi;
    float e = (abs(a.hi) >= abs(b.hi))
        ? (a.hi - s) + b.hi
        : (b.hi - s) + a.hi;
    return df2(s, e + a.lo + b.lo);
}

df2 df2_mul(df2 a, df2 b) {
    // Dekker split: split a.hi into two 12-bit halves
    float c   = (4097.0 + 1.0) * a.hi;   // 4097 = 2^12 + 1
    float ahi = c - (c - a.hi);
    float alo = a.hi - ahi;
    float bhi = c - (c - b.hi);          // same split for b
    float blo = b.hi - bhi;
    float p   = a.hi * b.hi;
    float e   = ((ahi * bhi - p) + ahi * blo + alo * bhi) + alo * blo;
    return df2(p, e + a.hi * b.lo + a.lo * b.hi);
}

df2 df2_from(float v) { return df2(v, 0.0); }
float df2_to_float(df2 a) { return a.hi + a.lo; }
```

**Note**: GLSL ES 3.0 has no `fma()` — use the Dekker split as shown above (no `fma` needed).

### 3.2 New Shader: mandelbrot_df2.frag

```glsl
// shaders/mandelbrot_df2.frag
// Double-float Mandelbrot for zoom levels 1e7 – 1e14
// Uniforms extend the standard layout with hi/lo pairs:

uniform float uTime;
uniform vec2  uResolution;
uniform float uCenterHi_x;  // high word of center.x
uniform float uCenterLo_x;  // low  word of center.x
uniform float uCenterHi_y;
uniform float uCenterLo_y;
uniform float uZoomHi;
uniform float uZoomLo;
uniform float uIterations;
uniform float uBailout;
uniform float uColorScheme;
uniform float uTransparentBg;

void main() {
    vec2 fragCoord = FlutterFragCoord().xy;
    float scale = min(uResolution.x, uResolution.y);
    vec2 pixel = (fragCoord - 0.5 * uResolution) / scale;

    // Compute c in double-float
    df2 cx = df2_add(df2(uCenterHi_x, uCenterLo_x),
                     df2_mul(df2(pixel.x, 0.0),
                             df2(1.0 / max(uZoomHi, 1e-10), 0.0)));
    df2 cy = df2_add(df2(uCenterHi_y, uCenterLo_y),
                     df2_mul(df2(pixel.y, 0.0),
                             df2(1.0 / max(uZoomHi, 1e-10), 0.0)));

    df2 zx = df2_from(0.0);
    df2 zy = df2_from(0.0);
    int it = 0;
    int maxIt = int(uIterations);

    for (int j = 0; j < 2000; j++) {
        if (j >= maxIt) { it = maxIt; break; }
        df2 zx2 = df2_mul(zx, zx);
        df2 zy2 = df2_mul(zy, zy);
        float mag2 = zx2.hi + zy2.hi;
        if (mag2 > uBailout * uBailout) { it = j; break; }
        df2 new_zx = df2_add(df2_add(zx2, df2(-zy2.hi, -zy2.lo)), cx);
        zy = df2_add(df2_mul(df2(2.0, 0.0), df2_mul(zx, zy)), cy);
        zx = new_zx;
        it = j + 1;
    }

    // Smooth coloring + palette (same as mandelbrot_et.frag)
    // ...
}
```

### 3.3 Dart-Side: DeepZoomPrecisionPolicy Update

```dart
// lib/features/renderer/deep_zoom_precision_policy.dart
// Add df2 tier between float and CPU:

static const Map<String, double> _df2ZoomThresholds = {
  'mandelbrot': 5e6,   // switch from float to df2 shader at 5M
  'julia':      2e6,
  'burning_ship': 2e6,
};

// In shouldUseCpuFallback: only trigger CPU at zoom >= 1e14 for df2-capable modules
// Add: shaderTierFor(moduleId, zoom) → 'float' | 'df2' | 'cpu'
```

`FractalController` selects `mandelbrot_df2.frag` or `mandelbrot_et.frag` based on tier.
The hi/lo center values are split from Dart `double` using:
```dart
double hi = center.x;
double lo = center.x - hi;   // residual (safe in Dart, which uses IEEE 754 double)
```

**Source**: FractalShark `HpSharkFloatLib/dblflt.cuh`, `deep_zoom_precision_policy.dart` comments.
**Effort**: High (~1 day: shader + Dart precision policy + controller wiring).
**Priority**: High — currently the app falls back to CPU at zoom 1e7; df2 extends to 1e14.

---

## 4. Orbit Trap Coloring

Add orbit trap as an optional coloring mode to escape-time shaders (zero new uniform slots needed
if encoded in the existing `uColorScheme` int range, e.g. scheme >= 10):

```glsl
// In the iteration loop, track minimum distance to origin:
float minDist = 1e10;
for (int j = 0; j < MAX_ITERS; j++) {
    // ... standard z = z^2 + c ...
    minDist = min(minDist, length(z));         // point trap
    // or: minDist = min(minDist, abs(z.x));  // line trap (Re axis)
}

// Coloring:
if (int(uColorScheme) == 10) {
    float t = clamp(minDist * 0.5, 0.0, 1.0);
    col = cosinePalette(t, vec3(0.0, 0.33, 0.67));
}
```

**Source**: Mandelbulber2 `fractal_coloring.cl` — multi-component additive model.
**Files**: `mandelbrot_et.frag`, `mandel_step_smooth.frag`.
**Dart-side**: No change — existing `uColorScheme` covers new int values.
**Priority**: Medium.

---

## 5. New Fractal Modules

### 5.1 Tier A — One EscapeTimeConfig Entry Each

These shaders either already exist in `shaders/` or are trivial 1-shader additions:

| id | shaderAsset | Formula | New parameters | Source |
|----|-------------|---------|----------------|--------|
| `julia_dual` | `julia_gpu.frag` (modify) | z²+c, juliaMode bool | `juliaMode`, `juliaCx`, `juliaCy` | giulia |
| `newton_z4` | `newton_general_gpu.frag` | z⁴−1, 4 roots | degree=4 | FractalExplorer |
| `newton_z5` | `newton_general_gpu.frag` | z⁵−1, 5 roots | degree=5 | FractalExplorer |
| `menger_sponge` | `menger_sponge_gpu.frag` ✓ | Cross-fold DE, 100 steps | foldScale, maxSteps | shader-fractals |
| `sierpinski_tetra` | `sierpinski_tetrahedron_gpu.frag` ✓ | Sum-fold DE, 150 steps | iterations | shader-fractals |

`✓` = shader file already exists in `shaders/`. Just add `EscapeTimeConfig` entry and verify
uniform layout matches `escape_time_builder.dart` expectations.

### 5.2 Dual-Mode Mandelbrot/Julia Shader (giulia Pattern)

Single shader handles both Mandelbrot and Julia via a `juliaMode` uniform:

```glsl
// shaders/mandel_julia_dual_gpu.frag
uniform float uJuliaMode;   // 0.0 = Mandelbrot, 1.0 = Julia
uniform vec2  uJuliaC;      // fixed c for Julia mode

void main() {
    vec2 c  = (uJuliaMode > 0.5) ? uJuliaC : pixel;
    vec2 z  = (uJuliaMode > 0.5) ? pixel   : vec2(0.0);
    // ... standard escape loop ...
}
```

**Dart-side**: `buildMandulJuliaDualModule()` in a new `julia_dual_module.dart`. Expose
`juliaCx`, `juliaCy` as `FractalParameter` with type `float`, range `[-2.0, 2.0]`.
Add UI: tap on the Mandelbrot view sets `juliaCx/juliaCy` (GestureDetector in `FractalCanvas`
converts tap position to complex coordinates and updates the controller).

**Julia Preset Coordinates** (from shader-fractals analysis):
```dart
// Add to EscapeTimeConfig.extraPresets:
('Dendritic',   -0.8,    0.156),
('Spiral',      -0.4,    0.6),
('Cauliflower',  0.285,  0.01),
('Flame',       -0.70176,-0.3842),
('Rabbit',      -0.835, -0.2321),
('Nautilus',     0.45,   0.1428),
```

### 5.3 Mandelbox 3D Module

```glsl
// shaders/mandelbox_3d_gpu.frag (new)
// Source: Mandelbulber2 fractal_mandelbox.cpp + shader-fractals mandelbox.glsl
// DE: box-fold + sphere-fold (see §2 of opensource-tools-fractals.md)

uniform float uFoldLimit;    // default 1.0, range [0.5, 1.5]
uniform float uFoldValue;    // default 2.0, range [1.5, 2.5]
uniform float uMinR2;        // mR² default 0.25
uniform float uFixedR2;      // fR² default 4.0
uniform float uScale;        // default 2.5, range [2.0, 4.0]
uniform float uMaxSteps;     // default 100 mobile, 300 desktop
```

Keep `uMaxSteps` at ≤ 150 for mobile. Desktop only: increase via performance tier setting.

### 5.4 Strange Attractor — Lorenz 2D Projection

`shaders/lorenz_2d_gpu.frag` already exists. Verify it uses the correct parameters:
- σ=10, ρ=28, β=8/3, dt=0.01
- Colour by velocity magnitude: `t = clamp(length(dv) * uColorVel, 0.0, 1.0)`

Add `EscapeTimeConfig` entry if not already in catalog.

### 5.5 IFS Fractals (from shader-fractals)

`sierpinski_carpet_gpu.frag`, `sierpinski_triangle_gpu.frag` already exist. Verify:
```glsl
// Sierpinski Carpet — correct modular grid algorithm:
for (int i = 0; i < depth; i++) {
    z = fract(z * 3.0);
    if (z.x > 1.0/3.0 && z.x < 2.0/3.0 &&
        z.y > 1.0/3.0 && z.y < 2.0/3.0) {
        fragColor = vec4(0.0, 0.0, 0.0, 1.0); return;
    }
}
```

---

## 6. Architecture Changes (Dart)

### 6.1 Zoom-Into-Cursor Correctness

**From Fractals-Explorer** `controls.hpp`: when zooming, the world point under the cursor must
stay fixed. Verify `lib/features/renderer/gesture_handler.dart`:

```dart
// On scroll/pinch zoom — the correct algorithm:
void _applyZoom(Offset cursorScreen, double scaleFactor) {
    final prevWorld = _screenToWorld(cursorScreen);
    _zoom *= scaleFactor;
    final newWorld = _screenToWorld(cursorScreen);
    _pan += prevWorld - newWorld;  // compensate drift
    _notify();
}
```

If `gesture_handler.dart` does not implement this pattern, the fractal will "slide" under the
cursor during zoom. **Search**: `GestureDetector` → `onScaleUpdate` in `fractal_canvas.dart`.

### 6.2 Uniform Schema — New Slots

Current standard layout (from `mandelbrot_et.frag`): slots 0–42 (uTime through uCustomStop7).

New slots needed for enhancements (add to `UniformSchema` builder in each affected shader's
Dart module):

| Uniform | Type | Slot (after stop7) | Purpose |
|---------|------|---------------------|---------|
| `uColorCycles` | float | 43 | Palette cycle speed |
| `uGamma` | float | 44 | Gamma override (default 1.0 = sRGB) |
| `uOrbitTrapWeight` | float | 45 | Orbit trap mix |
| `uJuliaMode` | float | 46 | 0=Mandelbrot, 1=Julia |
| `uJuliaCx` | float | 47 | Julia c.x |
| `uJuliaCy` | float | 48 | Julia c.y |

Only add slots used by a given shader. `UniformSchema.build()` tracks the cursor; adding a
new `float()` call automatically assigns the next index.

### 6.3 Palette System — Retain Current Inline Approach

The current 8-stop custom gradient + cosine built-in palettes in `mandelbrot_et.frag` is
sufficient and avoids a texture sampler slot. **Do not** migrate to 1D texture LUTs unless
>8 stops are needed. The cosine palette formula (see §2.4) can produce effectively infinite
colour variety by varying the 3-component phase offset.

**If** a 256-entry LUT is needed (e.g. for Magma/Viridis): use `setImageSampler(0, paletteTex)`
where `paletteTex` is a `1×256 RGBA8888` `ui.Image` generated by `PaletteService`. This
consumes sampler slot 0; ensure the shader's first sampler declaration is the palette, not
a scene texture (ordering matters in Flutter's `FragmentShader.setImageSampler`).

### 6.4 RuntimeModeService — Final Clean-Up

Ensure the service has exactly three modes with no ambiguity:

```dart
enum AppRenderMode { test, debug, release }

class RuntimeModeService {
    static AppRenderMode get mode {
        if (const bool.fromEnvironment('FORCE_GPU_RENDER')) return AppRenderMode.release;
        if (_isTestRunner()) return AppRenderMode.test;
        return kReleaseMode ? AppRenderMode.release : AppRenderMode.debug;
    }

    static bool _isTestRunner() {
        // Use flutter_test's `isRunningTest` or check Platform environment
        return Platform.environment.containsKey('FLUTTER_TEST');
    }

    static bool get useRendererPlaceholder => mode == AppRenderMode.test;
    static bool get isDebug => mode == AppRenderMode.debug;
}
```

`FractalRenderer` checks `RuntimeModeService.useRendererPlaceholder` only — no assert tricks.

---

## 7. Performance Targets

### 7.1 2D Escape-Time Fractals

| Device tier | Max iterations | AA | Expected FPS |
|-------------|---------------|-----|-------------|
| Mobile mid (Snapdragon 6xx) | 128 | none | 60 |
| Mobile high (Snapdragon 8xx, A-series) | 256 | FXAA | 60 |
| Desktop Linux | 512 | FXAA | 60 |
| Desktop HQ / export | 1024 | SSAA 4× | 20–30 |

`uIterations` is already a uniform — these are UI slider ranges.

### 7.2 3D Ray-Marched Fractals

| Device tier | Max steps | Iterations | Expected FPS |
|-------------|-----------|-----------|-------------|
| Mobile mid | 64 | 8 | 30 |
| Mobile high | 100 | 10 | 30–60 |
| Desktop | 200 | 15 | 60 |
| Desktop HQ | 400 | 25 | 30 |

### 7.3 Precision Tier Thresholds

Based on FractalShark precision table + `DeepZoomPrecisionPolicy` comments:

| Zoom level | Shader tier | Module |
|-----------|------------|--------|
| < 5 × 10^6 | `mandelbrot_et.frag` (float32) | mandelbrot, julia |
| 5×10^6 – 1×10^14 | `mandelbrot_df2.frag` (double-float) | mandelbrot, julia |
| > 1×10^14 | CPU isolate | mandelbrot |

Update `DeepZoomPrecisionPolicy._cpuFallbackZoomThresholds` to `1e14` for modules with a
`df2` shader available.

### 7.4 Separable Gaussian Glow Cost

σ=3 → 7 taps per axis → 14 texture fetches per pixel → ~8–12% GPU overhead at 1080p.
Enable only when user explicitly enables "Glow" in settings. Default: off.

---

## 8. Incremental Rollout Phases

Each phase leaves the app fully functional and passing `flutter analyze`.

### Phase 0 — Hotfixes (Day 1)
1. Remove diagnostic `return` from `mandelbrot_et.frag` (§0)
2. Fix `ProviderNotFoundException` at `FractalViewerScreen` push sites (§1 Bug 1)
3. Verify `RuntimeModeService` (§1 Bug 2) — no code change if already correct
4. Scan and fix image v4.x call sites (§1 Bug 3)

**Smoke test**: `flutter analyze && flutter test && flutter run -d linux`

---

### Phase 1 — Shader Quality Foundation (Week 1)
1. Add `linearToSRGB()` to `mandelbrot_et.frag`, `mandel_step_smooth.frag`, `mandelbulb.frag`
2. Standardise smooth iteration formula in above shaders (§2.3)
3. Standardise `cosinePalette()` function across all `*_gpu.frag` shaders (§2.4)
4. Replace branching HSV→RGB with compact 3-line version (§2.5)
5. Change default `uBailout` to `4.0` in catalog entries (§2.7)

**Guard**: All existing tests pass. No uniform schema changes in this phase.
**Smoke test**: `flutter analyze && flutter test`

---

### Phase 2 — Dual-Mode Julia + Preset Coordinates (Week 2)
1. Create `shaders/mandel_julia_dual_gpu.frag` with `uJuliaMode`, `uJuliaCx`, `uJuliaCy`
2. Add `julia_dual_module.dart` with `buildJuliaDualModule()`
3. Add 6 Julia preset coordinates from shader-fractals to `EscapeTimeConfig.extraPresets`
4. Wire tap-on-Mandelbrot → set Julia seed in `FractalCanvas`

**Smoke test**: `flutter run -d linux` → tap on Mandelbrot → Julia view appears.

---

### Phase 3 — Orbit Trap Coloring (Week 2–3)
1. Add orbit trap (point trap + line trap) to `mandelbrot_et.frag` and `julia_gpu.frag`
2. Expose via `uColorScheme` values 10 (point trap) and 11 (line trap)
3. Add UI labels "Orbit Trap — Point", "Orbit Trap — Line" to color scheme picker

**No Dart schema changes needed** — `uColorScheme` already a float uniform.

---

### Phase 4 — Zoom-Into-Cursor Fix + Precision Audit (Week 3)
1. Verify `gesture_handler.dart` implements correct zoom-into-cursor (§6.1)
2. Add `DeepZoomHysteresis.shaderTierFor()` returning `'float' | 'df2' | 'cpu'`
3. Implement `mandelbrot_df2.frag` with `dblflt` structs (§3)
4. Update `FractalController` to select df2 shader at zoom ≥ 5×10^6

**Guard**: CPU fallback still activates at zoom ≥ 1×10^14.
**Smoke test**: Zoom to 1×10^8 — smooth rendering, no pixel-grid artefacts.

---

### Phase 5 — Glow Post-Processing (Week 4)
1. Create `shaders/post_glow_h.frag` and `shaders/post_glow_v.frag`
2. Add `glowEnabled: bool` and `glowSigma: double` to `FractalController`
3. Add two-pass render logic to `FractalPainter` (render-to-picture → image → glow shader)
4. Add Glow toggle to UI settings

**Guard**: Glow disabled by default — zero performance impact when off.

---

### Phase 6 — 3D Additions (Week 5–6)
1. Add `EscapeTimeConfig` for `menger_sponge_gpu.frag` and `sierpinski_tetrahedron_gpu.frag`
   (shaders already exist — just need catalog entries and uniform verification)
2. Create `shaders/mandelbox_3d_gpu.frag` (new ray-marcher)
3. Add `mandelbox_module.dart` with parameters: foldLimit, foldValue, minR2, fixedR2, scale, maxSteps
4. Verify `mandelbulb.frag` uses correct analytic DE (§2 of opensource doc)

**Performance guard**: Default `maxSteps=100` on mobile; device tier policy caps at 150.

---

### Phase 7 — Attractor Catalog Verification (Week 6)
1. Verify existing `lorenz_2d_gpu.frag`, `aizawa_gpu.frag`, `halvorsen_gpu.frag` etc.
   use correct ODE parameters (§1 of opensource doc)
2. Add missing catalog entries for any attractor shaders not yet in `escape_time_catalog.dart`
3. Ensure velocity-based coloring (`t = clamp(length(dv) * uColorVel, 0.0, 1.0)`) is used

---

## 9. Shader Extraction — Complete List from Opensource Projects

The following GLSL snippets are extracted and ready to copy into our shaders:

### 9.1 Complete Complex Number Library (FractalExplorer)
```glsl
// Paste into any escape-time shader that needs generalised complex power
vec2 complexMul(vec2 a, vec2 b) {
    return vec2(a.x*b.x - a.y*b.y, a.x*b.y + a.y*b.x);
}
vec2 complexDiv(vec2 a, vec2 b) {
    float d = dot(b, b);
    return vec2(dot(a,b), a.y*b.x - a.x*b.y) / d;
}
vec2 complexPow(vec2 z, float p) {
    float r = pow(dot(z,z), p * 0.5);
    float a = atan(z.y, z.x) * p;
    return vec2(r * cos(a), r * sin(a));
}
// Integer power fast path:
vec2 complexPowN(vec2 z, int n) {
    vec2 r = z;
    for (int i = 1; i < n; i++) r = complexMul(r, z);
    return r;
}
vec2 complexSin(vec2 z) {
    return vec2(sin(z.x)*cosh(z.y), cos(z.x)*sinh(z.y));
}
vec2 complexCos(vec2 z) {
    return vec2(cos(z.x)*cosh(z.y), -sin(z.x)*sinh(z.y));
}
```

### 9.2 Smooth Iteration — Three Equivalent Forms
```glsl
// Form 1: log2(log2) — for z²+c (power=2)
float smoothIter2(int it, vec2 z) {
    return float(it) + 1.0 - log2(log2(max(dot(z,z), 1.001)));
}

// Form 2: generalised power
float smoothIterN(int it, vec2 z, float power) {
    return float(it) + 1.0 - log(log(max(length(z), 1.001))) / log(power);
}

// Form 3: Psychtoolbox compact form
float smoothIterFract(int it, vec2 z) {
    return fract(float(it) * 0.01);  // simple, fast, slight banding
}
```

### 9.3 Mandelbox Step (Mandelbulber2, exact)
```glsl
void mandelboxStep(inout vec3 z, vec3 c, inout float DE,
                   float foldLimit, float foldValue,
                   float mR2, float fR2, float scale) {
    // Box fold
    z = clamp(z, -foldLimit, foldLimit) * 2.0 * foldLimit / (foldLimit) - z;
    // Correct: reflect about ±foldLimit
    // Box fold (alternate — exact match to fractal_mandelbox.cpp):
    if (z.x >  foldLimit) z.x =  foldValue - z.x;
    if (z.x < -foldLimit) z.x = -foldValue - z.x;
    if (z.y >  foldLimit) z.y =  foldValue - z.y;
    if (z.y < -foldLimit) z.y = -foldValue - z.y;
    if (z.z >  foldLimit) z.z =  foldValue - z.z;
    if (z.z < -foldLimit) z.z = -foldValue - z.z;
    // Sphere fold
    float r2 = dot(z, z);
    if (r2 < mR2)      { float k = fR2/mR2; z *= k; DE *= k; }
    else if (r2 < fR2) { float k = fR2/r2;  z *= k; DE *= k; }
    z *= scale; DE = DE * abs(scale) + 1.0;
    z += c;
}
```

### 9.4 Mandelbulb DE (mandelbulb.frag — already correct)
The existing `mandelbulb.frag` implements the correct analytic DE. Verify that:
- `dr = pow(r, power-1.0) * power * dr + 1.0;` (not `dr = 2.0 * r * dr + 1.0`)
- Final: `return 0.5 * log(r) * r / dr;`

### 9.5 Sierpinski Tetrahedron DE (shader-fractals, sum-based fold)
```glsl
float sierpinskiTetraDE(vec3 z, int maxIter) {
    float scale = 2.0;
    int n = 0;
    while (n < maxIter && length(z) < 2.0) {
        if (z.x + z.y < 0.0) z.xy = -z.yx;
        if (z.x + z.z < 0.0) z.xz = -z.zx;
        if (z.y + z.z < 0.0) z.yz = -z.zy;
        z = z * scale - vec3(scale - 1.0);
        n++;
    }
    return length(z) * pow(scale, -float(n));
}
```

### 9.6 Menger Sponge DE (shader-fractals, cross-fold)
```glsl
float mengerDE(vec3 z, int maxIter) {
    float scale = 3.0;
    int n = 0;
    while (n < maxIter && length(z) < 2.0) {
        z = abs(z);
        if (z.x < z.y) z.xy = z.yx;
        if (z.x < z.z) z.xz = z.zx;
        if (z.y < z.z) z.yz = z.zy;
        z *= scale;
        z -= vec3(scale - 1.0) * 0.5;
        if (z.z < -(scale-1.0)*0.5) z.z += scale - 1.0;
        n++;
    }
    return (length(z) - 1.5) * pow(scale, -float(n));
}
```

### 9.7 Newton z³−1 (FractalExplorer, exact)
```glsl
// Already in newton_z3_gpu.frag — verify the step:
// z ← z - a * P(z)/P'(z)  where P(z)=z³-1, P'(z)=3z²
vec2 newtonStep(vec2 z, vec2 a) {
    vec2 z2   = complexMul(z, z);
    vec2 z3   = complexMul(z2, z);
    vec2 Pz   = z3 - vec2(1.0, 0.0);               // z³ - 1
    vec2 dPz  = 3.0 * z2;                           // 3z²
    return z - complexMul(a, complexDiv(Pz, dPz));
}
// Convergence tolerance: 0.0001–0.001
// Color by nearest root: roots = [1, exp(2πi/3), exp(4πi/3)]
```

### 9.8 Lorenz ODE Step
```glsl
// For 2D projection (XZ plane):
vec2 lorenzStep(vec2 xz, float y, float sigma, float rho, float beta, float dt) {
    float dx = sigma * (y - xz.x);
    float dy = xz.x * (rho - xz.y) - y;  // xz.y = z here
    float dz = xz.x * y - beta * xz.y;
    return vec2(xz.x + dt * dx, xz.y + dt * dz);
}
// Default: sigma=10, rho=28, beta=8.0/3.0, dt=0.01
```

### 9.9 Poisson Disk Shadow Sampling (glChAoS.P — for Mandelbulb shadows)
```glsl
// 16 Poisson disk offsets for soft shadows in mandelbulb.frag
const vec2 poissonDisk[16] = vec2[16](
    vec2(-0.94201624, -0.39906216), vec2( 0.94558609, -0.76890725),
    vec2(-0.09418410, -0.92938870), vec2( 0.34495938,  0.29387760),
    vec2(-0.91588581,  0.45771432), vec2(-0.81544232, -0.87912464),
    vec2(-0.38277543,  0.27676845), vec2( 0.97484398,  0.75648379),
    vec2( 0.44323325, -0.97511554), vec2( 0.53742981, -0.47373420),
    vec2(-0.26496911, -0.41893023), vec2( 0.79197514,  0.19090188),
    vec2(-0.24188840,  0.99706507), vec2(-0.81409955,  0.91437590),
    vec2( 0.19984126,  0.78641367), vec2( 0.14383161, -0.14100790)
);
float softShadow(vec3 pos, vec3 lightDir, float softness) {
    float shadow = 1.0;
    float scan = 0.01;
    for (int i = 0; i < 16; i++) {
        vec3 jitterDir = normalize(lightDir + vec3(poissonDisk[i], 0.0) * 0.01);
        float d = getDistance(pos + jitterDir * scan);
        shadow = min(shadow, softness * d / scan);
        scan += d * 0.5;
    }
    return clamp(shadow, 0.0, 1.0);
}
```

---

## 10. Files to Create / Modify — Summary

### New Shader Files
| File | Purpose | Phase |
|------|---------|-------|
| `shaders/mandelbrot_df2.frag` | Double-float Mandelbrot | 4 |
| `shaders/mandel_julia_dual_gpu.frag` | Combined Mandelbrot/Julia | 2 |
| `shaders/mandelbox_3d_gpu.frag` | Mandelbox ray-marcher | 6 |
| `shaders/post_glow_h.frag` | Glow pass horizontal | 5 |
| `shaders/post_glow_v.frag` | Glow pass vertical | 5 |

### Modified Shader Files
| File | Change | Phase |
|------|--------|-------|
| `shaders/mandelbrot_et.frag` | Remove diagnostic return; add sRGB, smooth iter | 0, 1 |
| `shaders/mandel_step_smooth.frag` | sRGB, orbit trap | 1, 3 |
| `shaders/mandelbulb.frag` | Verify DE; add Poisson shadow; sRGB | 1, 6 |
| All `*_gpu.frag` escape-time | `linearToSRGB()`, `cosinePalette()` | 1 |

### New Dart Files
| File | Purpose | Phase |
|------|---------|-------|
| `lib/core/modules/julia_dual_module.dart` | buildJuliaDualModule() | 2 |
| `lib/core/modules/mandelbox_module.dart` | buildMandelboxModule() | 6 |

### Modified Dart Files
| File | Change | Phase |
|------|--------|-------|
| `lib/features/renderer/deep_zoom_precision_policy.dart` | Add df2 tier | 4 |
| `lib/features/renderer/fractal_renderer.dart` | df2 shader selection | 4 |
| `lib/features/renderer/fractal_painter.dart` | Two-pass glow render | 5 |
| `lib/core/modules/builders/escape_time_catalog.dart` | New EscapeTimeConfig entries | 2, 6, 7 |
| `lib/core/services/runtime_mode_service.dart` | Clean enum-based modes | 0 |
| Route push sites | Wrap with `ChangeNotifierProvider.value` | 0 |
