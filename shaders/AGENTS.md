<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-02-13 | Updated: 2026-02-13 -->

# shaders

## Purpose
220+ GLSL fragment shaders for GPU-accelerated fractal rendering. Each shader implements one fractal type's rendering algorithm. Shaders receive uniforms from Dart (resolution, pan, zoom, iterations, colors, etc.) and output pixel colors. Organized into subdirectories by fractal category.

## Key Files

| File | Description |
|------|-------------|
| `legacy/mandelbrot.frag` | Classic Mandelbrot set (legacy) |
| `legacy/julia.frag` | Julia set (legacy) |
| `legacy/burning_ship.frag` | Burning Ship fractal (legacy) |
| `legacy/phoenix.frag` | Phoenix fractal (legacy) |
| `legacy/mandelbulb.frag` | 3D Mandelbulb with raymarching |
| `legacy/mandelbrot_simple.frag` | Mandelbrot via escape-time builder |
| `runtime/ink_sparkle.frag` | Material Design ink sparkle effect |
| `runtime/post_glow_h.frag` / `runtime/post_glow_v.frag` | Post-processing glow passes |

## Subdirectories

| Directory | Purpose |
|-----------|---------|
| `escape_time_family/` | 199 escape-time fractals (Mandelbrot variants, Julia, Celtic, etc.) |
| `trigonometric_and_transcendental/` | 35 trig-based fractals (sine, cosine, exponential, zeta) |
| `strange_attractors/` | 69 strange attractor visualizations (Lorenz, Rossler, Ikeda) |
| `ifs_and_geometric/` | 59 IFS and geometric fractals (Sierpinski, Koch, Dragon) |
| `3d_and_hypercomplex/` | 12 3D/hypercomplex fractals (Mandelbulb, Quaternion) |
| `cellular_and_stochastic/` | 15 cellular automata and stochastic fractals |
| `lyapunov_and_stability/` | 7 Lyapunov exponent and stability map shaders |
| `root_finding/` | 34 Newton, Halley, Householder, and related root-finding shaders |
| `kaleidoscopes/` | 15 kaleidoscope and symmetry shaders |
| `diagnostic/` | 8 utility/debug shaders (sampler diagnostics, gradient tests) |
| `legacy/` | 12 legacy compatibility shaders without `_gpu` naming |
| `runtime/` | 3 runtime/post-processing shaders |

## For AI Agents

### Working In This Directory
- Shaders are GLSL fragment shaders (`.frag` files)
- Every shader must be registered in `pubspec.yaml` under `flutter.shaders`
- Shaders follow a standard uniform layout for escape-time fractals (see `lib/core/modules/builders/escape_time_builder.dart`)
- Standard uniforms: resolution (vec2), center (vec2), zoom (float), iterations (float), bailout (float), colorScheme (float), time (float)

### Uniform Layout Convention
```glsl
// Standard escape-time uniform layout:
uniform vec2 uResolution;  // Canvas size in pixels
uniform vec2 uCenter;      // Pan offset (complex plane center)
uniform float uZoom;       // Zoom level
uniform float uIterations; // Max iteration count
uniform float uBailout;    // Escape radius
uniform float uColorScheme;// Palette index (0-7)
uniform float uTime;       // Animation time
```

### Testing Requirements
- Visual verification via catalog thumbnails (see `integration_test/generate_gpu_thumbnails_test.dart`)
- Shader benchmark tests in `test/shader_benchmark_test.dart`
- Diagnostic shaders (`diag_*.frag`) used for GPU capability testing

### Common Patterns
- Root-level `.frag` files have been moved into responsibility subdirectories
- Shader assets are directly referenced from `pubspec.yaml` by subdirectory path
- Naming convention: `{fractal_name}_gpu.frag` for escape-time catalog shaders
- Legacy shaders (without `_gpu` suffix) are older implementations

## Dependencies

### Internal
- `lib/core/modules/builders/escape_time_builder.dart` - Defines the uniform layout contract
- `lib/core/shaders/uniform_schema.dart` - Uniform schema definitions
- `pubspec.yaml` - Shader asset registration

<!-- MANUAL: -->

<!-- karpathy-guidelines:start -->
## Karpathy-Inspired Agent Guardrails

Source: https://github.com/forrestchang/andrej-karpathy-skills at commit `2c60614`.

These guardrails supplement the local instructions above. Local project, safety, and user-specific rules win on conflict.

Tradeoff: they bias toward caution over speed for non-trivial work; use judgment for obvious one-line fixes.

### Think Before Coding

- State assumptions before implementing; ask when uncertainty would change the solution.
- Surface multiple interpretations and tradeoffs instead of silently picking one.
- Push back when a simpler approach meets the goal.

### Simplicity First

- Build the minimum code that solves the requested problem.
- Avoid speculative features, single-use abstractions, and unnecessary configurability.
- If the solution is growing large, stop and simplify before continuing.

### Surgical Changes

- Touch only files and lines required by the request.
- Preserve existing style, comments, and nearby code unless the task requires changing them.
- Clean up only dead code introduced by your own change; mention unrelated dead code instead of deleting it.

### Goal-Driven Execution

- Convert the request into verifiable success criteria before editing.
- For multi-step work, state a short plan with a verification check for each step.
- Loop until the relevant tests, builds, or manual checks prove the goal is met.
<!-- karpathy-guidelines:end -->

<!-- karpathy-project-adjustment:start -->
## Project-Specific Karpathy Adjustment

This section localizes the Karpathy guardrails for `workspace-sidon/trebuchet-dynamics/flutter-fractal-forge/shaders`. Source inspiration: https://github.com/forrestchang/andrej-karpathy-skills at commit `2c60614`.

- Project family: Sidon fractal/rendering and visual-app workspace.
- Local focus: GPU/fractal rendering, Flutter/Electron apps, shaders, accessibility, and measurable visual behavior.
- Stack cues: Flutter/Dart.
- Evidence to prefer: test output, analyzer/linter output, screenshot/pixel checks when relevant, shader compile logs, frame/performance metrics, and exact UI state text.
- Surgical boundary: do not rely on visual vibes; validate rendering numerically and describe results in screen-reader-friendly text.
- Stop and ask when: a visual requirement lacks measurable acceptance criteria or accessibility impact is uncertain.
<!-- karpathy-project-adjustment:end -->
