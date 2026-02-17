# Flutter Fractal Forge — Refactoring & Enhancement Plan Prompt

> Paste the text below directly into an LLM. It provides all the context needed to produce
> a concrete, file-level implementation plan.

---

## Prompt

I'm working on **Flutter Fractal Forge** — a production Flutter app that renders fractals using
GPU fragment shaders (GLSL ES 3.0 via Flutter's `FragmentShader` / `FragmentProgram` API). The
app targets Linux desktop, Android, and iOS. Active Dart SDK: 3.10.7. Flutter uses Impeller on
Android (OpenGL ES backend) and Skia on Linux.

### Current Architecture

Feature-first layout under `lib/`:

```
lib/
  core/
    modules/
      fractal_module.dart        # FractalModule, FractalRenderState, UniformSetter typedef
      module_registry.dart       # ModuleRegistry — merges catalog + custom modules at startup
      builders/
        escape_time_catalog.dart # Declarative EscapeTimeConfig list (1 entry = 1 fractal)
        escape_time_builder.dart # Builds FractalModule from EscapeTimeConfig
      julia_module.dart          # Custom: extra seed params (cx, cy)
      phoenix_module.dart        # Custom: relaxation params (p, q)
      nova_module.dart           # Custom: Nova Julia with relaxation
      mandelbulb_module.dart     # Custom: 3D ray-march with rotation uniforms
    models/
      fractal_parameter.dart     # FractalParameter (float/int/bool/enum, range, step)
      fractal_params.dart        # FractalParams (Map<String, Object> param values)
      fractal_view_state.dart    # FractalViewState (pan offset, zoom, rotation angles)
      fractal_preset.dart        # FractalPreset (named snapshot of params + view)
      fractal_palette.dart       # FractalPalette (256-entry RGBA LUT)
    services/
      shader_service.dart        # FragmentProgram loading + caching
      palette_service.dart       # Palette LUT generation + GPU texture upload
      export_service.dart        # RenderRepaintBoundary → PNG/JPEG bytes
      performance_service.dart   # FPS tracking, frame budget monitoring
    shaders/
      uniform_schema.dart        # UniformSchema — slot layout for each shader type
  features/
    renderer/
      fractal_renderer.dart      # FractalRenderer widget (StatefulWidget + AnimationController)
      fractal_painter.dart       # CustomPainter — calls shader.setFloat / setImageSampler
      fractal_canvas.dart        # GestureDetector wrapper
      gesture_handler.dart       # Pan / zoom / fling / pinch-rotate logic
      fractal_provider.dart      # FractalController (ChangeNotifier, via Provider package)
      cpu_fractal_renderer.dart  # CPU fallback (Isolate-based tile rendering)
      deep_zoom_precision_policy.dart  # Selects float vs dblflt tier based on zoom level
      backend_policy.dart        # GPU vs CPU decision (GPU health + Impeller detection)
    catalog/
      catalog_repository.dart    # Groups all modules by dimension (2D / 3D)
      fractal_catalog_screen.dart
    auto_explore/
      auto_explore_service.dart  # Autonomous zoom/pan path generation
    export/
      batch_export_dialog.dart
      video_export_sheet.dart
    debug/
      shader_lab_screen.dart     # Live shader editing / hot-reload
```

**State management**: `provider` package — `FractalController` as `ChangeNotifier`.
Do NOT propose migrating to Riverpod, BLoC, or any other state management library.

**Adding a new escape-time fractal today** (the happy path):
1. Write a `.frag` shader following the standard uniform layout
2. Add one `EscapeTimeConfig(...)` entry to `escape_time_catalog.dart`
3. Register the shader in `pubspec.yaml` under `flutter.shaders`

**Currently implemented modules**:
- 2D escape-time (via catalog): Mandelbrot, Burning Ship, Tricorn, Multibrot, Newton z³−1,
  Newton sin(z), Multicorn, Lyapunov, Nova Julia, and several perturbation variants
- 2D custom modules: Julia (user-moveable seed), Phoenix, Nova
- 3D: Mandelbulb power-8 (ray-marched)
- Diagnostic shaders (debug builds only): always-red, gradient, sampler, coord tests

### Known Bugs to Fix (must be addressed before new features)

**Bug 1 — `ProviderNotFoundException` for `FractalController`**
Navigating directly to `FractalViewerScreen` throws because `Provider<FractalController>` is not
in scope on that route. The fix must preserve the existing lookup pattern used by `FractalRenderer`
(`context.read<FractalController>()`).

**Bug 2 — `_isTest` assert trick causes black screen in all debug builds**
`FractalRenderer` uses `assert(() { _isTest = true; return true; }())` to detect test mode,
which fires in ALL debug builds (not just integration tests), causing the renderer to show a
black `ColoredBox` placeholder instead of GPU output. There is an existing
`--dart-define=FORCE_GPU_RENDER=true` escape hatch but the underlying design is fragile.
Target state: clean `RuntimeModeService` injection with explicit test/debug/release modes.

**Bug 3 — Residual image package v4.x call sites**
`export_service.dart` and `ar_video_exporter.dart` were patched (`copyInto` → `compositeImage`,
`Animation()` → frame list + `addFrame`/`encodeGif`, `Format.bgra` → `ChannelOrder.bgra`) but
other callers may remain. Verify no pre-v4 API calls exist anywhere in the codebase.

### Open-Source Research (already completed — cite these in your plan)

Eight reference projects are cloned locally. Full algorithm extractions with exact GLSL code
are in `opensource/opensource-tools-fractals.md`. Key findings per project:

**FractalExplorer** (`opensource/FractalExplorer`, C++/raylib/GLSL 3.30):
- Complete GLSL complex number library: `ComplexMultiply`, `ComplexDivide`, `ComplexPow`,
  `ComplexSin`, `ComplexCos` — directly portable to GLSL ES 3.0
- Integer power optimisation: replace the `atan`/`log` path with a `ComplexMultiply` loop for
  whole-number exponents (2–3× faster for z², z³)
- Smooth iteration `nu` formula: `log(log(ComplexAbsSquared(z))/2.0/log(2.0)) / log(power)`
- HSV→RGB (branching, human-readable version)

**Fractals-Explorer** (`opensource/Fractals-Explorer`, JS/GLSL ES 3.0 + C++/OpenCL):
- **Cosine palette trick** (Case 6, best no-texture formula):
  `0.5 + 0.5*cos(3.0 + smooth*0.15 + vec3(0.0, 0.6, 1.0))`
- Rotation matrix in coordinate mapping (supports fractal rotation as a uniform)
- Zoom-into-cursor algorithm: `offset = prevComplex - toCartesian(cursor)` — preserves the
  world point under the cursor; verify our `gesture_handler.dart` implements this invariant
- Template-substituted Newton shaders: host replaces `%%FUNCTION`/`%%DERIVATIVE`/`%%ROOTS`
  before GPU compilation, enabling arbitrary polynomial Newton fractals without shader variants

**FractalShark** (`opensource/FractalShark`, C++/CUDA):
- **Double-float arithmetic** (head+tail, Knuth 2-sum / Dekker split): emulates ~14 decimal
  digits from two `float`s; extends usable zoom from ~10^7 (single float) to ~10^14:
  ```glsl
  // Add: s = a.head + b.head; err = (a.head - s) + b.head
  // Mul: t = a.head * b.head; err = a.head*b.head - t  (approx fma)
  ```
  This is the correct next tier for `deep_zoom_precision_policy.dart`.
- **Perturbation theory**: reference orbit Z_n computed at high precision on CPU; GPU iterates
  per-pixel delta `δ_{n+1} = 2·Z_n·δ_n + δ_n² + Δc` in float — dramatic quality improvement
  at deep zoom with no per-pixel precision cost
- Rebasing check: when `|δ|² > |Z+δ|²`, reset delta and restart reference from that index
- Reference orbit transport: CPU `double[]` → `Float32List` → Flutter `ImageShader` (1D
  texture) passed to shader via `setImageSampler`

**giulia** (`opensource/giulia`, C++/GLSL 4.0 + OpenCL):
- Dual-mode Mandelbrot/Julia in a single shader: `uniform bool juliaMode; uniform vec2 juliaC;`
  — mouse/tap on Mandelbrot view sets `juliaC` and instantly shows the corresponding Julia set
- Compact branchless HSV→RGB (3 lines, no conditionals):
  `c.z * mix(K.xxx, clamp(abs(fract(c.xxx+K.xyz)*6.0-K.www)-K.xxx, 0.0, 1.0), c.y)`
- Escape radius 4.0 preferred over 2.0 for smoother smooth-coloring output
- Known off-by-one in exponent loop (`exponent-1` iterations computes z^(exponent+1)): avoid
  this when porting

**shader-fractals** (`opensource/shader-fractals`, Shadertoy-style GLSL):
- 6 tested Julia `c` coordinates: Dendritic (−0.8, 0.156), Spiral (−0.4, 0.6),
  Cauliflower (0.285, 0.01), Flame (−0.70176, −0.3842), Rabbit (−0.835, −0.2321),
  Nautilus (0.45, 0.1428)
- Complete 3D distance estimators ready to adapt: Menger Sponge (cross-fold, 100 steps),
  Sierpinski Tetrahedron (sum-based fold, 150 steps), Mandelbox (2500 steps, desktop only)
- Fast 2D IFS shaders: Sierpinski Triangle (vertex reflection, 8 iterations), Sierpinski
  Carpet (modular grid, 6 iterations), Koch Curve (line reflection) — all mobile-suitable
- Shadertoy → Flutter uniform mapping: `iResolution`→`u_resolution`, `iTime`→`u_time`,
  `iMouse`→`u_mouse`, `mainImage(out,in)`→`void main()` + `fragColor`

**glChAoS.P** (`opensource/glChAoS.P`, C++/OpenGL 4.1):
- 36 strange attractor ODE formulas (Lorenz, Aizawa, Rossler, Halvorsen, Thomas, …) with
  pre-tuned parameters; Euler step `dt = 0.001–0.1` — adaptable to GLSL fragment shaders
- Lorenz: σ=10, ρ=28, β=8/3, initial (1,1,1), dt=0.01
- Velocity-based palette lookup: `t = clamp(length(dvdt(z)) * colorIntensity, 0.0, 1.0)`
- Separable Gaussian blur (2-pass, O(2σ) taps per axis) for glow post-processing
- 30+ 256-entry palette LUTs: Magma, Viridis, Inferno, Plasma (matplotlib-compatible)

**Mandelbulber2** (`opensource/mandelbulber2`, C++/Qt5/OpenCL):
- Three distance estimator (DE) types: analytic logarithmic (power fractals), analytic linear
  (IFS/folding), numerical delta (arbitrary transforms)
- Mandelbox exact parameters: foldLimit=1.0, foldValue=2.0, mR²=0.25, fR²=4.0, scale=2.5–3.0
- Multi-component color model: `colorValue += orbitTrap*w0 + aux_color*w1 + radius*w2 + ...`
- Soft shadows (secondary ray-march toward light) and AO (4-sample along surface normal)
- Numerical gradient normals: 6-tap central differences, `eps = 0.001 * detailSize`
- Phong shading: directional / point (1/r, 1/r², 1/r³ decay) / conical light types

**Psychtoolbox-3** (`opensource/Psychtoolbox-3`, MATLAB/GLSL):
- Full sRGB piecewise gamma correction (IEC 61966-2-1): apply after all color arithmetic
- Pan/zoom uniform pattern (clean reference): `c = center + (fragCoord/resolution - 0.5) / zoom`
- Perlin noise library (`ClassicPerlinNoiseLib.frag.txt`): `fade()` + `taylorInvSqrt()`

### Deliverables Required

Produce a **concrete, file-level implementation plan** structured as follows:

#### 1. Bug Fixes (prerequisite to everything else)

For each of the 3 bugs above:
- Exact file(s) to modify and the nature of the change
- Whether any other files must change as a consequence
- A one-line verification (widget test assertion or dart analyze check) that confirms the fix

#### 2. Shader Enhancement Catalog

A prioritized table of GLSL techniques to add, with columns:

| Technique | Source project | Target shader file(s) | Dart-side change needed | Effort | Priority |
|-----------|--------------|-----------------------|------------------------|--------|----------|

For each High-priority entry also include:
- The exact GLSL snippet to port (quoted from the research above)
- Which existing uniform slots it uses or whether `uniform_schema.dart` needs a new slot
- Whether it requires a new `EscapeTimeConfig` entry, a shared post-processing pass, or a
  modification to the existing module's `setUniforms` function

Prioritise: cosine palette, sRGB gamma, branchless HSV→RGB, double-float coordinate mapping,
orbit trap coloring, separable Gaussian glow, FXAA, smooth iteration (unified formula).

#### 3. New Fractal Modules

List each new `FractalModule` to add, grouped by implementation tier:

**Tier A — One `EscapeTimeConfig` + one `.frag` file** (lowest effort):
- For each: `id`, `shaderAsset` path, formula origin, parameter list (name, range, default)
- Candidates: Sierpinski Carpet, Sierpinski Triangle, Koch Curve, Newton z^4−1, Newton z^5−1,
  Burning Ship Julia, Multibrot Julia

**Tier B — New `buildXxxModule()` function with custom parameters**:
- Mandelbox 3D: parameters foldLimit, foldValue, mR², fR², scale, maxSteps, lightDir, aoSamples
- Strange Attractor (Lorenz): parameters σ, ρ, β, dt, colorVel, paletteOffset
- Dual-mode Mandelbrot/Julia (giulia pattern): single shader, `juliaMode` bool + `juliaC` vec2

**Tier C — New pipeline or precision infrastructure**:
- Double-float Mandelbrot: new precision tier in `deep_zoom_precision_policy.dart`; CPU
  computes reference orbit into `Float32List`, uploads via `ImageShader`, shader uses
  `dblflt` structs for coordinate arithmetic
- Menger Sponge 3D: ray-marcher with cross-fold DE, Phong + AO, camera orbit controls

For each Tier B/C module, specify the `FractalParameter` list with types and ranges.

#### 4. Architecture Changes (Dart/Flutter, not shaders)

Describe changes to non-shader Dart code with enough detail to implement directly:

- **`ProviderNotFoundException` fix**: where to insert the `Provider<FractalController>`
  ancestor, and whether a `MultiProvider` restructure in `main.dart` or a route-level
  wrapper is the right approach
- **`RuntimeModeService` redesign**: proposed enum (`testMode`, `debugMode`, `releaseMode`),
  injection point, and how `FractalRenderer` consumes it instead of the assert trick
- **Palette system upgrade** (if recommending LUT textures over inline GLSL cosine): impact
  on `uniform_schema.dart` slot numbering, `palette_service.dart` texture creation, and
  `fractal_painter.dart` `setImageSampler` call sites
- **Reference orbit pipeline** for perturbation-theory Mandelbrot: data flow from CPU
  `double` arithmetic → `Float32List` packing → Flutter `ui.Image` (1×N RGBA32F texture)
  → `setImageSampler` → shader texture lookup

#### 5. Performance Targets

For each new shader or post-processing pass that may be expensive, provide the table:

| Target device | Max iterations | Max ray steps | AA mode | Expected FPS |
|--------------|---------------|---------------|---------|-------------|
| Mobile mid   | 64  | 32  | none   | 60 |
| Mobile high  | 128 | 64  | FXAA   | 60 |
| Desktop      | 256 | 128 | FXAA   | 60 |
| Desktop HQ   | 512 | 256 | SSAA 4×| 30 |

Also specify: at what zoom level `deep_zoom_precision_policy.dart` should switch from `float`
to `dblflt` (suggest based on FractalShark's precision table: float ~10^7, dblflt ~10^14).

#### 6. Incremental Rollout Phases

A numbered phase list where each phase leaves the app in a working, shippable state:

- What is added or changed
- What existing behaviour may change and how to guard it
- A smoke-test command (`flutter test`, `flutter analyze`, or integration test invocation)

Phases should flow roughly: bug fixes → shader quality (coloring, gamma, glow) → new 2D Tier A
modules → palette system → new 2D Tier B modules → double-float zoom → 3D additions →
perturbation theory.

### Hard Constraints

- State management: `provider` package only — no Riverpod, BLoC, or other libraries
- Shader language: GLSL ES 3.0 (Impeller/OpenGL ES 3.0 compatible; no `fma`, no compute shaders)
- No new `pub.dev` dependencies without explicit justification
- All modules must flow through `ModuleRegistry` — no ad-hoc `FragmentProgram` loading
- The `EscapeTimeConfig` declarative pattern must be preserved and extended, not replaced
- `cpu_fractal_renderer.dart` CPU fallback must remain functional for every new 2D module
- All three platforms must build and pass `flutter analyze`: Linux desktop, Android, iOS

### Reference Material

Full algorithm extractions (exact GLSL snippets, parameter ranges, applicability ratings) are
in `opensource/opensource-tools-fractals.md`. Cloned repos are at `opensource/<name>/`.
Cite source project and file name when referencing specific formulas.
