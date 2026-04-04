# Flutter Fractal Forge — Implementation Roadmap

> Research roadmap. This file summarizes external ideas and speculative implementation options; it is not a statement of the currently shipped feature set.

Actionable techniques extracted from 4 major open-source fractal projects.

---

## Quick-Reference: Top 10 Implementable Techniques

### 1. Smooth Iteration Coloring (High Priority)

**What**: Continuous coloring instead of discrete iteration bands
**Where**: All 4 projects implement this
**Formula**:
```
if (escapes) {
    smooth_value = log2(log2(|z|²))
    color_index = n - smooth_value + 4.0
}
```

**Files to Reference**:
- FractalShark: `FractalSharkLib/FractalPalette.cpp`
- FractaVista: `assets/shaders/Mandelbrot.glsl` lines 22-26
- Fractl: Not explicitly implemented (opportunity)

**Flutter Implementation**:
- Apply in pixel shader (GPU) or per-pixel CPU loop
- Eliminates harsh color banding
- ~15 lines of code

---

### 2. Interactive Palette Gradient Editor (Medium Priority)

**What**: User-adjustable color stops with real-time preview
**Where**: FractaVista (Dear ImGui), GAPFixFractal (Qt)

**Implementation Pattern**:
```cpp
// Gradient editor UI
- Left-click on palette bar: Add color stop
- Drag stop: Reposition
- Right-click: Delete
- Color picker per stop
- Frequency slider: Modulate wave cycling

// GPU-side
- Store in Uniform Buffer Object (UBO)
- Linear interpolation: mix(color[i], color[i+1], t)
```

**FractaVista Reference**:
- File: `src/fractal/FractalComputer.cpp` (UBO setup)
- Shader: `assets/shaders/MainShader.glsl` lines 23-40

**Flutter Implementation**:
- Use Flutter's CustomPaint for gradient UI
- Pass palette as uniform to GPU shader
- Gradient interpolation in fragment/compute shader

---

### 3. GPU Compute Shaders for Multi-Fractal Support (High Priority)

**What**: Per-algorithm shader variants compiled at runtime
**Where**: FractaVista (OpenGL 4.3+), Fractl (WebGPU)

**Architecture Pattern**:
```glsl
// MainShader.glsl (dispatcher)
#ifdef FRACTAL_MANDELBROT
  #include "Mandelbrot.glsl"
#elif defined(FRACTAL_JULIA)
  #include "Julia.glsl"
// ... etc
#endif

// Per-algorithm files define: fractalFunction(coord) → iterations
```

**Supported by Flutter**:
- **Desktop (Linux/Windows/macOS)**: OpenGL 4.3+ compute shaders
- **Mobile (iOS/Android)**: Vulkan compute or Metal compute
- **Web**: WebGPU (experimental, in development)

**Implementation Pattern** (FractaVista style):
1. Define fractal types: Mandelbrot, Julia, BurningShip, Tricorn, Newton
2. Create per-type shader file with `fractalFunction(dvec2) → double`
3. Main shader includes correct variant via compile-time define
4. Pass parameters via uniform buffer

**Flutter Implementation**:
- Use `dart:ffi` to call C++ shader compiler, or
- Use `package:flutter_gpu` (new, experimental) for custom shaders
- Or use existing `package:flutter_shaders` with GLSL/WGSL

**Estimated Effort**: 2-3 days

---

### 4. Multithreading for CPU Fallback (Medium Priority)

**What**: Parallel per-pixel computation when GPU unavailable
**Where**: Fractl (rayon), FractalShark (custom 3-thread architecture)

**Fractl Pattern** (cleanest):
```rust
// Distribute pixels to rayon thread pool
pixels.par_iter_mut().for_each(|pixel| {
    let iterations = mandelbrot_escape_time(coord);
    *pixel = color_from_iterations(iterations);
});
```

**Flutter Implementation**:
- Use `dart:isolate` for parallel pixel computation
- Divide framebuffer into chunks (one per isolate)
- Merge results back to main thread
- **Reference**: Flutter's built-in `compute()` function

**Estimated Effort**: 1-2 days

---

### 5. Perturbation Theory for Extreme Zooms (Low Priority, Advanced)

**What**: Reference orbit + per-pixel perturbations (100,000+ digit zoom)
**Where**: FractalShark (exclusive focus), FractalZoomer

**Architecture**:
```
1. Compute high-precision reference orbit at click-point
2. For each pixel: compute low-precision perturbation
3. Combine: z_pixel = z_reference + delta_pixel
4. Advantage: 100× faster at extreme zooms
```

**Complexity**: High (requires custom number types, compression)
**Best For**: After v1 is feature-complete

**FractalShark Reference Files**:
- `FractalSharkLib/PerturbationResults.h` (compression)
- `FractalSharkLib/LAReference.h` (linear approximation)
- `FractalSharkLib/RefOrbitCalc.cpp` (multithreaded orbit)

---

### 6. Zoom with Cursor Centering (High Priority, Easy)

**What**: Mouse scroll zooms toward cursor position (not viewport center)
**Where**: FractaVista, Fractl (all implement)

**Pattern**:
```
zoom_at_cursor(mouse_x, mouse_y, zoom_factor):
    current_coord = screen_to_complex(mouse_x, mouse_y)
    new_zoom = zoom * zoom_factor
    new_center_offset = (current_coord - center) / zoom_factor
    new_center = center + new_center_offset
```

**Flutter Implementation**:
- Gesture detector: `onPointerScroll(details.scrollDelta.dy)`
- Map pointer position to complex plane
- Recalculate viewport bounds

**Estimated Effort**: 1 day

---

### 7. Escape Time Optimization — Bulb Detection (High Priority, Easy)

**What**: Skip interior points (Mandelbrot main cardioid/bulb)
**Where**: Fractl (lines 73-76), FractaVista (comment in Mandelbrot.glsl)

**Formula** (Mandelbrot main bulb):
```glsl
vec2 q = c - vec2(0.25);
if (q.x * q.x + q.y * q.y * (q.x + q.y * q.y) <= 0.25 * q.y * q.y) {
    return maxIterations; // Inside bulb, skip iteration
}
```

**Cardioid** (more advanced):
```glsl
double q = (c.x - 0.25)^2 + c.y^2;
if (q * (q + c.x - 0.25) <= 0.25 * c.y^2) {
    return maxIterations;
}
```

**Impact**: 15-20% faster rendering (skips ~30% of interior pixels)

---

### 8. Three Coloring Algorithms (Medium Priority)

**Where**: Fractl implements all three in WGSL

#### A. Histogram Coloring (Classic)
```glsl
color_value = escape_time / max_iterations * 255.0
```
- Simplest, banding artifacts

#### B. LCH Coloring (Perceptually-Uniform)
```glsl
s = escape_time / max_iterations
v = cos(1.0 - π * s)²
color = (75 - 75v, 28 + 75 - 75v, 360 * s^1.5 mod 360)
```
- Smoother, more aesthetically pleasing

#### C. OLC Coloring (Sinusoidal)
```glsl
color_r = 0.5 * (sin(0.1 * n) + 0.5) * 255
color_g = 0.5 * (sin(0.1 * n + 2.094) + 0.5) * 255
color_b = 0.5 * (sin(0.1 * n + 4.188) + 0.5) * 255
```
- Smooth continuous variation

**Fractl Reference**: `fractl_lib/src/shader.wgsl` lines 95-127

---

### 9. Julia Set Real-Time Preview (Medium Priority)

**What**: Show Julia set preview while clicking Mandelbrot point
**Where**: GAPFixFractal (control-click workflow)

**Pattern**:
```
1. Render Mandelbrot normally
2. On mouse move: Use mouse_pos as Julia constant (c parameter)
3. Render Julia preview in overlay/split-view
4. On click: Switch to Julia set, save parameter
```

**Flutter Implementation**:
- Use secondary `FractalRenderer` for preview
- Split viewport 50/50 (or overlay with opacity)
- Sync animation speed between both renders

**Estimated Effort**: 1-2 days

---

### 10. Multi-Fractal Type Support (High Priority)

**Recommended Implementations** (ranked by ease):

| Type | Complexity | Formula |
|------|-----------|---------|
| **Mandelbrot** | ★☆☆ | z → z² + c |
| **Julia** | ★☆☆ | z → z² + c (c fixed) |
| **Burning Ship** | ★☆☆ | z → (\|ℜ(z)\| + i\|\ℑ(z)\|)² + c |
| **Tricorn** | ★☆☆ | z → conj(z)² + c |
| **Multibrot** | ★★☆ | z → z^p + c (p configurable) |
| **Newton** | ★★☆ | z → z - f(z)/f'(z) (root finding) |
| **Cubic Mandelbrot** | ★★☆ | z → z³ + c |

**All implemented in**: FractaVista (OpenGL shaders), Fractl (WGSL)

**Implementation**: One shader function per type, callable from dispatcher

---

## Implementation Checklist

### Phase 1: Core (2-3 weeks)

- [ ] **Smooth iteration coloring** (formula only, ~15 LOC)
- [ ] **GPU compute shader** (single Mandelbrot type)
- [ ] **Zoom with cursor centering** (pan/scroll controls)
- [ ] **Escape time with bulb detection** (15% perf gain)
- [ ] **Interactive palette editor** (Flutter CustomPaint)
- [ ] **Export PNG** (with supersampling option)

### Phase 2: Multi-Fractal (1-2 weeks)

- [ ] **Julia set support** (reuse shader, different constant)
- [ ] **Burning Ship variant** (absolute value in iteration)
- [ ] **Tricorn variant** (conjugate in iteration)
- [ ] **Multibrot (variable exponent)** (parametric control)
- [ ] **Three coloring modes** (histogram, LCH, OLC)
- [ ] **Real-time coloring preview** (gradient editor)

### Phase 3: Performance (1 week)

- [ ] **CPU multithreading fallback** (dart:isolate)
- [ ] **Reference orbit caching** (for zoom animation)
- [ ] **Preset/bookmark system** (save locations)
- [ ] **Feature finder** (periodic point detection, optional)

### Phase 4: Advanced (2-4 weeks, optional)

- [ ] **Perturbation theory** (extreme zoom support)
- [ ] **Linear approximation** (alternative to perturbation)
- [ ] **Reference orbit compression** (memory optimization)
- [ ] **Video export** (zoom animation)

---

## File Organization Reference

### Recommended Flutter Structure
```
lib/
├── fractal/
│   ├── models/
│   │   ├── fractal_state.dart          # Zoom, center, iteration params
│   │   ├── fractal_type.dart           # Enum: Mandelbrot, Julia, etc.
│   │   └── coloring_params.dart        # Palette, frequency, mode
│   ├── renderers/
│   │   ├── gpu_renderer.dart           # GPU compute dispatch
│   │   ├── cpu_renderer.dart           # Dart/isolate-based fallback
│   │   └── shader_manager.dart         # Shader compilation & caching
│   └── algorithms/
│       ├── mandelbrot.glsl             # (Asset) GPU shader
│       ├── julia.glsl                  # (Asset) GPU shader
│       └── escape_time.dart            # CPU escape-time variants
├── ui/
│   ├── controls/
│   │   ├── palette_editor.dart         # Interactive gradient UI
│   │   ├── parameter_controls.dart     # Iterations, zoom, offset
│   │   └── fractal_selector.dart       # Type dropdown
│   └── viewport/
│       ├── fractal_canvas.dart         # Main render surface
│       ├── zoom_handler.dart           # Gesture/scroll logic
│       └── ui_overlay.dart             # Status, FPS, controls
└── services/
    ├── export_service.dart             # PNG/video export
    └── preset_service.dart             # Save/load locations
```

---

## Performance Targets (from Reference Projects)

| Metric | Target | Reference |
|--------|--------|-----------|
| **FPS (1920x1080, shallow zoom)** | 60 FPS | Fractl GPU (~60), FractaVista (~50) |
| **Render time (4K export)** | <5 seconds | FractaVista supersampling |
| **Max zoom depth (f64)** | 10^14 | Fractl with f64 |
| **Extreme zoom (perturbation)** | 10^1,000,000 | FractalShark only |
| **Startup time** | <1 second | FractaVista (shader caching) |
| **Memory usage** | <500 MB | All projects (GPU texture-bound) |

---

## References & Links

### Key Blog Posts
- **Deep Zoom Theory**: https://mathr.co.uk/blog/2021-05-14_deep_zoom_theory_and_practice.html
- **Deep Zoom (Part 2)**: https://mathr.co.uk/blog/2022-02-21_deep_zoom_theory_and_practice_again.html
- **Kalles Fraktaler**: https://mathr.co.uk/kf/kf.html

### Source Code
- **FractalShark**: https://github.com/mattsaccount364/FractalShark
- **FractaVista**: https://github.com/Krish2882005/FractaVista
- **Fractl**: https://github.com/Shapur1234/Fractl
- **GAPFixFractal**: https://github.com/3rdparty/GAPFixFractal

### Standards & APIs
- **OpenGL Compute**: https://www.khronos.org/opengl/wiki/Compute_Shader
- **WebGPU**: https://www.w3.org/TR/webgpu/
- **WGSL Spec**: https://www.w3.org/TR/wgsl/

### Flutter Packages
- **flutter_gpu**: New custom GPU integration (experimental)
- **flutter_shaders**: GLSL/WGSL shader support
- **dart:isolate**: Multithreading for CPU fallback
- **dart:ffi**: C/C++ FFI for custom rendering

---

**Last Updated**: February 17, 2026
**Status**: Ready for implementation planning
