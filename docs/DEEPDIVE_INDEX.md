# Open-Source Fractal Projects: Deep-Dive Index

**Primary Document:** `/home/xel/git/flutter-fractal-forge/OPENSOURCE_DEEPDIVE.md` (1,480 lines)

## Quick Reference by Project

### 1. DeepDrill (C++/SFML) — Perturbation Theory + Series Approximation
- **Root:** `/home/xel/git/flutter-fractal-forge/opensource/repos/renderers/DeepDrill/`
- **Key Files:**
  - Config & Version: `src/config.h` (MAP_FORMAT=320, v3.2.0)
  - Location Format: `src/shared/Options.h` (GMP arbitrary precision)
  - Data Structure: `src/shared/DrillMap.h` (7-channel result storage)
  - Precision Tiers:
    - f64: `src/math/StandardComplex.h`
    - Double-double: `src/math/ExtendedDouble.h` (mantissa+exponent)
    - 106-bit: `src/math/ExtendedComplex.h` (hi/lo pairs)
    - Arbitrary: `src/math/PrecisionComplex.h` (GMP)
  - Drilling Engine: `src/ddrill/Driller.h` (reference orbit + probe picking)
  - GPU Colorization: `shaders/colorizers/gradient.glsl` (multi-channel decode)
  - Video Pipeline: `src/dmake/DeepMake.h` + `src/dzoom/FFmpeg.h` (INI→frames→video)

- **Critical Data Structures:**
  - `DrillResult` enum: 8 outcomes (ESCAPED, PERIODIC, GLITCH, etc.)
  - `ChannelID` enum: 7 channels (RESULT, FIRST, LAST, NITCNT, DERIVATIVE, NORMAL, DIST)
  - `LocationOptions`: GMP-based (real, imag, zoom, depth, escape)
  - `PerturbationOptions`: tolerance, badpixels, rounds, debug_color
  - `ApproximationOptions`: coefficients, tolerance

- **Key Algorithm:** Perturbation + series approximation for deep zooms
  - Compute reference point at high precision
  - Per-pixel delta (low precision)
  - Glitch detection & refinement rounds
  - 7 independent output channels for post-processing

- **Export Pipeline:** DeepMake (INI config) → drill map → frames → FFmpeg video

---

### 2. FractaVista (C++/OpenGL) — Compute Shader Architecture
- **Root:** `/home/xel/git/flutter-fractal-forge/opensource/repos/renderers/FractaVista/`
- **Key Files:**
  - Type System: `src/fractal/FractalTypes.hpp` (6 fractal types)
  - Shader Registry: `src/fractal/FractalDefinition.hpp` (shader #define mapping)
  - GPU Dispatch: `src/fractal/FractalComputer.cpp` (compute shader + 8× SSAA export)
  - Shader Compilation: `src/gfx/Shader.cpp` (GL_COMPUTE_SHADER with injected defines)
  - Preset I/O: `src/app/Application.cpp` (JSON via nlohmann/json)

- **Supported Fractals:** Mandelbrot, Julia, BurningShip, CubicMandelbrot, Tricorn, Newton

- **GPU Architecture:**
  - Dispatch: 16×16 workgroups
  - UBO: std140 palette data (ColorStop array)
  - Output: RGBA8888 image binding
  - Supersampling: 2×, 4×, 8× at compute time
  - Read-back: `glGetTexImage()` + y-flip + SDL_image export

- **Shader Compilation:**
  - Load MainShader.glsl from assets
  - Inject #define FRACTAL_<TYPE> after #version
  - Compile GL_COMPUTE_SHADER, link program
  - Bind UBO to binding point 0

- **Preset Format:** JSON (.fracta extension)
  - Fields: type, renderWidth, renderHeight, offset, zoom, maxIterations
  - Coloring: useSmoothing, paletteFrequency, palette (ColorStop[])
  - Parameters: fractal-specific (e.g., juliaConstant for Julia)

- **Export:** PNG/JPG via SDL_image; 8× SSAA at compute dispatch time

---

### 3. Fractl (Rust) — GPU/CPU with WASM
- **Root:** `/home/xel/git/flutter-fractal-forge/opensource/repos/renderers/Fractl/`
- **Key Files:**
  - Workspace: `Cargo.toml` (members: fractl_lib, fractl_gui)
  - Feature System: `fractl_lib/src/lib.rs` (f32/f64 + CPU/GPU selection)
  - Math: `fractl_lib/src/math.rs` (Mandelbrot + Multibrot(exponent))
  - GPU Backend: `fractl_lib/src/gpu.rs` (wgpu compute)
  - Shader: `fractl_lib/src/shader.wgsl` (WGSL compute)

- **Feature Flag Matrix:**
  ```
  Mutually Exclusive: (f32|f64), (multithread|gpu), NOT(f64+gpu)
  Valid Combinations:
    - f32 + multithread (CPU f32)
    - f64 + multithread (CPU f64)
    - f32 + gpu (GPU f32 via wgpu)
    - f32 (default, CPU single-threaded)
    - f64 (default, CPU single-threaded)
  ```

- **Fractal Types:**
  - `Mandelbrot` (id=0)
  - `Multibrot(Float)` (id=1, parameterized exponent)

- **GPU Compute (wgpu):**
  - Adapter: HighPerformance power preference
  - Limits: downlevel_defaults() for broad compatibility
  - Buffers:
    - args_buffer: UniformBuffer (ArgsUniform struct)
    - storage_buffer: StorageBuffer (read_write, output results)
    - output_staging_buffer: Staging (map read)
  - Shader: Embedded WGSL (shader.wgsl)
  - Dispatch: 1D workgroups (one per element)
  - Read-back: Asynchronous map_async + poll

- **CPU Escape Time (both f32 and f64):**
  - Main bulb optimization (q * (q + (x - 0.25)) <= 0.25 * y²)
  - Standard Mandelbrot iteration (x_{n+1} = x_n² - y_n² + x₀, etc.)
  - Multibrot: z_{n+1} = z_n^e + z₀ (e parameterized)

- **Platforms:** Native (Windows/Linux/macOS) + WASM (browser via wasm-pack)

---

### 4. fractals-generator (C++) — Multi-Precision Rendering
- **Root:** `/home/xel/git/flutter-fractal-forge/opensource/repos/renderers/fractals-generator/`
- **Key Files:**
  - Main: `src/main.cpp` (precision selection + shader switching)
  - Examples: `examples/arbitrary-fixed-glsl/` (arbitrary-precision GLSL)

- **Precision Tiers:**
  ```
  FLOAT:           Single f32 (emulated as f64-em)
  DOUBLE:          Native f64
  EMULATED_DOUBLE: Emulated f64 in f32
  EMULATED_QUAD:   Emulated f128 (quad-single)
  FP128:           Fixed-point 128-bit
  DUAL:            f32 vs f64 comparison
  DUAL_F128:       f64 vs f128 comparison
  ```

- **Precision Expansion:**
  ```cpp
  #ifdef __GNUC__
  typedef __float128 LongReal;
  #else
  typedef long double LongReal;
  #endif
  ```

- **Global State:**
  - `d_zoom`: LongReal (zoom level)
  - `cx`, `cy`: LongReal (center position)
  - `c`: float[2] (Julia constant)
  - `w`, `h`: double (window dimensions)
  - `render_mode`: RENDER_MODES enum
  - `iterations`: int
  - `smooth`: bool (smooth vs classic coloring)

- **Shader Selection by Precision:**
  - FLOAT → fractal_f64_em.frag
  - DOUBLE → fractal_f64.frag
  - EMULATED_DOUBLE → fractal_f64_em.frag
  - EMULATED_QUAD → fractal_f128.frag
  - FP128 → fractal_fp128.frag

- **Export:**
  - `glReadPixels()` (GL_RGB)
  - Vertical flip for SFML
  - SFML Image::saveToFile() to PNG

---

## Cross-Project Patterns

### Precision Strategy (All Projects)
| Tier | DeepDrill | FractaVista | Fractl | fractals-gen |
|------|-----------|-------------|--------|--------------|
| Fast | StandardComplex (f64) | Compute f64 | f32 CPU | f32 (FLOAT) |
| Standard | ExtendedDouble (106-bit) | - | f64 CPU | f64 (DOUBLE) |
| Deep | PrecisionComplex (GMP) | - | - | f128 (QUAD/FP128) |

### Fractal Types (All Projects)
| Type | DeepDrill | FractaVista | Fractl | fractals-gen |
|------|-----------|-------------|--------|--------------|
| Mandelbrot | ✓ (primary) | ✓ | ✓ (default) | ✓ |
| Julia | - | ✓ | - | ✓ |
| BurningShip | - | ✓ | - | ✓ |
| Tricorn | - | ✓ | - | ✓ |
| Newton | - | ✓ | - | ✓ |
| Multibrot | - | - | ✓ | - |
| Cubic | - | ✓ | - | ✓ |

### Coloring Methods
| Method | DeepDrill | FractaVista | Fractl | fractals-gen |
|--------|-----------|-------------|--------|--------------|
| Palette Gradient | ✓ | ✓ | - | ✓ |
| Smooth (NIC) | ✓ (NITCNT channel) | ✓ | - | ✓ |
| Distance Estimation | ✓ (DIST channel) | - | - | ✓ |
| Histogram | - | - | ✓ (CPU) | ✓ |
| Normal Mapping | ✓ (NORMAL channel) | - | - | - |

---

## Key Algorithms & Optimizations

### Main Bulb Detection (All Projects Using Mandelbrot)
```glsl
float q = (x - 0.25)² + y²
if (q * (q + (x - 0.25)) ≤ 0.25 * y²)
    return maxIterations  // In main bulb: guaranteed in set
```

### Smooth Coloring (Normalized Iteration Count)
```glsl
float nic = iterations + 1.0 - log(log(|z|)) / log(2.0)
// Fractional part smooths color transitions
```

### Double-Double Arithmetic (DeepDrill)
```cpp
struct ExtendedComplex {
    StandardComplex high;  // High-order bits
    StandardComplex low;   // Low-order bits
    // ~106 bits precision (double-double)
};
```

### Series Approximation (DeepDrill)
- Pre-compute Taylor coefficients from reference point
- Skip early iterations for nearby pixels
- Detect glitches (reference divergence)
- Refine with new reference point

### Perturbation Theory (DeepDrill)
- Compute reference orbit at high precision (GMP)
- For each pixel: z = ref + δ (δ at low precision)
- Early bailout if δ exceeds tolerance
- Efficient for deep zooms (one high-precision orbit per region)

---

## Implementable Patterns for Flutter/GLSL ES 3.0

### 1. Multi-Stop Palette Interpolation
```dart
class ColorStop {
  final Color color;
  final double position;  // [0, 1]
}

Color interpolatePalette(double t, List<ColorStop> stops) {
  // Binary search + linear interpolation between stops
  final i = stops.indexWhere((s) => s.position >= t);
  if (i == 0) return stops[0].color;
  if (i == stops.length) return stops.last.color;
  // Interpolate between stops[i-1] and stops[i]
}
```

### 2. Compute Shader Dispatch (16×16 Workgroups)
```glsl
#version 310 es
precision highp float;

layout(local_size_x = 16, local_size_y = 16) in;
layout(rgba8, binding = 0) uniform image2D resultImage;

uniform vec2 fullResolution;
uniform vec2 offset;
uniform float zoom;
uniform int maxIterations;

void main() {
    ivec2 pixelCoords = ivec2(gl_GlobalInvocationID.xy);
    if (pixelCoords.x >= int(fullResolution.x) ||
        pixelCoords.y >= int(fullResolution.y)) return;

    vec4 result = computeFractal(pixelCoords, fullResolution, offset, zoom, maxIterations);
    imageStore(resultImage, pixelCoords, result);
}
```

### 3. Preset JSON Format
```json
{
  "location": {
    "centerX": -0.5,
    "centerY": 0.0,
    "zoom": 1.0,
    "maxIterations": 256,
    "escapeRadius": 2.0
  },
  "coloring": {
    "useSmoothing": true,
    "paletteFrequency": 0.01,
    "palette": [
      { "color": [0.55, 0.75, 0.95], "position": 0.0 },
      { "color": [1.0, 1.0, 1.0], "position": 1.0 }
    ]
  },
  "parameters": {
    "fractalType": "Mandelbrot"
  }
}
```

### 4. SSAA Screenshot (8× Supersampling)
```dart
Future<Uint8List> takeScreenshot({
  required int supersample,  // 2, 4, or 8
  required int width,
  required int height,
}) async {
  final ssWidth = width * supersample;
  final ssHeight = height * supersample;

  // Dispatch compute shader at supersampled resolution
  // Read pixels via glReadPixels
  // Downsample: average 2×2 or 4×4 blocks

  return downsampled;
}
```

### 5. Feature Selection (Cargo-style)
```rust
// Dart equivalent: compile-time constants
const bool USE_F32 = bool.fromEnvironment('PRECISION_F32', defaultValue: true);
const bool USE_GPU = bool.fromEnvironment('USE_GPU', defaultValue: false);

// Runtime selection
if (USE_GPU) {
  // wgpu compute path
} else {
  // CPU path (f32 or f64)
}
```

---

## File Inventory (All Locations)

### DeepDrill
- **Config:** `src/config.h` (version, constants)
- **Options:** `src/shared/Options.h` (full configuration struct)
- **Data:** `src/shared/DrillMap.h` (7-channel results)
- **Coords:** `src/shared/Coord.h` (i16 pixel coords)
- **Precision:** `src/math/{StandardComplex,ExtendedDouble,ExtendedComplex,PrecisionComplex}.h`
- **Engine:** `src/ddrill/{Driller,ReferencePoint,Approximator,MapAnalyzer,SlowDriller}.h`
- **Video:** `src/dmake/DeepMake.h`, `src/dzoom/{FFmpeg,Recorder,Zoomer,NamedPipe}.h`
- **Shaders:** `shaders/colorizers/gradient.glsl`, `shaders/scalers/{bicubic,trilinear,tricubic,nearest}.glsl`

### FractaVista
- **Types:** `src/fractal/{FractalTypes,FractalDefinition,FractalComputer}.hpp`
- **GPU:** `src/gfx/{Shader,Texture}.cpp`
- **UI:** `src/ui/{CameraController,UIManager,Theme}.cpp`
- **App:** `src/app/Application.cpp` (preset I/O)
- **Util:** `src/util/{FileUtils,JsonUtils,Logger,PlatformUtils}.hpp`

### Fractl
- **Workspace:** `Cargo.toml`
- **Library:** `fractl_lib/`
  - `src/lib.rs` (feature system)
  - `src/gpu.rs` (wgpu compute)
  - `src/math.rs` (fractal types + escape time)
  - `src/shader.wgsl` (WGSL compute kernel)
- **GUI:** `fractl_gui/`

### fractals-generator
- **Main:** `src/main.cpp` (precision selection + rendering)
- **Examples:** `examples/arbitrary-fixed-glsl/` (arbitrary-precision GLSL)

---

## Next Steps for Flutter Implementation

1. **Adopt FractaVista's compute shader pattern** (16×16 workgroups, UBO palette)
2. **Extend with DeepDrill's perturbation** (reference orbit caching for deep zooms)
3. **Use Fractl's feature flags** (compile-time precision selection)
4. **Implement FractaVista's preset JSON** format
5. **Support 8× SSAA export** via compute dispatch + read-back
6. **Add FFmpeg integration** for video export (DeepMake pattern)
7. **Multi-stop palette interpolation** with smoothing frequency
8. **Channel-based architecture** for extensibility (normal mapping, distance, etc.)

---

**Document Version:** 1.0 (February 2026)
**Source Projects:** All open-source, properly attributed
**Analysis Depth:** Complete architecture review with code snippets
**Ready for Implementation:** Yes
