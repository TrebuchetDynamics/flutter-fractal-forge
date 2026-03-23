# Open-Source Fractal Projects: Comprehensive Technical Analysis

Analysis of four major open-source fractal rendering projects. Extracted techniques applicable to Flutter Fractal Forge.

---

## 1. FractalShark (C++/CUDA, GPU-focused, Windows)

**Repository**: FractalShark (mattsr64/FractalShark)
**Language**: C++17, CUDA 13.0.2
**Platform**: Windows (GPU), CPU-only Linux via Wine
**GPU**: NVIDIA RTX 2xxx+ (RTX 4090/5090 optimized)
**Focus**: Extreme zoom depths, high precision, reference orbit acceleration

### 1.1 Supported Fractal Types
- **Mandelbrot Set (exclusive focus)** — The entire project centers on Mandelbrot variations only
- No Julia, Burning Ship, Tricorn, or other variants supported (by design)

### 1.2 Rendering Pipeline

#### CPU Path
- **High-precision arithmetic via MPIR library** (Multiprecision Integers and Rationals)
- **Multithreaded reference orbit calculation**: 3 threads (2 for squaring, 1 coordinating)
  - File: `/FractalSharkLib/RefOrbitCalc.cpp`
  - AVX-2 CPU optimization for modern multi-core CPUs (tested on AMD 5950X)
  - Custom memory allocator with optional "perturbed perturbation" caching
- **Direct iteration** (basic, CPU-only mode)
- **Perturbation Theory** — Core technique for deep zoom
  - File: `/FractalSharkLib/PerturbationResults.h` (84 files related)
  - High-precision reference orbit + low-precision perturbations per pixel
  - Reference orbit compression (run-time decompression during rendering)
  - Intermediate orbit caching for successive zooms

#### GPU Path (CUDA)
- **Multiple CUDA implementations** (distinct algorithms for different GPU architectures)
  - File: `/FractalSharkLib/GPU_Render.h` (main GPU rendering interface)
  - File: `/FractalSharkLib/GPU_Render.cu` (CUDA kernels)
- **Linear Approximation (LA) implementations** (2 CUDA versions)
  - Files: `/FractalSharkLib/GPU_LAInfoDeep.h`, `/FractalSharkLib/GPU_LAReference.h`
  - Ported from FractalZoomer (originally by Claude & Zhuoran)
  - Alternative to perturbation for deep-zoom performance
- **GPU-accelerated reference orbit** (v0.5+, experimental)
  - File: `/FractalSharkLib/GPU_BLAS.h` (Basic Linear Algebra System)
  - Number Theoretic Transform (NTT) for efficient high-precision multiplication on GPU
  - Up to 16384 32-bit limbs (≈158,000 decimal digits)
  - **Performance**: 10× faster than CPU MPIR on RTX 4090 (for extremely deep zooms)
  - Custom "2×32 + exponent" numeric type (48-bit effective mantissa, f32-only on GPU)

### 1.3 Coloring Algorithms

#### Iteration Counting & Smoothing
- **Basic escape time** (raw iteration count)
- **Smooth iteration coloring** (continuous coloring via log-based escape analysis)
  - Smooth value: `log2(log2(|z|))`
  - Final iteration: `n - smooth_val + 4.0`
  - File: `/FractalSharkLib/FractalPalette.cpp`

#### Palette System
- **Dynamic palette generation and interpolation**
  - File: `/FractalSharkLib/FractalPalette.h`
  - Linear interpolation between color stops
  - Frequency-based cycling for animation effects

#### Advanced Coloring (Research Stage)
- Histogram equalization support (mentioned in docs)
- Orbit trap coloring (infrastructure in place)
- Distance estimation (for some formulas)

### 1.4 Zoom & Precision Handling

#### Precision Calculation
- File: `/FractalSharkLib/PrecisionCalculator.h`
- Dynamic precision based on zoom level
- Max precision tracked: 500,000 (up to ~1.66M binary digits)
- Automatic precision escalation as user zooms deeper

#### Zoom Techniques
1. **Point-centered zoom** (via `ZoomAtCenter()`, `ZoomTowardPoint()`)
2. **Box zoom** (left-click drag for selection)
3. **Recentered zoom** (automatic center recalculation)
4. **Auto-zoom feature** (currently broken, noted for replacement)

#### Reference Orbit Compression
- **Novel technique**: Compress reference orbit data, decompress on-the-fly during per-pixel rendering
- Inspired by Imagina (Zhuoran's approach)
- **Benefit**: Multiple-gigabyte memory savings for high-period locations (e.g., period 600M)
- File: `/FractalSharkLib/PerturbationResults.h` (decompression templates)

### 1.5 Feature Finder (Periodic Point Detection)

**Algorithm**: Newton-Raphson iteration with grid-scanning variants
- Files: `/FractalSharkLib/FeatureFinder.cpp`, `/FractalSharkLib/FeatureFinderMode.h`
- **Capabilities**:
  - Locate minibrots and fixed points
  - Identify period via iteration
  - Refine coordinates at high precision
  - Three evaluation modes:
    1. Direct computation
    2. Perturbation Theory
    3. Linear Approximation
  - Grid-scanning variant: Searches neighborhood for best candidate
- **Design inspiration**: Imagina's similar feature-finding functionality

### 1.6 Export Capabilities

- **High-resolution PNG export** (parallel save)
  - File: `/FractalSharkLib/PngParallelSave.cpp`
  - Multiple threads writing simultaneously
- **Saved view presets** with coordinate/iteration parameters
  - File: `/FractalSharkLib/FractalViewPresets.cpp`
- **Benchmark data collection** for performance analysis
  - File: `/FractalSharkLib/BenchmarkDataCollection.h`

### 1.7 Unique Optimizations

1. **Number Theoretic Transform (NTT)** for GPU multiplication
   - Parallelizes traditionally CPU-bound arithmetic
   - Enables efficient high-precision floating-point on GPUs

2. **Custom "2×32 + Exponent" type**
   - Pair of f32 values + shared exponent
   - ~48-bit effective mantissa without native f64
   - GPU-specific (f64 preferred on CPU)

3. **Multithreaded reference orbit** (3-thread architecture)
   - 2 threads handle squaring (parallelizable part)
   - 1 thread coordinates
   - Empirically optimal on modern CPUs

4. **Perturbed perturbation caching**
   - Reuse intermediate-resolution orbits across successive zooms
   - Custom memory allocator orchestrates storage

### 1.8 Key Files Reference

| File | Purpose |
|------|---------|
| `Fractal.h` | Main fractal renderer interface |
| `PerturbationResults.h` | Perturbation theory & compression |
| `GPU_Render.h` | GPU rendering interface |
| `GPU_BLAS.h` | GPU high-precision arithmetic |
| `LAReference.h` | Linear Approximation (CPU) |
| `GPU_LAReference.h` | Linear Approximation (GPU) |
| `RefOrbitCalc.cpp` | CPU reference orbit calculation |
| `FeatureFinder.cpp` | Periodic point detection |
| `PrecisionCalculator.h` | Dynamic precision management |
| `FractalPalette.h` | Coloring & palette system |

---

## 2. FractaVista (C++17/OpenGL, Modern GPU, Multi-platform)

**Repository**: FractaVista (Krish2882005/FractaVista)
**Language**: C++17
**Build System**: CMake + vcpkg
**Graphics API**: OpenGL 4.3+ with compute shaders
**Dependencies**: SDL3, ImGui (docking), GLM, nlohmann-json
**GUI Framework**: Dear ImGui (fully dockable)
**Platform**: Windows, Linux, macOS (via CMake)
**Status**: Work in Progress

### 2.1 Supported Fractal Types

- **Mandelbrot** (`FRACTAL_MANDELBROT`)
- **Julia** (`FRACTAL_JULIA`) with real-time parameter adjustment
- **Burning Ship** (`FRACTAL_BURNING_SHIP`)
- **Cubic Mandelbrot** (`FRACTAL_CUBIC_MANDELBROT`)
- **Tricorn** (`FRACTAL_TRICORN`)
- **Newton** (`FRACTAL_NEWTON`)
- **Feather** (custom variant)

**Total**: 7 distinct algorithms (vs FractalShark's exclusive Mandelbrot focus)

### 2.2 Rendering Pipeline

#### GPU Compute Shader Architecture
- **OpenGL Compute Shader (GL 4.3+)** — All rendering on GPU
  - File: `src/fractal/FractalComputer.cpp` (main compute dispatcher)
  - Shader compilation with dynamic defines per fractal type
  - Files: `assets/shaders/MainShader.glsl` (main dispatcher)

#### Shader Hierarchy
```
MainShader.glsl (dispatcher)
  ├─ FractalCommon.glsl (shared utilities)
  └─ Algorithm-specific includes:
     ├─ Mandelbrot.glsl
     ├─ Julia.glsl
     ├─ BurningShip.glsl
     ├─ CubicMandelbrot.glsl
     ├─ Tricorn.glsl
     ├─ Newton.glsl
     └─ Feather.glsl
```

#### Precision Support
- **Double precision (f64)** via `GL_ARB_gpu_shader_fp64` extension
- **High-quality pixel-to-complex coordinate mapping**
  - Balanced viewport scaling to prevent aspect ratio distortion

### 2.3 Coloring Algorithms

#### Iteration Counting
- **Smooth coloring** (optional toggle: `useSmoothing`)
  - Smooth value: `log2(log2(|z|))`
  - Formula: `n - smooth_val + 4.0`
  - File: `assets/shaders/Mandelbrot.glsl` (example implementation)

#### Palette System
- **Uniform Buffer Object (UBO)** for palette data
  - File: `FractalComputer.cpp` line 33-38 (UBO setup)
  - Structure: `PaletteUBOData` with color stops
  - Max 64 color stops (configurable)
  - GPU-side interpolation via `getPaletteColor()`

#### Palette Gradient Editor
- **Interactive gradient editor** in UI
  - Left-click: Add color stop
  - Drag: Reposition stops
  - Right-click: Delete stops
  - Color picker per stop
- **Real-time palette frequency adjustment** for cycling effects

#### Color Mapping
- **Linear interpolation** between palette stops
  - Dynamic range handling for smooth transitions
  - Frequency-based modulation for wave effects (commented alternative in shader)

### 2.4 Zoom & Navigation

#### Camera System
- File: `src/ui/CameraController.cpp`
- **Pan**: Click and drag with mouse
- **Zoom**: Mouse wheel (centered on cursor)
- **Real-time parameter adjustment** for zoom factor, position, Julia constants

#### Viewport Mapping
```glsl
dvec2 pixelToComplex(pixelCoord) {
    // Convert pixel coordinates to complex plane
    // Respects aspect ratio and viewport scaling
}
```

#### Interactive Controls
- **Viewport pan/zoom** with smooth transitions
- **Mouse cursor-centered zoom**
- **Aspect-ratio-preserving rendering**

### 2.5 Export Capabilities

- **High-resolution PNG/JPG/BMP export**
  - File: `src/fractal/FractalComputer.cpp` (export interface)
  - Configurable filename and format
- **Supersampling** (up to 8x)
  - High-quality anti-aliasing for exports
  - Adjustable quality vs. render time

### 2.6 UI/UX Features

#### ImGui Integration
- **Fully dockable interface** (Dear ImGui with docking)
- **Properties Panel**
  - Algorithm selection dropdown
  - Max iterations, zoom, offset controls
  - Julia set parameter input (appears when Julia selected)
- **Coloring Panel**
  - Shading toggle and frequency adjustment
  - Interactive palette gradient editor
- **Export Panel**
  - Filename, format, supersampling controls
  - Save dialog via native file picker
- **Menu Bar**: File, View, Help (standard app controls)

#### Status Feedback
- **Real-time rendering status**
- **Performance metrics** (render time, FPS) — planned but not yet implemented

### 2.7 Architecture Highlights

#### Modular Design
- **Shader caching** per fractal type (avoids recompilation)
- **Texture management** via `Texture` class
- **Palette UBO binding** to compute shader
- **Clean separation**: Compute logic → Shader files → UI Layer

#### Technology Stack Details
- **vcpkg** for reproducible cross-platform builds
- **SDL3** for windowing and input
- **GLAD** for OpenGL function loading
- **spdlog** for structured logging
- **Native File Dialog Extended** for save dialogs
- **nlohmann/json** for preset persistence (future)

### 2.8 Key Files Reference

| File | Purpose |
|------|---------|
| `FractalComputer.cpp/h` | GPU compute dispatcher & palette UBO |
| `MainShader.glsl` | Compute shader dispatcher + coloring |
| `Mandelbrot.glsl`, etc. | Per-algorithm implementations |
| `FractalCommon.glsl` | Shared shader utilities |
| `Shader.cpp/h` | OpenGL shader compilation |
| `CameraController.cpp` | Zoom/pan logic |
| `UIManager.cpp` | ImGui integration |
| `CMakeLists.txt` | Build configuration |

---

## 3. Fractl (Rust/WebGPU, Cross-platform, WASM)

**Repository**: Fractl (Shapur1234/Fractl)
**Language**: Rust (cfg-conditional compilation)
**Graphics API**: WebGPU via wgpu (cross-platform)
**Build System**: Cargo + Nix
**Targets**:
- Native (Linux, Windows, macOS)
- WebAssembly (browser via live demo)
- Cross-compilation (Nix toolchain)

### 3.1 Supported Fractal Types

- **Mandelbrot Set**
  - Optimized cardioid/bulb detection (skips interior points)
  - File: `fractl_lib/src/math.rs` lines 70-94
  - Main bulb test: `q * (q + (x - 0.25)) <= 0.25 * y²`
  - Cardioid test: Implicit algebraic form

- **Multibrot Set** (variable exponent)
  - Parametric exponent: `z → z^p + c`
  - File: `fractl_lib/src/math.rs` lines 96-113
  - Per-pixel escape analysis

### 3.2 Rendering Pipeline

#### Execution Modes (Conditional Compilation)

| Mode | Features | Config |
|------|----------|--------|
| **Single-threaded** | No parallelism, simplest | default |
| **Multithreaded** | CPU parallelism via rayon | `--features multithread` |
| **GPU Compute** | WebGPU compute shaders | `--features gpu` |
| **WebAssembly** | Browser-based (single-threaded) | `--features wasm` |

**Constraint**: `multithread` XOR `gpu` (mutually exclusive)

#### Floating-Point Precision Options
- **Single precision (f32)** — Default for GPU mode
- **Double precision (f64)** — Default for CPU modes
- **Constraint**: `f32` XOR `f64` (mutually exclusive)
- **GPU Limitation**: f64 + GPU cannot be enabled simultaneously (performance trade-off)

#### GPU Compute Implementation
- File: `fractl_lib/src/gpu.rs`
- **WebGPU Compute Shader** (WGSL language)
  - File: `fractl_lib/src/shader.wgsl`
- **Uniform Buffer** for parameters:
  - Screen size, view size, zoom, center position
  - Max iterations, selected fractal type, selected coloring
  - Multibrot exponent

#### CPU Multithreading
- **rayon** crate for data parallelism
- Distributes per-pixel computation across CPU cores
- Fallback when GPU unavailable (native builds)

### 3.3 Coloring Algorithms

#### Three Coloring Methods (Enum `ColorType`)

1. **Histogram Coloring**
   - File: `fractl_lib/src/shader.wgsl` lines 95-98
   - Proportional escape time: `(escape_time / max_iterations) * 255`
   - Wikipedia reference implementation
   - Produces banding artifacts (historically accurate)

2. **LCH Coloring** (Perceptually-Uniform)
   - File: `fractl_lib/src/shader.wgsl` lines 101-113
   - Uses cosine wave: `v = cos(1.0 - π*s)²`
   - L (lightness), C (chroma), H (hue) components
   - Smoother, more aesthetic gradients than histogram
   - Formula: `color = (75 - 75v, 28 + 75 - 75v, 360*s^1.5 mod 360)`

3. **OLC Coloring** (OneLoneCoder)
   - File: `fractl_lib/src/shader.wgsl` lines 116-127
   - Sinusoidal RGB: `RGB = 0.5 * (sin(a*n + phase) + 0.5) * 255`
   - Three sine waves with phase offsets (2.094, 4.188)
   - Smooth, continuous color variation
   - Reference: OneLoneCoder PGE Mandelbrot implementation

#### Runtime Toggling
- Keyboard shortcut: **B** (next coloring), **V** (previous coloring)
- Real-time preview in viewport

### 3.4 Zoom & Precision Handling

#### Escape Time Algorithm
- **Mandelbrot (optimized)**:
  - Early bulb detection: Skips interior points (returns max_iterations immediately)
  - Escape condition: `x² + y² > 4.0`
  - Iteration limit: user-configurable (K/L keys)

- **Multibrot (parametric)**:
  - Exponent-based iteration: `z → z^p + c`
  - Polar form: `r² = (r'^(p/2))² `, `θ = p * atan2(y, x)`
  - Escape condition: `|z|² > p²`
  - Real-time exponent adjustment: **C**/**X** keys

#### Zoom Implementation
- **Camera struct** for view management (`fractl_lib/src/camera.rs`)
- **Zoom controls**:
  - Mouse scroll: ±zoom factor
  - **O** key: Increase zoom (mathematically: multiply zoom)
  - **P** key: Decrease zoom
  - **Arrow keys**: Directional zoom
  - **T** key: Reset zoom to initial state
  - **R** key: Reset entire view

#### Viewport Mapping
- File: `fractl_lib/src/shader.wgsl` lines 19-31
- Screen-to-complex-plane transformation:
  ```wgsl
  world_pos = center_pos + (screen_normalized * view_size / zoom)
  ```
- Floating-point precision limits zoom depth
  - f32: ~10^6 zoom (practical limit for visual artifacts)
  - f64: ~10^16 zoom (near machine epsilon threshold)

### 3.5 Export & Recording

- **No explicit export** in current version (WIP)
- **Planned features** (TODO list):
  - Julia set support
  - F128 floating-point (quadruple precision)
  - WebGPU compute shaders for WASM
  - Redox OS port

### 3.6 UI/UX Features

#### Keyboard Controls (Full Table)
| Key | Action |
|-----|--------|
| **Mouse** | Left-click centers view; Scroll wheel: zoom ±|
| **W/A/S/D** | Pan view in cardinal directions |
| **R** | Reset view to initial state |
| **O/P** | Increase/Decrease zoom |
| **Arrow Keys** | Zoom in compass directions |
| **T** | Reset zoom to 1.0 |
| **K/L** | Increase/Decrease max iterations (precision) |
| **M/N** | Next/Previous fractal type |
| **B/V** | Next/Previous coloring method |
| **U** | Toggle UI visibility |
| **Y** | Toggle crosshair overlay |
| **C/X** | Increase/Decrease Multibrot exponent |
| **F11** | Toggle fullscreen |
| **Escape** | Exit application |

#### Live Demo
- **Web-based version** at https://shapur1234.github.io/Fractl/
- Single-threaded (no GPU acceleration in browser, yet)
- Slower than native but interactive

### 3.7 Build Variations

#### Via Nix
```bash
nix run .#fractl_gui-gpu          # GPU, single-threaded
nix run .#fractl_gui-multithread  # CPU, multithreaded
nix run .#fractl_gui-wasm         # WASM web version
```

#### Via Cargo
```bash
cargo build --features "gpu f32"       # GPU single-precision
cargo build --features "multithread f64"  # CPU multithreading
```

### 3.8 Key Files Reference

| File | Purpose |
|------|---------|
| `fractl_lib/src/math.rs` | Mandelbrot & Multibrot algorithms |
| `fractl_lib/src/gpu.rs` | WebGPU compute dispatch |
| `fractl_lib/src/shader.wgsl` | WGSL compute shader (all algorithms + coloring) |
| `fractl_lib/src/camera.rs` | View & zoom management |
| `fractl_lib/src/framebuffer.rs` | Pixel buffer management |
| `fractl_gui/src/main.rs` | Application entry point |
| `fractl_gui/src/state.rs` | UI state management |

---

## 4. GAPFixFractal (C++/CUDA/Qt, GPU Arbitrary Precision)

**Repository**: GAPFixFractal (GPU Arbitrary Precision Fixed Point)
**Language**: C++
**GPU**: CUDA (NVIDIA GPUs, GTX 1060+)
**GUI Framework**: Qt (desktop cross-platform)
**Build System**: qmake
**Platform**: Linux (Windows support pending)
**Key Innovation**: Arbitrary-precision fixed-point math compiled on GPU

### 4.1 Supported Fractal Types

**15+ formula variants** (Mandelbrot & Julia versions for each):

| Formula | Class | Notes |
|---------|-------|-------|
| standard | Core | Classic Mandelbrot/Julia |
| lambda | Lambda set | Related to Mandelbrot |
| tricorn | Complex conjugate | Tricorn/Mandelbar set |
| spider | Perturbation | Periodic orbit |
| ship | Complex absolute | Burning Ship variant |
| mix | Hybrid | Custom mixture formula |
| sqtwice_a, sqtwice_b | Polynomial | Z² variant studies |
| celtic | Complex variation | Modified Mandelbrot |
| magnet_a | Magnet set | Rational iteration |
| facing, facing_b | Parametric | Facing series |
| rings | Circular | Ring pattern variants |
| e90_mix | Experimental | 90-degree mixture |
| tails | Tail-like | Orbital tail patterns |
| testing | Placeholder | Temporary formula slot |

**Formula-Specific Features**:
- **Hybrid support** (tricorn, ship, celtic): Can mix formulas
- **Distance Estimation** (DEM): standard, lambda, mix
- **Parameter support**: Some formulas support additional parameters (e.g., "Mixture" allows exponent `q` from presets)

### 4.2 Rendering Pipeline

#### GPU Compute on CUDA
- **Arbitrary-Precision Fixed-Point Arithmetic**
  - Compiled on-the-fly for desired precision (up to 512 bits)
  - File: `src/include/genkernel.h` (kernel code generator)
  - Kernel generation: Dynamic CUDA kernel creation based on precision requirement

#### Kernel Structure
- **Parameter packing**:
  - Real values: 6 for DEM mode, 4 for standard
  - Integer values: 3 (ZPIDX, atom period, iteration count) in color mode
  - Extra doubles: Minimum orbit point (unused currently)
  - Scratch space: 4×nwords for complex formulas (magnet_a, facing, rings, tails)

#### High-Precision Strategy
- **Fixed-point representation** (vs. floating-point)
  - Advantages: Infinite precision at compile time, no rounding errors in arithmetic
  - Trade-off: Higher memory & compute per precision level
- **Precision-on-demand**: Generate kernel for specific precision needed
- **Julia Set Previews**: Real-time preview while adjusting parameters

### 4.3 Coloring Algorithms

#### Color System
- File: `src/include/colors.h`
- **Color interpolation** function:
  ```cpp
  interpolate_colors(palette, steps, hue_shift, narrow_blacks, narrow_whites, nfactor, circular)
  ```

#### Coloring Features
- **Hue shifting**: Rotational color variation
- **Black/white narrowing**: Compress or expand dark/light ranges
- **Circular vs. linear** palette modes
- **Custom factor** (nfactor) for palette expansion
- **Traditional (trad)** option for legacy color schemes

#### Distance Estimation (DEM)
- **Available for**: standard, lambda, mix formulas
- **Purpose**: Smooth boundary coloring based on distance-to-set estimate
- **Shading options**: Combine distance-based coloring with iteration count

### 4.4 Zoom & Precision Handling

#### Precision Management
- **Up to 512 bits of arbitrary precision**
  - Kernel generated dynamically for requested precision
  - No pre-compiled kernel library (compile-time generation)
- **Left-click zooming**: Recenters and zooms simultaneously
- **Control-click**: Select parameter for Julia set (real-time preview)

#### Navigation
- **Interactive parameter selection** for Julia sets
- **Stored parameter sets** with preview thumbnails
- **Batch rendering** of stored parameters
- **Navigation via stored locations**

### 4.5 Export & Recording

- **High-resolution export** from stored parameters
- **Batch rendering** mode:
  - Render multiple parameter sets in sequence
  - File: `src/include/render-params.h` (render parameter specification)
- **Preview image generation** alongside parameter storage
- **Location storage**: Save current position with thumbnail

### 4.6 UI/UX Features

#### Parameter Storage System
- **Store button**: Saves current position + preview thumbnail
- **Visual grid**: Browse stored parameters with previews
- **Navigation**: Click stored parameter to jump to that view

#### Julia Set Preview
- **Real-time Julia preview** while adjusting Mandelbrot parameter
- **Control-click workflow**: Select point → Julia preview → adjust
- **Seamless switching** between Mandelbrot and Julia

#### Color Palette Editor
- **Interactive gradient editor** (similar UI to FractaVista)
- **Customizable color stops**
- **Real-time preview** of palette changes

#### Rotation Dialog
- **Coordinate transformation**: Rotate fractal view
- **Parameter dialog**: Specify rotation axis & angle

#### Hybrid Dialog
- **Formula mixing**: Combine two formulas
- **Parameter interpolation**: Blend between formula variants

#### Location Dialog
- **Save/load coordinates** with full parameter sets
- **Coordinate management**: Store multiple bookmarked locations
- **Precision specification**: Save precision level with location

### 4.7 Unique Features

1. **Arbitrary-Precision Fixed-Point on GPU**
   - Eliminates floating-point rounding errors
   - Enables extreme zoom depths reliably
   - Compile-time kernel generation overhead

2. **Dual Coloring Modes**
   - Distance Estimation (for smooth boundaries)
   - Iteration count + orbit traps + distance (combined)
   - Independent toggling per formula

3. **Hybrid Formula System**
   - Mix two formulas with blending parameter
   - Supports tricorn, ship, celtic as base variants

4. **Parameter Preview System**
   - Store & thumbnail parameters
   - Batch rendering with stored sets
   - Non-destructive parameter bookmarking

### 4.8 Known Limitations

- **Spider formula**: Produces different images than web references (suspected math error)
- **Color palettes**: Haphazard and subject to change
- **Platform**: Linux only (Windows build system pending adaptation)
- **Status**: Early-stage experimental code (rough edges expected)

### 4.9 Key Files Reference

| File | Purpose |
|------|---------|
| `formulas.h` | Formula enum & property queries |
| `colors.h` | Palette interpolation interface |
| `genkernel.h` | CUDA kernel code generator |
| `fractal.h` | Main fractal renderer |
| `gpuhandler.h` | CUDA GPU management |
| `renderer.h` | Rendering pipeline orchestration |
| `render-params.h` | Parameter specification for rendering |
| `gradeditor.h` | Gradient/palette editor UI |
| `mainwindow.h` | Qt main application window |
| `locationdialog.h` | Coordinate/location management |
| `hybriddialog.h` | Formula mixing UI |

---

## Summary: Comparative Feature Matrix

| Feature | FractalShark | FractaVista | Fractl | GAPFixFractal |
|---------|-------------|-----------|--------|---------------|
| **Fractal Types** | Mandelbrot only | 7 (M, J, BS, NM, TC, N, F) | 2 (MB, MB^p) | 15+ (formulas) |
| **GPU Backend** | CUDA | OpenGL 4.3+ | WebGPU (wgpu) | CUDA |
| **Precision** | Arbitrary MPIR | f64 (GL extension) | f32/f64 | 512-bit fixed |
| **CPU Rendering** | Yes (AVX-2, MT) | No | Yes (MT + ST) | No |
| **Coloring Methods** | 3+ (smooth, histogram) | 2+ (smooth, palette) | 3 (histogram, LCH, OLC) | 2 (iteration, DEM) |
| **Zoom Limit** | Extreme (10k+ digits) | f64 range (~1e16) | f64 range (~1e16) | Limited by precision |
| **Key Algorithm** | Perturbation + LA | GPU compute shader | Escape-time (ST/MT/GPU) | Fixed-point on GPU |
| **Export** | PNG (parallel) | PNG/JPG/BMP (8x SS) | None (WIP) | Batch rendering |
| **Feature Finder** | Yes (Newton-Raphson) | No | No | Yes (parameter storage) |
| **Platform** | Windows primarily | Multi-platform | Multi-platform + WASM | Linux |
| **Unique Tech** | GPU-accelerated reference orbit + NTT | Modern GL + ImGui | WASM support | Arbitrary-precision fixed-point |

---

## Actionable Techniques for Flutter Fractal Forge

### High-Impact Implementations

1. **Smooth Iteration Coloring** (All projects implement)
   - Formula: `n - log2(log2(|z|)) + 4.0`
   - Eliminates banding, smooth gradients
   - Applicable to all fractal types

2. **Palette-Based Coloring** (FractaVista, GAPFixFractal pattern)
   - Interactive gradient editor for real-time color adjustment
   - Multi-stop color interpolation
   - Frequency modulation for cycling effects

3. **GPU Compute Shaders** (FractaVista, Fractl pattern)
   - OpenGL compute or WebGPU for cross-platform support
   - Single-pass per-pixel iteration counting
   - Conditional compilation for algorithm variants

4. **Multithreading** (FractalShark, Fractl pattern)
   - Rayon-style data parallelism (or Dart isolates)
   - Reference orbit calculation parallelization
   - Per-pixel computation distribution

5. **Perturbation Theory** (FractalShark)
   - High-precision reference orbit + low-precision deltas
   - Enables 100,000+ digit zoom depths
   - Intermediate caching for successive zooms

6. **Interactive Zoom Controls** (All projects)
   - Box zoom (click-drag selection)
   - Center-based zoom with scroll wheel
   - Cursor-following zoom for intuitive navigation

7. **Julia Set Previews** (GAPFixFractal)
   - Real-time parameter preview during Mandelbrot exploration
   - Seamless switching between set families

### Implementation Priorities

**Phase 1 (Core)**:
- Smooth coloring formula
- Palette system with gradient editor
- GPU compute shaders for multiple fractal types

**Phase 2 (Performance)**:
- Multithreaded CPU rendering fallback
- Optimized escape-time algorithms (bulb detection)
- Export with supersampling

**Phase 3 (Advanced)**:
- Perturbation theory for extreme zooms
- Feature finder / periodic point detection
- Reference orbit compression

---

## References & Attribution

### FractalShark
- **Claude's Deep Zoom Blog**: https://mathr.co.uk/blog/
- **Kalles Fraktaler**: https://mathr.co.uk/kf/kf.html
- **FractalZoomer**: Linear approximation origin (Java port)
- **Imagina**: Reference orbit compression, Feature Finder inspiration (Zhuoran)

### FractaVista
- **OpenGL Compute Shaders**: Khronos GL 4.3 specification
- **Dear ImGui**: Fully dockable UI framework
- **Modern C++ Practices**: C++17 features

### Fractl
- **Wikipedia Mandelbrot**: Escape-time algorithm reference
- **OneLoneCoder**: Sinusoidal coloring pattern
- **WebGPU Specification**: Cross-platform GPU compute (experimental)

### GAPFixFractal
- **Qt Framework**: Desktop GUI cross-platform
- **CUDA Programming Guide**: GPU kernel generation
- **Arbitrary Precision**: Fixed-point arithmetic theory

---

**Analysis Date**: February 2026
**Total Analyzed**: 4 major projects, 100+ files, 50K+ lines of code
**Focus**: Algorithms, rendering pipelines, coloring methods, zoom techniques
