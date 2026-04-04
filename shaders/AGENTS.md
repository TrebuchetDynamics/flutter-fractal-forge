<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-02-13 | Updated: 2026-03-21 -->

# shaders

## Purpose
450+ shader assets used for fractal rendering, diagnostics, experiments, and legacy implementations. Production shaders are registered in `pubspec.yaml`; many additional `.frag` files are retained for development, migration, and research.

## Key Files

| File | Description |
|------|-------------|
| `common.vert` | Shared vertex shader used by all fragment shaders |
| `mandelbrot_et.frag` | Escape-time Mandelbrot baseline used in renderer experiments |
| `escape_time_perturb_gpu.frag` | Shared perturbation-oriented shader path for supported escape-time formulas |
| `mandelbulb.frag` | 3D Mandelbulb raymarching shader |
| `mandel_julia_dual_gpu.frag` | Dual-view shader for Mandelbrot/Julia exploration |
| `ink_sparkle.frag` | Material Design ink sparkle effect |

## Subdirectories

| Directory | Purpose |
|-----------|---------|
| `escape_time_family/` | 25+ escape-time fractals (Mandelbrot variants, Julia, Celtic, etc.) |
| `trigonometric_and_transcendental/` | 15+ trig-based fractals (sine, cosine, exponential, zeta) |
| `strange_attractors/` | 20+ strange attractor visualizations (Lorenz, Rossler, Ikeda) |
| `ifs_and_geometric/` | 20+ IFS and geometric fractals (Sierpinski, Koch, Dragon) |
| `3d_and_hypercomplex/` | 10+ 3D/hypercomplex fractals (Mandelbulb, Quaternion) |
| `cellular_and_stochastic/` | 15+ cellular automata and stochastic fractals |
| `lyapunov_and_stability/` | 10+ Lyapunov exponent and stability map shaders |
| `diagnostic/` | Utility/debug shaders (sampler diagnostics, gradient tests) |

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
- Most production shader assets currently live at the root of `shaders/`
- `pubspec.yaml` is the source of truth for which shaders ship in the app bundle
- Naming convention is usually `{fractal_name}_gpu.frag` for production shaders
- Legacy or diagnostic shaders are retained for debugging and migration work; do not assume every `.frag` is user-facing

## Dependencies

### Internal
- `lib/core/modules/builders/escape_time_builder.dart` - Defines the uniform layout contract
- `lib/core/shaders/uniform_schema.dart` - Uniform schema definitions
- `pubspec.yaml` - Shader asset registration

<!-- MANUAL: -->
