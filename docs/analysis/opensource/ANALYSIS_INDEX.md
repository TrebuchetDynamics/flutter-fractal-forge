# Fractal Projects Analysis — Complete Index

**Analysis Date**: February 17, 2026
**Status**: Complete and ready for implementation planning
**Scope**: 4 major open-source fractal projects, 100+ source files analyzed

---

## Documents Generated

This analysis consists of two complementary documents:

### 1. [TECHNICAL_ANALYSIS.md](./TECHNICAL_ANALYSIS.md)
**773 lines | 29 KB | Deep Technical Reference**

Comprehensive breakdown of all four projects with emphasis on algorithms, architectures, and specific file locations.

**Contents**:
- **Section 1**: FractalShark (C++/CUDA, GPU reference orbit acceleration)
- **Section 2**: FractaVista (C++17/OpenGL, modern compute shaders)
- **Section 3**: Fractl (Rust/WebGPU, cross-platform with WASM)
- **Section 4**: GAPFixFractal (C++/CUDA, arbitrary-precision fixed-point)
- **Section 5**: Comparative feature matrix
- **Section 6**: References & attribution

**Best For**: Understanding implementation details, finding specific file references, technical decision-making.

---

### 2. [../../planning/IMPLEMENTATION_ROADMAP.md](./../../planning/IMPLEMENTATION_ROADMAP.md)
**378 lines | 12 KB | Actionable Implementation Guide**

Practical implementation guide with code examples, time estimates, and a phased development plan.

**Contents**:
- **Section 1**: Top 10 implementable techniques with code examples
- **Section 2**: 4-phase implementation plan with time estimates
- **Section 3**: Recommended Flutter project structure
- **Section 4**: Performance targets & benchmarks
- **Section 5**: References & implementation links

**Best For**: Planning sprints, prioritizing features, making design decisions.

---

## Quick Navigation

### By Project

| Project | Language | Platform | Best For |
|---------|----------|----------|----------|
| **[FractalShark](#fractalshark)** | C++/CUDA | Windows (GPU) | Extreme zoom, high precision |
| **[FractaVista](#fractavista)** | C++17 | Multi-platform | Modern architecture, multi-fractal |
| **[Fractl](#fractl)** | Rust | Multi-platform + WASM | Cross-platform patterns, coloring |
| **[GAPFixFractal](#gapfixfractal)** | C++/CUDA | Linux | Fixed-point math, formula variety |

### By Technology

| Technology | Projects | Files |
|-----------|----------|-------|
| **GPU Compute Shaders** | FractaVista, Fractl | `*.glsl`, `*.wgsl` |
| **Coloring Algorithms** | All projects | TECHNICAL_ANALYSIS.md §1.3, §2.3, §3.3, §4.3 |
| **Zoom Techniques** | All projects | TECHNICAL_ANALYSIS.md §1.4, §2.4, §3.4, §4.4 |
| **Perturbation Theory** | FractalShark | TECHNICAL_ANALYSIS.md §1.2 |
| **Multithreading** | FractalShark, Fractl | RefOrbitCalc.cpp, gpu.rs |
| **Feature Finder** | FractalShark, GAPFixFractal | FeatureFinder.cpp, locationdialog.h |

### By Difficulty

**Easy (Start Here)**
- Smooth iteration coloring formula
- Zoom with cursor centering
- Bulb detection optimization
- Basic palette system

**Medium**
- GPU compute shaders
- Interactive palette editor
- CPU multithreading fallback
- Julia set preview

**Advanced**
- Perturbation theory
- Linear approximation
- Reference orbit compression
- Feature finder (Newton-Raphson)

---

## FractalShark

**Type**: GPU-accelerated reference orbit research
**Focus**: Extreme zoom depths, high precision
**Key Innovation**: GPU-accelerated reference orbit with NTT

### Key Insights
- **Mandelbrot-only**: By design, exclusive focus on one set
- **10× GPU speedup**: RTX 4090 vs. multithreaded CPU MPIR at extreme zoom
- **Reference orbit compression**: Saves GB for high-period locations
- **Multiple CUDA implementations**: Different architectural strategies

### Techniques to Extract
1. Smooth iteration coloring with log formula
2. Perturbation theory with compression
3. Multithreaded reference orbit (3-thread architecture)
4. Linear approximation (2 CUDA variants)
5. Feature finder with Newton-Raphson

### Files
- **Main**: `FractalSharkLib/Fractal.h`, `GPU_Render.h`
- **Coloring**: `FractalPalette.cpp`
- **Perturbation**: `PerturbationResults.h` (84 files related)
- **GPU**: `GPU_BLAS.h`, `GPU_LAReference.h`

**Read in TECHNICAL_ANALYSIS.md**: Section 1 (pages 1-25)

---

## FractaVista

**Type**: Modern desktop fractal explorer
**Focus**: Multiple fractal types, clean architecture
**Key Innovation**: Fully dockable ImGui interface with compute shaders

### Key Insights
- **7 fractal types**: Mandelbrot, Julia, Burning Ship, Tricorn, Newton, Cubic, Feather
- **OpenGL 4.3+ compute**: Modern GPU pipeline
- **Shader hierarchy**: Dynamic includes per algorithm type
- **Interactive palette editor**: ImGui-based, gradient stops
- **Supersampling**: 8x quality for exports

### Techniques to Extract
1. GPU compute shader architecture
2. Per-algorithm shader includes with #defines
3. Interactive palette editor UI pattern
4. Smooth coloring in GPU (log-based)
5. Supersampling for high-quality export

### Files
- **Main**: `src/fractal/FractalComputer.cpp`
- **Shaders**: `assets/shaders/MainShader.glsl` + per-type includes
- **UI**: `src/ui/UIManager.cpp`
- **Shader compilation**: `src/gfx/Shader.cpp`

**Read in TECHNICAL_ANALYSIS.md**: Section 2 (pages 25-45)

---

## Fractl

**Type**: Cross-platform Rust fractal renderer
**Focus**: WASM support, conditional compilation, coloring algorithms
**Key Innovation**: Three coloring methods in WGSL, live browser demo

### Key Insights
- **WASM target**: Live demo at https://shapur1234.github.io/Fractl/
- **Three coloring modes**: Histogram, LCH, OLC (fully implemented)
- **Conditional compilation**: multithread XOR gpu (mutually exclusive)
- **f32/f64 variants**: Floating-point precision options
- **Clean escape-time**: Bulb detection optimization included

### Techniques to Extract
1. Three coloring algorithms (all in WGSL)
2. Bulb detection for interior skipping (15% perf gain)
3. WebGPU compute shader pattern (WGSL)
4. Multibrot parametric support
5. Conditional compilation patterns

### Files
- **Math algorithms**: `fractl_lib/src/math.rs`
- **GPU compute**: `fractl_lib/src/gpu.rs`, `shader.wgsl`
- **Coloring**: Lines 95-127 in `shader.wgsl`
- **Camera**: `fractl_lib/src/camera.rs`

**Read in TECHNICAL_ANALYSIS.md**: Section 3 (pages 45-65)

---

## GAPFixFractal

**Type**: Arbitrary-precision fixed-point fractal renderer
**Focus**: High-precision formula variety, DEM coloring
**Key Innovation**: On-the-fly CUDA kernel generation for any precision

### Key Insights
- **15+ formula variants**: Standard, tricorn, ship, celtic, magnet, etc.
- **512-bit precision**: Arbitrary-precision fixed-point math
- **Kernel generation**: Dynamic CUDA kernel compilation per precision
- **Distance Estimation**: DEM available for smooth boundaries
- **Julia preview**: Real-time preview while exploring Mandelbrot

### Techniques to Extract
1. 15+ fractal formulas (enum-based dispatch)
2. Arbitrary-precision fixed-point strategy
3. Distance Estimation (DEM) for coloring
4. Julia set preview pattern
5. Parameter storage with thumbnails

### Files
- **Formulas**: `src/include/formulas.h`
- **Coloring**: `src/include/colors.h`
- **Kernel generation**: `src/include/genkernel.h`
- **Main renderer**: `src/include/renderer.h`
- **UI dialogs**: `hybriddialog.h`, `locationdialog.h`

**Read in TECHNICAL_ANALYSIS.md**: Section 4 (pages 65-85)

---

## Comparison Matrix

**See TECHNICAL_ANALYSIS.md Section 5** for detailed feature comparison:

| Feature | FractalShark | FractaVista | Fractl | GAPFixFractal |
|---------|-------------|-----------|--------|---------------|
| Fractal types | 1 | 7 | 2 | 15+ |
| GPU backend | CUDA | OpenGL | WebGPU | CUDA |
| CPU fallback | Yes | No | Yes | No |
| Precision | MPIR (arbitrary) | f64 | f32/f64 | Fixed-point (512-bit) |
| Key algorithm | Perturbation+LA | Compute shader | Escape-time | Fixed-point kernel gen |

---

## Implementation Priority

### Phase 1: Core Features (2-3 weeks)
Start here for MVP:

1. **Smooth iteration coloring** — Formula only, biggest visual improvement
2. **GPU compute shader** — Single algorithm (Mandelbrot)
3. **Interactive palette** — Add/drag/delete color stops
4. **Zoom controls** — Cursor-centered, box selection
5. **Bulb detection** — 15% free performance win

**Reference**: ../../planning/IMPLEMENTATION_ROADMAP.md Sections 1-3

### Phase 2: Multi-Fractal (1-2 weeks)
Expand feature set:

6. **Julia set** — Reuse shader, different constant
7. **Burning Ship** — Absolute value in iteration
8. **Tricorn** — Conjugate in iteration
9. **Three coloring modes** — Histogram, LCH, OLC
10. **Export with supersampling** — 8x quality option

**Reference**: ../../planning/IMPLEMENTATION_ROADMAP.md Section 4

### Phase 3: Performance (1 week)
Optimize & cache:

11. **CPU multithreading** — dart:isolate fallback
12. **Preset system** — Save/load locations
13. **Caching** — Reference orbit, shader compilation
14. **Performance metrics** — FPS counter, render time

**Reference**: ../../planning/IMPLEMENTATION_ROADMAP.md Section 5

### Phase 4: Advanced (2-4 weeks, optional)
Research & extreme zoom:

15. **Perturbation theory** — 100,000+ digit zooms
16. **Linear approximation** — Alternative algorithm
17. **Feature finder** — Periodic point detection
18. **Video export** — Zoom animation recording

**Reference**: TECHNICAL_ANALYSIS.md Section 1 for deep details

---

## Code Examples

### 1. Smooth Iteration Coloring
Found in: FractalShark, FractaVista, Fractl

```glsl
// GLSL / WGSL
if (escapes_after_n_iterations) {
    smooth_value = log2(log2(magnitude(z)²))
    final_iteration = n - smooth_value + 4.0
    color = palette_lookup(final_iteration)
}
```

See: TECHNICAL_ANALYSIS.md §1.3, §2.3, §3.3

### 2. Bulb Detection
Found in: Fractl, FractaVista (commented)

```glsl
// Main cardioid test
q = c - vec2(0.25)
if (q.x² + q.y² * (q.x + q.y²) <= 0.25 * q.y²) {
    return maxIterations  // Skip interior
}
```

See: ../../planning/IMPLEMENTATION_ROADMAP.md §7

### 3. Three Coloring Algorithms
All in: Fractl `shader.wgsl` lines 95-127

- **Histogram**: `escape_time / max_iterations * 255`
- **LCH**: Cosine-wave based perceptual coloring
- **OLC**: Sinusoidal RGB variation

See: ../../planning/IMPLEMENTATION_ROADMAP.md §8

### 4. Palette UBO Setup
Found in: FractaVista

```cpp
// Setup uniform buffer for palette
glBindBuffer(GL_UNIFORM_BUFFER, paletteUBO);
glBufferSubData(GL_UNIFORM_BUFFER, 0, sizeof(PaletteUBOData), &uboData);
```

See: TECHNICAL_ANALYSIS.md §2.3

---

## Performance Targets

**Reference**: ../../planning/IMPLEMENTATION_ROADMAP.md Performance Targets

| Metric | Target | Reference |
|--------|--------|-----------|
| **FPS (1080p)** | 60 | FractaVista 50, Fractl 60 |
| **4K Export** | <5 sec | With 8x supersampling |
| **Startup** | <1 sec | Shader caching |
| **Max zoom (f64)** | 10^14 | Fractl demonstrated |
| **Memory** | <500 MB | All projects |

---

## Key References

### Deep Zoom Theory
- https://mathr.co.uk/blog/2021-05-14_deep_zoom_theory_and_practice.html
- https://mathr.co.uk/blog/2022-02-21_deep_zoom_theory_and_practice_again.html

### Source Repositories
- **FractalShark**: https://github.com/mattsaccount364/FractalShark
- **FractaVista**: https://github.com/Krish2882005/FractaVista
- **Fractl**: https://github.com/Shapur1234/Fractl
- **GAPFixFractal**: https://github.com/3rdparty/GAPFixFractal

### Standards & APIs
- **OpenGL Compute Shaders**: https://www.khronos.org/opengl/wiki/Compute_Shader
- **WebGPU Spec**: https://www.w3.org/TR/webgpu/
- **WGSL Language**: https://www.w3.org/TR/wgsl/

### Flutter Integration
- **flutter_gpu**: Custom GPU integration (experimental)
- **flutter_shaders**: GLSL/WGSL shader support
- **dart:isolate**: Multithreading
- **dart:ffi**: C/C++ FFI for rendering backends

---

## How to Use These Documents

### For Architecture Planning
1. Start with **../../planning/IMPLEMENTATION_ROADMAP.md** sections 1-2
2. Read **TECHNICAL_ANALYSIS.md** section 5 (Comparison Matrix)
3. Decide which techniques to prioritize

### For Implementation
1. Choose a feature from Phase 1 (../../planning/IMPLEMENTATION_ROADMAP.md)
2. Find the project that implements it best
3. Read corresponding section in TECHNICAL_ANALYSIS.md
4. Locate specific files and line numbers
5. Adapt code pattern to Flutter

### For Deep Understanding
1. Pick a project of interest
2. Read complete section in TECHNICAL_ANALYSIS.md
3. Visit GitHub repository (see references)
4. Examine key files with line number references
5. Understand architectural patterns

### For Performance Tuning
1. See Performance Targets (../../planning/IMPLEMENTATION_ROADMAP.md)
2. Reference Optimization Wins section
3. Implement high-impact techniques first
4. Profile with Flutter DevTools

---

## Document Statistics

| Metric | Value |
|--------|-------|
| **Total lines** | 1,151 |
| **Total sections** | 95+ |
| **File references** | 100+ |
| **Code examples** | 30+ |
| **Projects analyzed** | 4 |
| **Techniques identified** | 50+ |
| **Implementation phases** | 4 |
| **High-priority features** | 10 |

---

## Next Steps

1. **Read ../../planning/IMPLEMENTATION_ROADMAP.md** — Choose Phase 1 priorities
2. **Reference TECHNICAL_ANALYSIS.md** — Deep-dive on chosen techniques
3. **Create Flutter skeleton** — Implement recommended project structure
4. **Start Phase 1** — Smooth coloring + GPU compute shader + palette editor
5. **Iterate** — Add features from Phase 2 & 3

---

**Created**: February 17, 2026
**Last Updated**: February 17, 2026
**Status**: Complete and ready for development planning
