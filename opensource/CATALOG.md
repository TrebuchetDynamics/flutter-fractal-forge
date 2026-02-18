# Flutter Fractal Forge — Opensource Learning Catalog

**19 projects analyzed · All techniques mapped to our codebase · Ready to implement**

Cross-references our actual files in `lib/` and `shaders/`. Companion to
`opensource-tools-fractals.md` (deep code listings) and `refactor-plan.md` (action plan).

---

## Quick Navigation

- [Project Matrix](#project-matrix) — all 19 at a glance
- [Project Entries](#project-entries) — per-project findings
- [Synthesis: What to Build](#synthesis-what-to-build)
- [Shader Code Vault](#shader-code-vault) — copy-paste GLSL
- [Coloring Algorithm Comparison](#coloring-algorithm-comparison)
- [Precision Tier Map](#precision-tier-map)

---

## Project Matrix

| # | Project | Lang | Fractal Types | GPU | Precision | Unique Contribution |
|---|---------|------|--------------|-----|-----------|---------------------|
| 1 | **glChAoS.P** | C++/GLSL | 36 ODE attractors + IFS + DLA | OpenGL 4.1 | float | Particle GPU pipeline, PBR/SSAO, 30+ palettes |
| 2 | **mandelbulber2** | C++/OpenCL | 460+ (3D ray-march) | OpenCL | float | Full 3D DE library, AO, soft shadows, animation |
| 3 | **Psychtoolbox-3** | MATLAB/GLSL | Mandelbrot | OpenGL | float | sRGB science, minimal clean shader, Perlin noise |
| 4 | **FractalExplorer** | C++/GLSL | 7 (Multibrot, Julia, Newton, etc.) | OpenGL 3.3 | float | Complete complex-math GLSL library |
| 5 | **Fractals-Explorer** | JS+C++/GLSL | 5 + WebGL | WebGL/OpenGL/OpenCL | float | 7 coloring algos, rotation, cosine palette Case 6 |
| 6 | **FractalShark** | C++/CUDA | Mandelbrot deep zoom | CUDA | float→quad→NTT | Perturbation theory, double-float (head+tail) |
| 7 | **giulia** | C++/GLSL | Mandelbrot, Julia | OpenGL 4.0 | float+double | Dual-mode shader, 5 cosine presets, HSV 3-line |
| 8 | **shader-fractals** | GLSL | 11 (2D+3D IFS+ray-march) | OpenGL | float | Complete DE library: Mandelbulb/Mandelbox/Menger/Sierpinski |
| 9 | **DeepDrill** | Swift/macOS | Mandelbrot deep zoom | Metal? | arbitrary | Perturbation + series approx, location/palette files |
| 10 | **FractalExplorer** | C++/raylib | 10 types | OpenGL | float | Modular per-type shaders, integer power fast path |
| 11 | **Fractals-Generator** | C++/CMake | Mandelbrot+variants | CPU/GPU | float+double | Preset system, config-driven rendering |
| 12 | **MV2** | C++/GLSL 4.6 | Mandelbrot+Julia | OpenGL 4.6 | **native double** | dvec2 uniforms, reference-orbit SSBO, TAA, normal map |
| 13 | **MandlebrotSetSFML** | C++/CUDA | Any (user-defined) | CUDA | float+double | **NVRTC runtime formula compiler**, custom DSL |
| 14 | **KF2** | C++ | Mandelbrot + variants | CPU/OpenCL | MPFR arbitrary | Gold standard perturbation + series approx + glitch detection |
| 15 | **par-fractal** | Rust/WGSL | 2D+3D, Buddhabrot | WebGPU | float | Multi-pass post-FX (bloom+FXAA), LOD, preset YAML |
| 16 | **JWildfire** | Java | Flame IFS (903 variations) | GPU partial | float | Largest variation library, keyframe animation |
| 17 | **FractaVista** | C++/OpenGL | 6 (Mandelbrot..Newton) | Compute shader | float | 8× SSAA export, nlohmann/json presets, spdlog |
| 18 | **Fractl** | Rust | Mandelbrot+Julia | GPU+CPU+WASM | f32/f64 feature-flag | Compile-time precision, multithread/gpu/wasm feature flags |
| 19 | **GAPFixFractal** | C++/Qt/CUDA | 16 formulas + hybrid | CUDA | 32×uint32 arbitrary | Hybrid formula system, gradient editor, batch render |

---

## Project Entries

### 1. glChAoS.P
**Repo**: `opensource/glChAoS.P` · **Docs**: `opensource-tools-fractals.md §1`

**Unique**: Real-time GPU particle visualization of strange attractors. Transform-feedback
pipeline writes next position back to VBO without CPU roundtrip.

**Key techniques for us**:
- **30+ scientific palettes** (Magma, Viridis, Inferno, Plasma + custom) as 256-entry RGB LUTs
- **Velocity-based palette coloring**: `t = clamp(length(dvdt(pos)) * colorVel, 0, 1)` → palette sample
- **Separable Gaussian glow**: O(2σ) horizontal then vertical — not O(σ²) naive 2D
- **FXAA post-pass**: luminance edge detection + adaptive blur, ~2% GPU cost
- **Bilateral filter**: edge-aware denoise preserving fractal boundaries
- **Poisson disk soft shadows**: 16-tap pattern (listed in `refactor-plan.md §9.9`)
- **ACES/Reinhard tone mapping** after exposure/contrast/brightness correction

**Our files**: `lib/core/services/palette_service.dart`, shader glow passes (not yet built)

---

### 2. mandelbulber2
**Repo**: `opensource/mandelbulber2` · **Docs**: `opensource-tools-fractals.md §2`

**Unique**: 460+ 3D fractal formulas with OpenCL kernels, full ray-march with physically-based shading.

**Key techniques for us**:
- **Analytic DE for Mandelbulb** (spherical coords): `dr = pow(r, p-1)*p*dr + 1; final = 0.5*log(r)*r/dr`
- **Analytic linear DE for Mandelbox** (box+sphere fold): exact algorithm with correct DE accumulation
- **Smooth iteration coloring**: `n + 1 - log(log(r))/log(power)` — eliminates all banding
- **Orbit trap additive model**: `colorValue += minDist * w1 + aux_color * w2 + r/DE * w3`
- **Numerical gradient normals**: 6-tap central difference on DE function
- **Phong + soft shadows** (secondary ray march to light with `softness * d/scan` penumbra)
- **AO along normal**: 4–8 equidistant samples, compares march dist vs DE
- **Fold-count coloring for Mandelbox**: increment counter on each fold event

**UI parameter ranges** (for our sliders):
```
Mandelbulb: power 2–16, maxIter 32–512, bailout 8–20
Mandelbox: foldLimit 0.5–1.5, scale 2.0–4.0, mR² 0.1–0.5
Lighting: ambient 0.0–0.5, shininess 8–256, aoSamples 4–16
```

**Our files**: `shaders/mandelbulb.frag`, `lib/core/modules/mandelbox_module.dart`

---

### 3. Psychtoolbox-3
**Repo**: `opensource/Psychtoolbox-3` · **Docs**: `opensource-tools-fractals.md §3`

**Unique**: Neuroscience stimulus toolkit — provides the cleanest minimal Mandelbrot shader
reference plus rigorous color science.

**Key techniques for us**:
- **Minimal Mandelbrot shader** (exact formula): `c = center + (uv - 0.5) / zoom`
- **sRGB piecewise transfer function** (IEC 61966-2-1): mandatory for correct display output
- **`fract(iter * 0.01)`** anti-banding: 1 line, zero cost
- **Perlin noise GLSL library** (`ClassicPerlinNoiseLib.frag.txt`): for noise-hybrid fractals
- **Virtual texture pattern**: 1×1 GPU texture with full computation in fragment shader

**Most important code**: `linearToSRGB()` — apply as last step before `fragColor` in every shader.

**Our files**: ALL `shaders/*.frag` files need `linearToSRGB()` added (see `refactor-plan.md §2.2`)

---

### 4 & 10. FractalExplorer (two projects)
**Repos**: `opensource/FractalExplorer` (raylib/C++) · **Docs**: `opensource-tools-fractals.md §4`

**Unique**: Complete GLSL complex-number library + one shader file per fractal type (clean reference).

**Fractal types**: Multibrot (z^n+c), Multicorn (conj(z)^n+c), Burning Ship (|Re|+i|Im|)^n+c,
Julia, Newton z³−1, Newton sin(z), polynomial degree 2/3.

**Key code** (directly portable to Flutter GLSL):
```glsl
vec2 complexPow(vec2 z, float p) {
    float r = pow(dot(z,z), p*0.5);
    float a = atan(z.y, z.x) * p;
    return vec2(r*cos(a), r*sin(a));
}
// Integer fast path (avoids atan/log):
vec2 complexPowN(vec2 z, int n) {
    vec2 r = z;
    for (int i = 1; i < n; i++) r = complexMul(r, z);
    return r;
}
vec2 complexSin(vec2 z) { return vec2(sin(z.x)*cosh(z.y), cos(z.x)*sinh(z.y)); }
vec2 complexCos(vec2 z) { return vec2(cos(z.x)*cosh(z.y), -sin(z.x)*sinh(z.y)); }
```

**Newton z³−1**: colors by which of 3 roots the iteration converges to — creates basin-of-attraction artwork.

**Zoom-into-cursor algorithm** (from `controls.hpp`): required for correct zoom UX — see `refactor-plan.md §6.1`.

**Our files**: `lib/features/renderer/gesture_handler.dart`, `lib/core/modules/builders/escape_time_catalog.dart`

---

### 5. Fractals-Explorer
**Repo**: `opensource/Fractals-Explorer` · **Docs**: `opensource-tools-fractals.md §5`

**Unique**: Multi-backend (WebGL/OpenGL/OpenCL/CPU) with 7 distinct Mandelbrot coloring algorithms.

**Best coloring formula** (Case 6 — cosine palette, no texture needed):
```glsl
vec3 val = 0.5 + 0.5*cos(3.0 + smooth_*0.15 + vec3(0.0, 0.6, 1.0));
```

**Rotation support**: 2×2 rotation matrix applied in fragment shader to the complex plane.

**Zoom-into-cursor** (C++ side):
```cpp
void ZoomIntoPoint(vec2i cursor, float delta) {
    vec2f prevComplex = toCartesian(cursor);
    zoom += delta;
    offset = prevComplex - toCartesian(cursor); // re-center
}
```

**Our files**: same as above

---

### 6. FractalShark
**Repo**: `opensource/FractalShark` · **Docs**: `opensource-tools-fractals.md §6`

**Unique**: Extreme deep zoom (10^150,000 magnification) via CUDA perturbation + bilinear
approximation (BLA). The reference for GPU double-float arithmetic.

**Precision tiers**:
| Type | Bits | Zoom range |
|------|------|-----------|
| float | 32 | ~10² |
| double | 64 | ~10^15 |
| dblflt (head+tail float) | ~64 | ~10^30 |
| dbldbl | ~128 | ~10^60 |
| GPU NTT | ~500K | ~10^150,000 |

**Double-float GLSL** (from `HpSharkFloatLib/dblflt.cuh` — see `refactor-plan.md §3.1`):
```glsl
struct df2 { float hi; float lo; };
df2 df2_add(df2 a, df2 b) {
    float s = a.hi + b.hi;
    float e = (abs(a.hi) >= abs(b.hi)) ? (a.hi-s)+b.hi : (b.hi-s)+a.hi;
    return df2(s, e + a.lo + b.lo);
}
```
→ Extends useful zoom from 10^7 (float) to ~10^14 before CPU fallback.

**Perturbation theory**:
```
δ_{n+1} = 2·Z_ref_n·δ_n + δ_n² + Δc
```
Reference orbit computed once at high precision; all pixels iterate as small float deltas.

**Our files**: `lib/features/renderer/deep_zoom_precision_policy.dart`, `shaders/mandelbrot_df2.frag` (to create)

---

### 7. giulia
**Repo**: `opensource/giulia` · **Docs**: `GIULIA_TECHNICAL_ANALYSIS.md`, `GIULIA_SHADER_FORMULAS.md`

**Unique**: Clean dual-mode Mandelbrot/Julia in a single shader. The simplest correct reference implementation.

**Dual-mode pattern** (the key architectural idea):
```glsl
uniform float uJuliaMode;  // 0=Mandelbrot, 1=Julia
uniform vec2  uJuliaC;
void main() {
    vec2 c = uJuliaMode > 0.5 ? uJuliaC : pixelCoord;
    vec2 z = uJuliaMode > 0.5 ? pixelCoord : vec2(0.0);
    // one escape loop serves both modes
}
```

**Compact branchless HSV→RGB** (best version across all 19 projects):
```glsl
vec3 hsv2rgb(vec3 c) {
    vec4 K = vec4(1.0, 2.0/3.0, 1.0/3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}
```

**Known bug in giulia**: loop runs `exponent-1` times → `exponent=3` produces z⁴. Our shaders must not replicate this.

**Escape radius**: use 4.0 (not 2.0) — smoother smooth-coloring, cleaner first band.

**Our files**: `lib/core/modules/julia_dual_module.dart`, `shaders/mandel_julia_dual_gpu.frag`

---

### 8. shader-fractals
**Repo**: `opensource/shader-fractals` · **Docs**: `opensource-tools-fractals.md §8`

**Unique**: Standalone GLSL library covering 5 × 2D and 6 × 3D fractals. The fastest path to verified DE functions.

**IFS fractals** (very fast, no ray-march needed):
- **Sierpinski Carpet**: `fract(z*3)` + center-third test — depth 6, instant
- **Sierpinski Triangle**: midpoint-toward-nearest-vertex — depth 8, instant
- **Koch Curve**: line-reflection iterations — depth 6

**3D DEs** (all verified, exact formulas):
- Mandelbulb: `0.5 * log(r) * r / dr` — 250 steps, power=8 (animatable ±5)
- Mandelbox: scale=-5.446, 15 iters, 2500 steps (reduce to 150–200 for mobile)
- Menger Sponge: cross-fold, scale=3, 100 steps
- Sierpinski Tetrahedron: sum-fold, scale=2, 150 steps

**Julia preset coordinates** (6 tested interesting points):
```dart
('Dendritic',   -0.8,    0.156),
('Spiral',      -0.4,    0.6),
('Cauliflower',  0.285,  0.01),
('Flame',       -0.70176,-0.3842),
('Rabbit',      -0.835, -0.2321),
('Nautilus',     0.45,   0.1428),
```

**Shadertoy → Flutter uniform map**: `iResolution→u_resolution`, `iTime→u_time`, `iMouse→u_mouse`, `mainImage(out,in)→void main()+fragColor`

**Our files**: `lib/core/modules/builders/escape_time_catalog.dart` (add preset coords)

---

### 9. DeepDrill
**Repo**: `opensource/DeepDrill` · **Platform**: macOS Swift

**Unique**: End-to-end workflow for extreme deep zoom including location files, palette files, and
a separate `DeepMake` video composer. Demonstrates the full user-facing product around perturbation theory.

**Key learnings**:
- **Location file format**: store center (hi/lo pairs), zoom level, iteration count, and palette reference as a bundle — enables bookmarking and sharing specific fractal views
- **Palette file format**: JSON/external file separate from app binary — user-extensible
- **DeepMake**: renders a sequence of frames at increasing zoom then composites into video — this is exactly our `video_export_service.dart` use case
- **Progressive refinement UI**: shows coarse render instantly, refines in background — good UX pattern

**Our files**: `lib/core/services/history_store.dart` (could store location bundles), `lib/core/services/video_export_service.dart`

---

### 11. fractals-generator
**Repo**: `opensource/fractals-generator` · **Language**: C++/CMake with Nix flake

**Unique**: Preset-driven rendering with examples directory showing parameter combinations.

**Key learnings**:
- **examples/ directory**: ships a set of `.json` preset files — each defines fractal type, center, zoom, iteration count, colormap. Directly maps to our `FractalPreset` model.
- **Config-driven pipeline**: no hardcoded values anywhere; all parameters flow from config → renderer
- **Nix flake**: reproducible build (not directly useful for us but shows good DevX thinking)

**Our files**: `lib/core/models/fractal_preset.dart`, `lib/core/services/preset_store.dart`

---

### 12. MV2 ⭐ HIGH VALUE
**Repo**: `opensource/MV2` · **Language**: C++/GLSL 4.60

**Unique**: The most feature-complete single-shader Mandelbrot reference. Uses **native GPU double
precision** (`dvec2`, `double` uniforms), SSBOs for reference orbit, perturbation, TAA, normal map.

**Shader uniform system** (from `shaders/render.glsl`):
```glsl
uniform dvec2  center;       // native GPU double!
uniform double zoom;         // native GPU double!
uniform float  theta;        // rotation angle
uniform bool   perturbation; // flag: use reference orbit
uniform bool   series_approx;// flag: use SA skip
uniform bool   cardioid_check;// early-out for bulb/cardioid
uniform bool   taa;          // temporal anti-aliasing
uniform bool   normal_map_effect;
uniform float  height;       // normal map bump height
uniform float  angle;        // normal map light angle
uniform float  iter_multiplier; // color speed
uniform float  spectrum_offset; // palette rotation
uniform int    transfer_function; // coloring mode
uniform int    ssaa_factor;  // supersampling 1–4×
uniform int    fractal;      // fractal type selector
uniform float  power;        // z^power
uniform dvec2  initialz;     // z₀ for Julia
```

**SSBO layout**:
```glsl
layout(std430, binding=5) readonly buffer reference_orbit { dvec2 reference[]; };
layout(std430, binding=2) readonly buffer spectrum       { vec4 spec[]; };
layout(std430, binding=3) readonly buffer variables      { float sliders[]; };
layout(std430, binding=4) readonly buffer kernel         { float weights[]; };
```

**Normal map coloring** (reference: math.univ-toulouse.fr Cheritat):
Uses the iteration gradient (u vector) to simulate lighting on the fractal boundary — produces
a 3D-embossed appearance with zero ray-marching cost.

```glsl
// After escape with z = (zx, zy):
vec2 u = normalize(vec2(zx, zy)); // escape direction
// Shading = dot(u, lightDir) gives bump-mapped appearance
float shade = dot(u, vec2(cos(angle), sin(angle)));
col *= 0.5 + 0.5 * shade;
```

**TAA (Temporal Anti-Aliasing)**: accumulates previous frames with jittered sub-pixel samples.
Uses `prevFrameTex` sampler and `accIndex` image for frame counting.

**High-precision atan2 in GLSL**: 10-term polynomial using FMA chain (see shader lines 30–70)
for correct atan2 with double inputs where hardware double support is unavailable.

**Cardioid/period-2-bulb check**: early-out test to skip main cardioid and largest bulb — saves
~40–50% iterations for standard overview zooms:
```glsl
// Cardioid: p = sqrt((x-0.25)^2 + y^2); x < p - 2p^2 + 0.25 → inside
// Period-2 bulb: (x+1)^2 + y^2 < 0.0625 → inside
```

**Our files**: `shaders/mandelbrot_et.frag` (add normal map mode, cardioid check), `shaders/mandelbrot_df2.frag` (use dvec2 uniforms if Impeller/GLES supports them — check first)

---

### 13. MandlebrotSetSFML ⭐ HIGH VALUE
**Repo**: `opensource/MandlebrotSetSFML` · **Language**: C++/CUDA

**Unique**: **Runtime formula compiler** using NVRTC. Users type a formula in a DSL, it compiles to
CUDA PTX at runtime and runs on GPU. This is the most flexible formula system of all 19 projects.

**Formula DSL variables**:
- `z_real`, `z_imag` — current iteration state
- `real`, `imag` — pixel coordinate (constant per pixel)
- `new_real` — store next real part here (system copies to `z_real` after)
- `z_comp` — pre-computed `z_real²+z_imag²` for escape check
- `PI`, `GOLDEN_RATIO` — constants

**Example custom formulas**:
```cpp
// Burning Ship:
new_real = z_real*z_real - z_imag*z_imag + real;
z_imag = 2*fabs(z_real)*fabs(z_imag) + imag;

// Custom: sin-enhanced Mandelbrot:
new_real = sin(z_real)*z_real - z_imag*z_imag + real;
z_imag = 2*z_real*z_imag + imag;
```

**Flutter equivalent**: Our `frm/` parser (`frm_lexer.dart`, `frm_parser.dart`, `frm_ast.dart`) is
exactly this idea — a formula DSL that generates GLSL shader code. **We already have this feature!**
Ensure the DSL supports: `sin`, `cos`, `fabs`, `PI`, `GOLDEN_RATIO`, `pow`, `exp`, `log`, `sqrt`.

**Our files**: `lib/features/formulas/frm/frm_lexer.dart`, `frm_parser.dart`, `frm_ast.dart`

---

### 14. KF2 (Kalles Fraktaler 2)
**Repo**: `opensource/kf2` · **Docs**: agent analysis (KF2 section above)

**Unique**: The gold standard for deep-zoom correctness. Used by the fractal community for
record-setting zoom depths. Implements the full perturbation + series approximation + glitch
correction stack.

**Three-tier perturbation system**:
1. **Reference orbit**: compute center point at MPFR precision, store as `dvec2[]` array
2. **Series approximation**: fit Taylor coefficients to skip early iterations (Horner evaluation)
3. **Glitch correction**: detect bad pixels (bailout criterion violated during perturbation),
   re-render with new reference point

**Series approximation strategy**:
- Probe image with 3×3 grid of points
- Compute A[k] coefficients for complex Taylor series
- Binary search for the last consistent skip-point
- Auto-tune term count: `nTerms ≈ sqrt(pixel_count) * 0.021`

**Glitch detection criterion**:
```cpp
if (delta_magnitude < reference_magnitude * epsilon) bGlitch = TRUE;
```
Where `epsilon` is tuned per zoom level.

**MPFR precision management**: precision bits = `ceil(zoom_exponent * log2(10)) + 64` guard bits.

**Our files**: `lib/features/renderer/deep_zoom_precision_policy.dart`, `lib/features/renderer/cpu_render_isolate.dart`

---

### 15. par-fractal ⭐ HIGH VALUE
**Repo**: `opensource/par-fractal` · **Language**: Rust/WGSL · **Has CLAUDE.md**

**Unique**: Modern WebGPU renderer with the most complete post-processing pipeline and adaptive LOD system.

**5-pass render pipeline**:
```
Scene → Bloom Extract → Horizontal Blur → Vertical Blur → Composite → FXAA
```
Each pass writes to a named texture; passes are independent render graph nodes.

**LOD profiles** (from `src/lod.rs`):
| Level | Ray steps | Min dist | Shadow samples | Scale |
|-------|-----------|---------|----------------|-------|
| Ultra | 325 | 0.00035 | 128 | 1.0 |
| High | 250 | 0.0007 | 64 | 0.85 |
| Medium | 175 | 0.0015 | 32 | 0.7 |
| Low | ~100 | ~0.003 | 16 | 0.5 |

**LOD strategies**: Distance, Motion (lower during pan/zoom), Performance (maintain target FPS), Hybrid.

**WGSL uniform alignment** (critical lesson):
Rust structs passed to GPU MUST have explicit `_padding` fields to achieve 16-byte alignment for
every `vec3`/`mat4` field. Flutter's `FragmentShader.setFloat()` has the same requirement —
uniform ordering is the API contract.

**Preset YAML system**: load/save all rendering parameters as `~/.config/par-fractal/settings.yaml`.
Maps directly to our `FractalPreset` + `preset_store.dart`.

**Buddhabrot compute shader**: atomic buffer accumulation — each escaped trajectory adds to a
density buffer rather than coloring by escape iteration count. Produces nebula-like images.

**Our files**: `lib/features/renderer/fractal_painter.dart` (multi-pass), `lib/core/services/preset_store.dart`

---

### 16. JWildfire
**Repo**: `opensource/JWildfire` · **Language**: Java

**Unique**: 903 parameterizable variation functions for flame IFS fractals. The largest open-source
variation library. Also includes "Dancing Flames" (audio-reactive animation) and MutaGen (genetic
mutation of parameter sets).

**Variation plugin architecture**:
```java
abstract class VariationFunc {
    abstract void transform(FlameTransformationContext ctx,
                            XForm xform, XYZPoint in, XYZPoint out, double amount);
    abstract String getName();
    abstract String[] getParameterNames();
    abstract Object[] getParameterValues();
}
```

**Transform pipeline**: `Point → Affine Matrix → Var1 → Var2 → ... → VarN → Output`

**IFS iteration** (chaos game):
```
1. Start at origin
2. Choose random XForm by weight
3. Apply affine + variations to current point
4. Plot resulting point (after burn-in)
5. Repeat ~10M times
```

**Variation categories relevant to fractals**:
- `swirl`: `r * (cos(θ+r), sin(θ+r))` — spiral distortion
- `spherical`: `v / |v|²` — inversion about unit circle
- `polar`: `(r, θ, φ)` coordinate remap
- `heart`, `diamond`, `ex`, `julia`, `exponential`, `power`

**Audio-reactive animation** (Dancing Flames): maps audio frequency bands to variation parameter
envelopes. In our context: could map to parameter oscillation.

**Our files**: could add IFS chaos-game renderer as a new module (`lib/core/modules/ifs_module.dart`)

---

### 17. FractaVista
**Repo**: `opensource/FractaVista` · **Language**: C++17/OpenGL 4.3

**Unique**: OpenGL **compute shaders** (not fragment shaders) for fractal generation. Clean
modular architecture with nlohmann/json for preset serialization and spdlog for structured logging.

**6 fractal types**: Mandelbrot, Julia, Burning Ship, Cubic Mandelbrot (`z³+c`), Tricorn, Newton.

**Compute shader approach**: dispatches `width/8 × height/8` work groups; each thread computes
one pixel. Writes directly to image2D. Different from fragment shader approach:
- **Advantages**: explicit control over work distribution, easier shared memory
- **Flutter**: fragment shaders are the only option in `FragmentProgram` API; compute not available

**8× SSAA export**: renders at 8× resolution then downscales — highest quality export pattern.

**nlohmann/json presets** (maps to our Dart `FractalPreset`):
```json
{
  "fractal": "mandelbrot",
  "center": [-0.5, 0.0],
  "zoom": 300.0,
  "maxIter": 256,
  "colorScheme": "viridis",
  "power": 2.0
}
```

**Our files**: `lib/core/models/fractal_preset.dart`, `lib/core/services/preset_store.dart`

---

### 18. Fractl
**Repo**: `opensource/Fractl` · **Language**: Rust

**Unique**: Compile-time feature flags selecting precision and backend.

**Feature flag system** (Cargo features):
```
f32 ↔ f64          (mutually exclusive: precision)
multithread ↔ gpu  (mutually exclusive: backend)
f64 ↔ gpu          (mutually exclusive: GPU only supports f32)
```

This enforces at compile time that you can't run f64 on GPU (it doesn't exist on most mobile GPUs).

**Lesson for Flutter**: Our `deep_zoom_precision_policy.dart` should mirror this logic:
- GPU shader: always float (GLSL ES 3.0), unless GLSL 4.6 double extension available
- df2 shader: emulated double via two floats
- CPU isolate: Dart `double` (64-bit IEEE 754)

**WASM support**: Fractl compiles to WebAssembly for browser rendering. Relevant for any
future Flutter Web fractal support.

**Our files**: `lib/features/renderer/backend_policy.dart`

---

### 19. GAPFixFractal ⭐ UNIQUE
**Repo**: `opensource/GAPFixFractal` · **Language**: C++/Qt5/CUDA

**Unique**: The most sophisticated arbitrary-precision fractal renderer with a hybrid formula system,
gradient editor, and CUDA acceleration.

**16 built-in formulas**:
`standard`, `lambda`, `spider`, `tricorn`, `ship`, `mix`, `sqtwice_a`, `sqtwice_b`,
`celtic`, `magnet_a`, `facing`, `facing_b`, `rings`, `e90_mix`, `tails`, `testing`

**Hybrid formula dialog**: combine multiple formulas with configurable switching conditions —
e.g. "use formula A for first 50 iterations, then formula B." Creates fractal types impossible
with a single formula.

**Arbitrary precision**: stores center/width as arrays of `uint32_t[nwords]` where `nwords ≤ 32`.
Each word is a 32-bit limb of a fixed-point number. 32 words → 1024-bit precision.

**Gradient editor**: interactive UI for building color gradients with anchor points and interpolation
modes (linear, step, cosine). Maps to our `FractalPalette` model.

**Batch render system**: queue of (location, resolution, maxIter, palette) tuples → renders to
files. Maps to our `batch_export_service.dart`.

**Pixel coordinate encoding** (clever trick for GPU dispatch):
```cpp
uint32_t encode_coord(int x, int y, int w, int h) {
    uint16_t x1 = x - w/2;   // center origin
    uint16_t y1 = y - h/2;
    return (uint32_t)y1 * 65536 + x1;
}
```
Single uint32 encodes both x and y relative to center — compact GPU dispatch.

**Our files**: `lib/core/models/fractal_palette.dart`, `lib/core/services/batch_export_service.dart`

---

## Synthesis: What to Build

Ranked by impact/effort ratio across all 19 projects.

### Tier 1 — One-line/few-line fixes with dramatic visual impact

| Fix | Source | Our File | Effort |
|-----|--------|---------|--------|
| Add `linearToSRGB()` to all shaders | Psychtoolbox-3 | All `shaders/*.frag` | 1h |
| Smooth iteration formula (log-log) | All 19 projects | `mandelbrot_et.frag` | 30min |
| Cosine palette 3-channel with phase | giulia/Fractals-Explorer | `mandelbrot_et.frag` | 30min |
| Escape radius 4.0 instead of 2.0 | giulia | `escape_time_catalog.dart` | 5min |
| Add Julia preset coordinates (6 points) | shader-fractals | `escape_time_catalog.dart` | 30min |
| Cardioid/bulb early-out check | MV2 | `mandelbrot_et.frag` | 30min |
| Branchless HSV→RGB (3-line) | giulia | Any HSV shader | 10min |

### Tier 2 — New features with clear implementation path

| Feature | Source | Our File | Effort |
|---------|--------|---------|--------|
| Orbit trap coloring (point+line) | mandelbulber2 | `mandelbrot_et.frag` | 2h |
| Normal map coloring | MV2 | `mandelbrot_et.frag` | 3h |
| Dual-mode Mandelbrot/Julia shader | giulia | new `mandel_julia_dual_gpu.frag` | 4h |
| df2 shader (double-float precision) | FractalShark | new `mandelbrot_df2.frag` | 1 day |
| Separable Gaussian glow | glChAoS.P | new `post_glow_h/v.frag` | 4h |
| FXAA post-pass | glChAoS.P / par-fractal | new `post_fxaa.frag` | 3h |

### Tier 3 — New modules (new Dart+shader pairs)

| Module | Source | Our Files | Effort |
|--------|--------|---------|--------|
| Menger Sponge 3D | shader-fractals | `shaders/menger_sponge_gpu.frag` + catalog entry | 2h |
| Sierpinski Tetrahedron | shader-fractals | `shaders/sierpinski_tetrahedron_gpu.frag` + entry | 2h |
| Mandelbox 3D | mandelbulber2 / shader-fractals | new `shaders/mandelbox_3d_gpu.frag` + module | 4h |
| IFS (Sierpinski carpet/triangle) | shader-fractals | verify existing shaders + catalog entries | 1h |
| Newton sin(z) | FractalExplorer | new shader + catalog entry | 2h |
| Burning Ship (correct) | FractaVista / GAPFixFractal | verify `shaders/burning_ship_gpu.frag` | 1h |
| Tricorn / Multicorn | FractaVista | verify or add | 1h |
| Cubic Mandelbrot (z³+c) | FractaVista | new catalog entry, reuse `complexPowN` | 1h |

### Tier 4 — Architecture enhancements

| Enhancement | Source | Our Files | Effort |
|-------------|--------|---------|--------|
| Location bundle (center hi/lo + zoom + palette) | DeepDrill | `fractal_preset.dart` + `history_store.dart` | 4h |
| LOD during pan/zoom | par-fractal | `fractal_renderer.dart` + `performance_service.dart` | 1 day |
| Palette SSBO / 256-entry LUT | MV2 / glChAoS.P | `palette_service.dart` + shader sampler | 4h |
| Hybrid formula switcher | GAPFixFractal | `lib/features/formulas/` | 1 week |
| Perturbation theory reference orbit | KF2 / MV2 | `cpu_render_isolate.dart` + new shader | 2 weeks |
| TAA (temporal anti-aliasing) | MV2 | `fractal_painter.dart` | 1 week |
| Bloom post-pass | par-fractal | new shader pair | 1 day |

### Tier 5 — Long-term / advanced

| Enhancement | Source | Notes |
|-------------|--------|-------|
| Strange attractor module (Lorenz etc.) | glChAoS.P | ODE step in GPU via iterative rendering |
| Full series approximation | KF2 | Requires reference orbit + coefficient storage |
| Glitch detection + correction | KF2 | Requires perturbation first |
| Flame IFS chaos-game renderer | JWildfire | Density accumulation buffer |
| Audio-reactive parameters | JWildfire Dancing Flames | Needs audio input pipeline |
| Buddhabrot accumulation mode | par-fractal | Compute-shader equivalent via progressive render |

---

## Shader Code Vault

Ready-to-paste GLSL ES 3.0 / 3.1 snippets for Flutter's `FragmentProgram`.

### A. sRGB Gamma Correction (from Psychtoolbox-3)
```glsl
// Apply as LAST step before fragColor in every shader
vec3 linearToSRGB(vec3 lin) {
    bvec3 lo = lessThan(lin, vec3(0.00304));
    return mix(
        1.055 * pow(max(lin, vec3(0.00304)), vec3(1.0/2.4)) - 0.055,
        12.92 * lin,
        vec3(lo)
    );
}
```

### B. Smooth Iteration Count (universal — from all projects)
```glsl
// Form 1: power=2, fastest
float smoothIter(int it, vec2 z) {
    return float(it) + 1.0 - log2(log2(max(dot(z,z), 1.001)));
}
// Form 2: generalized power n
float smoothIterN(int it, float r2, float power) {
    return float(it) + 1.0 - log(log(max(sqrt(r2), 1.001))) / log(power);
}
```

### C. Cosine Palette (from giulia scheme 4 / Fractals-Explorer Case 6)
```glsl
// Best no-texture coloring formula — 4 built-in presets:
vec3 cosinePalette(float t, vec3 phase) {
    return 0.5 + 0.5 * cos(6.28318 * (t + phase));
}
vec3 palette(float t, int scheme) {
    if (scheme == 0) return cosinePalette(t, vec3(0.00, 0.33, 0.67)); // Fire
    if (scheme == 1) return cosinePalette(t, vec3(0.50, 0.60, 0.70)); // Ocean
    if (scheme == 2) return cosinePalette(t, vec3(0.00, 0.10, 0.20)); // Midnight
    if (scheme == 3) return cosinePalette(t, vec3(0.80, 0.50, 0.40)); // Sunset
    return vec3(t); // grayscale
}
```

### D. Compact HSV→RGB (giulia — branchless, 3 lines)
```glsl
vec3 hsv2rgb(vec3 c) {
    vec4 K = vec4(1.0, 2.0/3.0, 1.0/3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}
```

### E. Complex Number Library (FractalExplorer)
```glsl
vec2 cMul(vec2 a, vec2 b) {
    return vec2(a.x*b.x - a.y*b.y, a.x*b.y + a.y*b.x);
}
vec2 cDiv(vec2 a, vec2 b) {
    float d = dot(b, b);
    return vec2(dot(a,b), a.y*b.x - a.x*b.y) / d;
}
vec2 cPow(vec2 z, float p) {
    float r = pow(dot(z,z), p*0.5);
    float a = atan(z.y, z.x) * p;
    return vec2(r*cos(a), r*sin(a));
}
vec2 cPowN(vec2 z, int n) { vec2 r=z; for(int i=1;i<n;i++) r=cMul(r,z); return r; }
vec2 cSin(vec2 z) { return vec2(sin(z.x)*cosh(z.y),  cos(z.x)*sinh(z.y)); }
vec2 cCos(vec2 z) { return vec2(cos(z.x)*cosh(z.y), -sin(z.x)*sinh(z.y)); }
```

### F. Cardioid + Period-2 Bulb Early Exit (MV2)
```glsl
// Returns true if pixel is inside main cardioid or period-2 bulb → skip iteration
bool inMainBulb(vec2 c) {
    float x = c.x - 0.25, y2 = c.y*c.y;
    float p = sqrt(x*x + y2);
    if (c.x < p - 2.0*p*p + 0.25) return true;    // cardioid
    if ((c.x+1.0)*(c.x+1.0) + y2 < 0.0625) return true; // period-2
    return false;
}
```

### G. Normal Map Effect (MV2 / Cheritat)
```glsl
// Call after escape loop; z is the escaped value, angle is light angle
float normalMapShade(vec2 z, int it, float angle, float height) {
    // Iteratively extract the gradient direction
    vec2 u = vec2(cos(angle), sin(angle));
    vec2 v = z / length(z);          // escape direction
    float shade = dot(u, v) * 0.5 + 0.5;
    return clamp(shade, 0.0, 1.0);
}
```

### H. Orbit Trap Coloring (mandelbulber2)
```glsl
// Add to iteration loop: track min distance to origin (point trap)
float minDist = 1e10;
for (int i = 0; i < maxIter; i++) {
    z = cMul(z,z) + c;
    minDist = min(minDist, length(z));   // point trap
    // or: min(minDist, abs(z.x));       // line trap (Re axis)
    // or: min(minDist, abs(length(z)-1.0)); // circle trap
    if (dot(z,z) > bailout) { escape_it = i; break; }
}
float t = clamp(minDist * 0.5, 0.0, 1.0);
```

### I. Mandelbulb DE (shader-fractals — verified)
```glsl
float mandelbulbDE(vec3 pos, float power) {
    vec3 z = pos; float dr = 1.0, r = 0.0;
    for (int i = 0; i < 10; i++) {
        r = length(z);
        if (r > 2.0) break;
        float theta = acos(z.z/r) * power;
        float phi   = atan(z.y, z.x) * power;
        float rp    = pow(r, power);
        dr = pow(r, power-1.0) * power * dr + 1.0;
        z = rp * vec3(sin(theta)*cos(phi), sin(phi)*sin(theta), cos(theta)) + pos;
    }
    return 0.5 * log(r) * r / dr;
}
```

### J. Menger Sponge DE (shader-fractals — verified)
```glsl
float mengerDE(vec3 z) {
    float scale = 3.0; int n = 0;
    while (n < 25 && length(z) < 2.0) {
        z = abs(z);
        if (z.x<z.y) z.xy=z.yx; if (z.x<z.z) z.xz=z.zx; if (z.y<z.z) z.yz=z.zy;
        z *= scale; z -= vec3(scale-1.0)*0.5;
        if (z.z < -(scale-1.0)*0.5) z.z += scale-1.0;
        n++;
    }
    return (length(z)-1.5) * pow(scale, -float(n));
}
```

### K. Sierpinski Tetrahedron DE (shader-fractals — verified)
```glsl
float sierpinskiTetraDE(vec3 z) {
    float scale = 2.0; int n = 0;
    while (n < 15 && length(z) < 2.0) {
        if (z.x+z.y<0.0) z.xy=-z.yx;
        if (z.x+z.z<0.0) z.xz=-z.zx;
        if (z.y+z.z<0.0) z.yz=-z.zy;
        z = z*scale - vec3(scale-1.0);
        n++;
    }
    return length(z) * pow(scale, -float(n));
}
```

### L. Double-Float (head+tail) — from FractalShark
```glsl
// Extends Mandelbrot zoom to ~10^14 without arbitrary precision
struct df2 { float hi; float lo; };
df2 df2_from(float v) { return df2(v, 0.0); }
df2 df2_add(df2 a, df2 b) {
    float s = a.hi + b.hi;
    float e = (abs(a.hi) >= abs(b.hi)) ? (a.hi-s)+b.hi : (b.hi-s)+a.hi;
    return df2(s, e + a.lo + b.lo);
}
df2 df2_mul(df2 a, df2 b) {
    // Dekker split (no fma needed for GLSL ES 3.0)
    float c = (4097.0) * a.hi;
    float ahi = c-(c-a.hi), alo = a.hi-ahi;
    float bhi = c-(c-b.hi), blo = b.hi-bhi;
    float p = a.hi * b.hi;
    float e = ((ahi*bhi-p) + ahi*blo + alo*bhi) + alo*blo;
    return df2(p, e + a.hi*b.lo + a.lo*b.hi);
}
```

### M. Perturbation Theory Delta Update (FractalShark / KF2)
```glsl
// GPU thread per pixel, refOrbit[] pre-loaded from SSBO or texture
for (int i = 0; i < maxIter; i++) {
    float Zx = refOrbit[i].x, Zy = refOrbit[i].y;
    float nx = 2.0*(Zx*dx - Zy*dy) + dx*dx - dy*dy + dc_x;
    float ny = 2.0*(Zx*dy + Zy*dx) + 2.0*dx*dy       + dc_y;
    dx = nx; dy = ny;
    // Rebasing: restart reference when delta dominates
    if (dx*dx+dy*dy > (Zx+dx)*(Zx+dx)+(Zy+dy)*(Zy+dy)) {
        dx=Zx+dx; dy=Zy+dy;
    }
    if (dx*dx+dy*dy > 4.0) { escape_it = i; break; }
}
```

---

## Coloring Algorithm Comparison

| Algorithm | Visual Quality | GPU Cost | Texture Needed | Source |
|-----------|---------------|---------|----------------|--------|
| Step (iter/maxIter) | ❌ heavy banding | free | no | — |
| Smooth (log-log) | ✅ no banding | +1 log/sqrt | no | All projects |
| Cosine palette | ✅ beautiful cycles | +3 cos | no | giulia/Fractals-Explorer |
| HSV cycling | ✅ full spectrum | +1 atan | no | FractalExplorer |
| Orbit trap (point) | ✅ adds detail | +min per iter | no | mandelbulber2 |
| Orbit trap (line) | ✅✅ striking | +min per iter | no | mandelbulber2 |
| Normal map | ✅✅ 3D-like | +2 log/atan | no | MV2 |
| Palette LUT (256 tex) | ✅✅ flexible | +1 tex fetch | yes (1×256) | glChAoS.P |
| Mandelbulber2 additive | ✅✅✅ richest | +N per iter | yes | mandelbulber2 |
| Distance estimator | ✅✅✅ edge detail | +full DE | no | mandelbulber2 |

---

## Precision Tier Map

| Zoom Level | Backend | Our Implementation |
|-----------|---------|-------------------|
| < 1×10^6 | float shader (`mandelbrot_et.frag`) | ✅ exists |
| 1×10^6 – 1×10^14 | df2 shader (`mandelbrot_df2.frag`) | 🔲 needs building |
| 1×10^14 – 1×10^60 | CPU isolate (Dart double) | ✅ `cpu_render_isolate.dart` |
| > 1×10^60 | CPU + MPFR or perturbation | 🔲 future work |

**Transition triggers** (`deep_zoom_precision_policy.dart`):
- `5e6` → switch from float to df2 shader
- `1e14` → switch to CPU isolate
- During pan/zoom → reduce iteration count (LOD, from par-fractal)

---

## Mapping to Our Feature Tree

```
lib/features/renderer/
  fractal_renderer.dart       ← shader selection, precision policy, LOD during gesture
  fractal_painter.dart        ← multi-pass (glow, FXAA, bloom from par-fractal)
  gesture_handler.dart        ← zoom-into-cursor fix (Fractals-Explorer algorithm)
  deep_zoom_precision_policy  ← df2 tier (FractalShark), perturbation trigger (KF2)
  cpu_render_isolate.dart     ← MPFR equiv, reference orbit for perturbation (KF2)

lib/core/modules/
  builders/escape_time_catalog.dart  ← add 6 Julia presets, normal-map mode, orbit trap mode
  mandelbox_module.dart              ← Mandelbox 3D (mandelbulber2 exact)
  julia_dual_module.dart             ← dual-mode shader (giulia)
  nova_module.dart                   ← Newton (FractalExplorer)
  phoenix_module.dart                ← verify/add (GAPFixFractal formula list)

lib/core/services/
  palette_service.dart     ← add Magma/Viridis/Inferno/Plasma (glChAoS.P LUTs)
  preset_store.dart        ← JSON format with all params (FractaVista / par-fractal YAML)
  history_store.dart       ← location bundle (DeepDrill: center hi/lo + zoom + palette)
  batch_export_service.dart← queue-based batch (GAPFixFractal)

lib/features/formulas/frm/
  frm_lexer.dart           ← already exists; add PI, GOLDEN_RATIO, fabs (MandlebrotSetSFML DSL)
  frm_parser.dart
  frm_ast.dart

shaders/ (new files needed)
  mandelbrot_df2.frag      ← double-float Mandelbrot (FractalShark)
  mandel_julia_dual_gpu.frag ← dual-mode (giulia)
  mandelbox_3d_gpu.frag    ← Mandelbox ray-marcher (mandelbulber2 + shader-fractals)
  post_glow_h.frag         ← separable Gaussian H (glChAoS.P)
  post_glow_v.frag         ← separable Gaussian V
  post_fxaa.frag           ← FXAA (par-fractal / glChAoS.P)
  post_bloom_extract.frag  ← bloom bright-pass (par-fractal)

shaders/ (modify existing)
  mandelbrot_et.frag       ← +linearToSRGB, +cardioid_check, +normal_map_effect, +orbit_trap
  mandel_step_smooth.frag  ← +linearToSRGB, +orbit_trap
  mandelbulb.frag          ← verify DE formula; +sRGB; +Poisson soft shadows
  ALL *_gpu.frag           ← +linearToSRGB, +cosinePalette()
```

---

*Generated: 2026-02-17 | Sources: 19 open-source fractal projects*
*Companion docs: `opensource-tools-fractals.md` (deep code) · `refactor-plan.md` (action plan)*
*Agent analyses: `GIULIA_TECHNICAL_ANALYSIS.md` · `TECHNICAL_ANALYSIS_GPU_RENDERING.md`*
*Agent analyses: `OPENSOURCE_TECHNICAL_ANALYSIS.md` · `FRACTAL_SHADER_TECHNIQUES_CATALOG.md`*
