<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-02-13 | Updated: 2026-02-13 -->

# shaders

## Purpose
220+ GLSL fragment shaders for GPU-accelerated fractal rendering. Each shader implements one fractal type's rendering algorithm. Shaders receive uniforms from Dart (resolution, pan, zoom, iterations, colors, etc.) and output pixel colors. Organized into subdirectories by fractal category.

## Key Files

| File | Description |
|------|-------------|
| `legacy/diagnostics/mandelbrot.frag` | Minimal Mandelbrot-uniform diagnostic shader (legacy) |
| `legacy/escape_time/julia.frag` | Julia set (legacy) |
| `legacy/escape_time/burning_ship.frag` | Burning Ship fractal (legacy) |
| `legacy/escape_time/phoenix.frag` | Phoenix fractal (legacy) |
| `legacy/raymarched_3d/mandelbulb.frag` | 3D Mandelbulb with raymarching |
| `legacy/diagnostics/mandelbrot_simple.frag` | Minimal size-uniform gradient diagnostic shader |
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
| `root_finding/` | Newton, Halley, Householder, Schröder, Steffensen, and related root-finding shader families |
| `kaleidoscopes/` | 15 kaleidoscope and symmetry shaders |
| `diagnostic/` | 8 utility/debug shaders (sampler diagnostics, gradient tests) |
| `legacy/` | 12 legacy compatibility shaders without `_gpu` naming, grouped by responsibility (see `legacy/AGENTS.md`) |
| `runtime/` | 3 runtime/post-processing shaders |

## For AI Agents

### Working In This Directory
- Shaders are GLSL fragment shaders (`.frag` files)
- Every shader must be registered in `pubspec.yaml` under `flutter.shaders`
- Declarative escape-time shaders follow the layout in `lib/core/modules/builders/escape_time_builder.dart`; other shader families use their documented contracts.
- Uniform contracts vary by shader family. Escape-time and ray-marched 3D layouts are defined in `lib/core/modules/builders/uniform_layout.dart` and implemented by their module builders.

### Uniform Layout Convention

Keep the shader declaration order aligned with its Dart uniform setter. The shared contracts live in `lib/core/modules/builders/uniform_layout.dart`:

- Escape-time shaders built with `EscapeTimeConfig` use the slot layout in `EscapeTimeUniformSlots` and `escape_time_builder.dart`.
- Ray-marched 3D shaders use a shared frame/camera prefix in `Raymarched3DUniformSlots` and `setRaymarched3DFrameUniforms()`:

| Slot(s) | GLSL uniform | Meaning |
|---|---|---|
| 0 | `uTime` (`float`) | Animation time |
| 1–2 | `uResolution` (`vec2`) | Canvas size in pixels |
| 3–4 | `uMousePos` (`vec2`) | Shared camera pan target |
| 5 | `uZoom` (`float`) | Camera zoom |
| 6–8 | `uRotation` (`vec3`) | Camera rotation |

Custom shader parameters follow this prefix and keep their module-specific order. Check both the Dart setter and shader declarations when changing a layout. The shared layout test and 3D shader pan-target test cover the current contract; shader compilation checks are separate from hardware-GPU visual verification.

The declarative escape-time slot sequence is:

1. `uResolution` (`vec2`) - canvas pixel size
2. `uCenter` (`vec2`) - complex-plane center
3. `uZoom` (`float`) - zoom level
4. `uIterations` (`float`) - maximum iteration count
5. `uBailout` (`float`) - escape radius
6. `uColorScheme` (`float`) - palette index
7. `uTime` (`float`) - animation time

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
- `lib/core/modules/builders/escape_time_builder.dart` and `lib/core/modules/builders/uniform_layout.dart` - Define the uniform layout contract
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
