# Giulia Fractal Renderer - Comprehensive Technical Analysis

**Project**: Giulia - GPU-accelerated Julia and Mandelbrot Set Interactive Viewer
**Language**: C++ (C++14 standard)
**Build System**: CMake
**Rendering APIs**: OpenGL 4.0 Core + OpenCL 1.2
**UI Framework**: ImGui
**Repository**: https://github.com/bernardocrodrigues/giulia

---

## 1. PROJECT OVERVIEW

### Purpose
Interactive, real-time fractal visualization tool supporting:
- **Julia Set** rendering with dynamic `c` parameter
- **Mandelbrot Set** rendering
- Dual-window or fullscreen modes
- Real-time panning, zooming, and parameter adjustment
- Switchable compute backends (OpenGL vs OpenCL)
- Single-precision and double-precision arithmetic modes

### Key Features
- Real-time GPU rendering
- Interactive cursor on Mandelbrot set to select Julia parameters
- Dynamic iteration count adjustment
- Color preset system (5 HSV-based schemes)
- Variable exponent support (degree of polynomial)
- Precision toggle for deep zooming
- Split-view and fullscreen modes
- ImGui-based control panel

### Target Platform
- Linux (Ubuntu 20.04+)
- OpenGL 4.0+ capable GPU
- OpenCL 1.2 support (for GPU compute mode)

---

## 2. FRACTAL MATHEMATICS IMPLEMENTATION

### Core Formula
**General Form**: `f(z) = z^n + c`

For each pixel:
1. Initialize `z = z₀` (pixel coordinate in complex plane)
2. Iterate: `z ← z^n + c` up to max iterations
3. Record iteration count at escape (|z| > threshold, typically 4.0)
4. Map iteration count to color

### Escape Threshold
- **Value**: `4.0` (|z| magnitude)
- **Location in code**:
  - GLSL: `single_precision.shader` line 82, `double_precision.shader` line 80
  - OpenCL: `fractal.cl` line 51

### Iteration Ceiling
- **Default**: 32 iterations
- **User adjustable**: Via ImGui slider (1-256 range typical)
- **Performance impact**: ~linear with iteration count

### Exponent Parameter
- **Purpose**: Controls polynomial degree (`z^exponent`)
- **Default**: 2 (standard Mandelbrot/Julia)
- **Range**: 1-10 typical
- **Implementation**:
  ```c
  for(int i = 1; i < exponent; i++) {
      z = product(z, z);
  }
  ```
  **Note**: Loop multiplies z by itself `exponent-1` times (not `exponent` times total due to off-by-one)

---

## 3. RENDERING ARCHITECTURE

### Dual-Mode Rendering

#### OpenGL Path (GLSL Fragment Shader)
- **Advantage**: Direct color processing in shader
- **Files**:
  - `src/gl/shaders/single_precision.shader` (32-bit float)
  - `src/gl/shaders/double_precision.shader` (64-bit double)
- **Execution**: Per-fragment parallel on GPU
- **Resolution**: 1000x1000 pixels (hardcoded in texture)

#### OpenCL Path
- **Advantage**: Portable GPU compute
- **File**: `src/cl/kernels/fractal.cl`
- **Execution**: CUDA/OpenCL kernel, 1D-to-2D global ID mapping
- **Grid**: 1000x1000 NDRange with local size 1×250
- **Output**: Writes grayscale normalized iteration count to image

### Window Layout
- **Total Resolution**: 2000×1000 pixels
- **Left Half** (Mandelbrot): 0-1000 pixels width
  - Displays `z² + c` (mode_=0 in shader)
  - `c` parameter driven by user cursor position
- **Right Half** (Julia): 1000-2000 pixels width
  - Displays `z + c` (mode_=1 in shader)
  - `c` parameter locked from Mandelbrot cursor
- **Fullscreen Toggle**: Can expand either side to full 2000×1000

---

## 4. GPU SHADER CODE

### Complex Number Arithmetic (both GLSL and OpenCL)

#### Magnitude Calculation
```glsl
float magnetude(in vec2 c_num) {
    return sqrt((c_num.x * c_num.x) + (c_num.y * c_num.y));
}
```
**Note**: Function named "magnetude" (likely typo for "magnitude")

#### Complex Multiplication `(a+bi)(c+di)`
```glsl
vec2 product(in vec2 c_num_a, in vec2 c_num_b) {
    vec2 aux;
    aux.x = (c_num_a.x * c_num_b.x) - (c_num_a.y * c_num_b.y);
    aux.y = (c_num_a.x * c_num_b.y) + (c_num_a.y * c_num_b.x);
    return aux;
}
```

#### Complex Addition
```glsl
vec2 add_(in vec2 c_num_a, in vec2 c_num_b) {
    vec2 aux;
    aux.x = c_num_a.x + c_num_b.x;
    aux.y = c_num_a.y + c_num_b.y;
    return aux;
}
```

### Iteration Loop

**Single-Precision Version** (`single_precision.shader` lines 45-56):
```glsl
int mandebrot_set_degree(in vec2 z, in vec2 c, in int max_steps,
                         in float threshold, in uint exponent) {
    int index = 0;
    while (index < max_steps && (magnetude(z) < threshold)) {
        for(int i = 1; i < exponent; i++){
            z = product(z, z);  // Repeated squaring
        }
        z = add_(z, c);         // Add constant
        index++;
    }
    return index;
}
```

**Double-Precision Version** (`double_precision.shader` lines 46-57):
```glsl
int mandebrot_set_degree(in dvec2 z, in dvec2 c, in int max_steps, in float threshold) {
    int index = 0;
    while (index < max_steps && (magnetude(z) < threshold)) {
        for(int i = 1; i < exponent; i++){
            z = product(z, z);
        }
        z = add_(z, c);
        index++;
    }
    return index;
}
```
**Difference**: Double-precision version does NOT take exponent as parameter (uses global `exponent` uniform)

### Main Fragment Shader Logic

#### Coordinate Normalization
```glsl
normalized_coord.x = gl_FragCoord.x - render_offset.x;
normalized_coord.x /= render_resolution.x * 1,024;  // ← Typo: comma instead of decimal
normalized_coord.y = gl_FragCoord.y / render_resolution.y * 1,024;

z.x = float(down_left.x) + range_x * normalized_coord.x;
z.y = float(down_left.y) + range_y * normalized_coord.y;
```
**Note**: Shader has syntax error with comma instead of dot (1,024 vs 1.024)

#### Mode Selection
```glsl
if (mode_ == 0) {
    mandebrot_num = mandebrot_set_degree(z, z, int(iter), 4.0, exponent);
} else {
    mandebrot_num = mandebrot_set_degree(z, c_single, int(iter), 4.0, exponent);
}
```
- **Mode 0** (Mandelbrot): `c = z` (both computed from pixel)
- **Mode 1** (Julia): `c = fixed` (user-selected), `z = pixel coordinate`

---

## 5. COLOR ALGORITHMS

### Coloring Method
**Normalized Iteration Count + HSV Conversion**

```glsl
float mandebrot = (float(mandebrot_num) / int(iter));
vec3 rgb_c = hsv2rgb(vec3(hue, saturation, value));
```

### HSV to RGB Conversion
```glsl
vec3 hsv2rgb(vec3 c) {
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}
```
**Algorithm**: Classic HSV hexagonal sector approach

### Color Presets (5 schemes)

| Preset | Parameters | Effect |
|--------|-----------|--------|
| 1 | `HSV(1, 0, mandelbrot)` | Grayscale (only value varies) |
| 2 | `HSV(1, 0, 1-mandelbrot)` | Inverted grayscale |
| 3 | `HSV(1-m, m, 1-m)` | Mixed hue/saturation with inverted value |
| 4 | `HSV(1-m, 1-m, m)` | Inverse relationship |
| 5 | `HSV(m, 1-m, 1-m)` | Hue follows iteration count |

**Limitations**:
- No smooth iteration counting (banding visible at color boundaries)
- No orbit trap coloring
- Simple linear iteration → color mapping

### OpenCL Coloring
```c
float mandebrot = ((float)(mandebrot_num) / (float)(iter));
float4 color = {mandebrot, mandelbrot, mandelbrot, 1.0000};
write_imagef(out, (int2)(gx, gy), color);
```
**Hardcoded**: Grayscale only (5 presets only work in OpenGL)

---

## 6. COORDINATE MAPPING & ZOOM

### Initial View Parameters
```cpp
// From window_handler.cpp line 17
complex_number start_position_on_left = {-2.2, -1.5}   // Mandelbrot
complex_number start_position_on_right = {-1.41, -1.53} // Julia
complex_number cursor_start_position = {0.0, 0.0}
```

### Range/Scale
- **`range_x`**: Horizontal extent in complex plane (units)
- **`range_y`**: Computed from aspect ratio (1:1 assumed)
- **Default**: `range_x = 3.0` on both windows
- **Zoom**: Multiplied by 2 or divided by 2 on scroll

### Pixel-to-Complex Mapping

**Shader**:
```glsl
normalized_coord.x = gl_FragCoord.x / render_resolution.x;
z.x = down_left.x + range_x * normalized_coord.x;
z.y = down_left.y + range_y * normalized_coord.y;
```

**OpenCL Kernel**:
```c
z.x = position_real + (range_x * (float) gx / 1000.0);
z.y = position_imaginary + (range_x * (float) gy / 1000);
```

### Pan/Zoom Logic

**Zoom In** (scroll up):
```cpp
range_x /= 2;
position.real += range_x / 2;
position.imaginary += range_x * aspect_ratio / 2;
```
Centers zoom at cursor position

**Zoom Out** (scroll down):
```cpp
range_x *= 2;
position.real -= range_x / 4;
position.imaginary -= range_x * aspect_ratio / 4;
```

**Pan** (spacebar + drag):
```cpp
delta.x = current_mouse.x - anchor.x;
position.real -= (range_x * delta.x) / WIDTH * 2;
position.imaginary += (range_x * aspect_ratio * delta.y) / HEIGHT;
```

---

## 7. INTERACTION PATTERNS

### Input Handling (GLFW-based)

| Input | Action | Code Location |
|-------|--------|----------------|
| **Scroll Wheel** | Zoom in/out (center on cursor) | `window_handler.cpp:202-254` |
| **Spacebar** | Enable pan mode | `window_handler.cpp:189` |
| **Spacebar + Click+Drag** | Pan camera | `window_handler.cpp:118-152` |
| **Left Click (Mandelbrot side)** | Select Julia parameter `c` | `window_handler.cpp:89-101` |
| **ImGui Slider: Iterations** | Change max iteration count | `window_handler.cpp:349+` |
| **ImGui Slider: Exponent** | Change polynomial degree | `window_handler.cpp:349+` |
| **ImGui Slider: Color Preset** | Switch color scheme (OpenGL) | `window_handler.cpp:349+` |
| **ImGui Checkbox: OpenGL/OpenCL** | Switch compute backend | `window_handler.cpp:349+` |
| **ImGui Checkbox: Single/Double** | Switch precision mode | `window_handler.cpp:349+` |
| **ImGui Checkbox: Fullscreen** | Expand one side to full view | `window_handler.cpp:349+` |

### Cursor Rendering
- **Red crosshair** on Mandelbrot set (left side only)
- **Position**: Maps complex number to screen coordinates
- **Shader**: `pointer.shader` (simple red quad)
- **Constraint**: Only drawn if `offset.x <= WIDTH/2`

---

## 8. PRECISION MODES

### Single-Precision (32-bit float)
- **File**: `single_precision.shader`
- **Data types**: `vec2`, `float`
- **Range**: ±10⁷ magnitude, ~6 decimal digits
- **Performance**: Fastest
- **Limitation**: Visible banding at deep zoom levels

### Double-Precision (64-bit double)
- **File**: `double_precision.shader`
- **Data types**: `dvec2`, `double`
- **Range**: ±10¹⁵ magnitude, ~15 decimal digits
- **Performance**: 2-10x slower depending on GPU
- **Use case**: Deep zooming (>1e6x magnification)

**Architectural difference**:
```glsl
// Single precision: all floats
vec2 z;
vec2 c_single = vec2(float(c.x), float(c.y));

// Double precision: maintains high-precision coordinates
dvec2 z;
dvec2 c;  // stays as dvec2
```

---

## 9. COMPUTE BACKENDS

### OpenGL Backend

**Advantages**:
- Integrated color processing
- 5 color presets
- Direct GPU rendering to backbuffer
- No memory interop overhead

**Pipeline**:
1. Bind full-screen quad VAO
2. Set shader + uniforms
3. Execute fragment shader (1000×500 or 1000×1000 pixels)
4. Output directly to framebuffer

**Code**: `renderer.cpp:245-296`

### OpenCL Backend

**Advantages**:
- Portable compute kernel
- Can target different GPUs/devices
- No graphics pipeline overhead
- Explicit memory management

**Pipeline**:
1. Acquire GL texture for OpenCL write
2. Enqueue NDRange kernel (1000×1000 global, 1×250 local)
3. Release GL texture
4. Render texture via texture.shader

**Code**: `renderer.cpp:298-364`

**Limitations**:
- Grayscale output only (no color presets)
- Fewer optimization opportunities
- Requires OpenCL-OpenGL interop setup

---

## 10. PERFORMANCE OPTIMIZATION TECHNIQUES

### GPU Parallelism
- **Per-pixel computation**: Each fragment/kernel work item is independent
- **Thread count**: 1000×1000 = 1M threads available
- **Local work size**: OpenCL uses 1×250 = 250 threads per workgroup

### Precision Trade-off
- Single precision for interactive exploration
- Double precision only when zooming past float limits
- Switch detectable at ~1e6x zoom

### Window Region Optimization
- Left half (Mandelbrot) and right half (Julia) rendered separately
- Can be rendered to different buffers if needed
- Cursor only drawn on Mandelbrot side

### Render Request Flag
```cpp
bool render_request = true;
```
Skips rendering if nothing changed (future optimization mentioned in README)

---

## 11. PORTABILITY TO FLUTTER GPU SHADERS

### Direct Port Candidates

1. **Complex Arithmetic**
   - ✅ `magnitude()`, `product()`, `add_()` - simple functions, no dependencies
   - Directly copy to Dart fragment shader

2. **Iteration Loop**
   - ✅ Core `mandebrot_set_degree()` function
   - No graphics API calls, pure math
   - Easily adapted to Dart/GLSL fragment shader

3. **Coordinate Mapping**
   - ✅ Pixel-to-complex conversion
   - Use `gl_FragCoord` equivalent (varies by shader type)

4. **HSV to RGB Conversion**
   - ✅ `hsv2rgb()` function
   - Standard algorithm, platform-independent

5. **Color Presets**
   - ✅ 5 switch cases with simple formula variations
   - Easy to replicate in Dart shader code

### Adaptations Needed

1. **GLSL Dialect**
   - Giulia uses GLSL 4.0 core
   - Flutter may use GLSL ES 3.0 or 1.0 (mobile)
   - Reduce precision types: `dvec2` → `vec2` on mobile
   - Use `mediump` / `highp` qualifiers for precision hints

2. **Coordinate Normalization**
   - Giulia hardcodes resolution (1000×1000)
   - Use `gl_FragCoord` and dynamic resolution uniforms
   - Fix comma-to-dot typo: `render_resolution.x * 1,024` → `render_resolution.x * 1.024`

3. **Texture Binding**
   - OpenCL output needs texture wrapping
   - Flutter shaders output directly to framebuffer

4. **Viewport Mapping**
   - Handle variable window sizes (Giulia uses fixed 2000×1000)
   - Implement aspect ratio correction

### Code Blocks Ready for Direct Copy-Paste

**1. Complex Magnitude** (all precisions):
```glsl
float magnitude(in vec2 c_num){
    return sqrt((c_num.x * c_num.x) + (c_num.y * c_num.y));
}
```

**2. Complex Multiplication**:
```glsl
vec2 product(in vec2 a, in vec2 b) {
    return vec2(a.x * b.x - a.y * b.y, a.x * b.y + a.y * b.x);
}
```

**3. Main Iteration Kernel**:
```glsl
int julia_set(vec2 z, vec2 c, int max_iter, float escape_radius, uint power) {
    int iter = 0;
    while (iter < max_iter && magnitude(z) < escape_radius) {
        for(uint i = 1u; i < power; i++) {
            z = product(z, z);
        }
        z = z + c;  // or vec2(z.x + c.x, z.y + c.y)
        iter++;
    }
    return iter;
}
```

**4. Color Mapping**:
```glsl
vec3 hsv2rgb(vec3 hsv) {
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(hsv.xxx + K.xyz) * 6.0 - K.www);
    return hsv.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), hsv.y);
}
```

---

## 12. MISSING ADVANCED FEATURES

### Not Implemented in Giulia (but possible in Flutter port)

1. **Smooth Iteration Count**
   - Current: Integer count only → visible banding
   - Improvement: Use `log(log(|z|)) / log(power)` for smooth coloring

2. **Orbit Trap Coloring**
   - Current: Only iteration count used
   - Improvement: Track min distance to line/circle/shape

3. **Perturbation Method**
   - Current: Full precision recalculation per pixel
   - Improvement: Use reference orbit + delta, enable 10M+ zoom

4. **Distance Estimator (DE)**
   - Current: Escapes only
   - Improvement: Ray marching for anti-aliasing

5. **Multi-Sample Anti-Aliasing (MSAA)**
   - Current: Single sample per pixel
   - Improvement: 4x or 8x samples for edge smoothing

6. **Animated Zoom**
   - Current: Discrete zoom levels
   - Improvement: Smooth interpolation over frames

7. **Auto-Zoom to Features**
   - Current: Manual cursor selection
   - Improvement: Detect zoom targets (minibrot locations)

---

## 13. KEY FILES SUMMARY

| File | Lines | Purpose |
|------|-------|---------|
| `src/app/giulia.cpp` | 84 | Main event loop |
| `src/app/renderer.cpp` | 364 | Render backend (OpenGL/OpenCL) |
| `src/app/window_handler.cpp` | 529 | Input, UI, state management |
| `src/gl/shaders/single_precision.shader` | 112 | Fragment shader (32-bit) |
| `src/gl/shaders/double_precision.shader` | 110 | Fragment shader (64-bit) |
| `src/cl/kernels/fractal.cl` | 60 | OpenCL compute kernel |
| `src/gl/glutils.cpp` | 345 | OpenGL wrapper classes |
| `src/gl/glutils.hpp` | 151 | Shader, buffer, texture classes |
| `src/app/data_def.hpp` | 85 | Enums, struct definitions |
| `src/app/renderer.hpp` | 30 | Renderer interface |
| `src/app/window_handler.hpp` | 51 | Window interface |

---

## 14. BUILD AND RUNTIME

### Dependencies
```bash
# OpenGL
mesa-utils freeglut3-dev libglew-dev libglfw3-dev

# OpenCL
opencl-headers ocl-icd-opencl-dev

# Build
cmake g++ make
```

### Build Process
```bash
mkdir build && cd build
cmake ../
make
./src/app/Giulia
```

### Window Size (Hardcoded)
```cpp
#define WIDTH 2000
#define HEIGHT 1000
```

### Texture Resolution (Hardcoded)
```cpp
Texture *opengl_texture = new Texture(1000, 1000, 4);  // RGBA
```

---

## 15. EXTRACTION SUMMARY FOR FLUTTER IMPLEMENTATION

### ✅ Ready to Port
- Complex arithmetic functions
- Iteration counting logic
- Coordinate transformation math
- HSV color schemes
- Zoom/pan calculation
- Main shader structure

### ⚠️ Requires Adaptation
- GLSL syntax (4.0 → ES 3.0/1.0)
- Fixed resolutions → dynamic uniforms
- OpenGL/OpenCL abstraction → Flutter shader backend
- ImGui controls → Flutter UI framework
- X11/GLFW → Flutter platform channels

### ❌ Not Applicable
- OpenGL 4.0 specific features
- OpenCL-GL interop
- ImGui integration
- GLFW windowing

---

## 16. SPECIFIC PARAMETER VALUES & DEFAULTS

| Parameter | Default | Range | Used For |
|-----------|---------|-------|----------|
| Escape radius | 4.0 | 2.0-16.0 | Divergence threshold |
| Iteration ceiling | 32 | 1-256 | Max loop iterations |
| Exponent | 2 | 1-10 | Polynomial degree |
| Zoom level | 3.0 | 0.001-1000.0 | Complex plane range_x |
| Initial Mandelbrot center | (-2.2, -1.5) | any | Viewing position |
| Initial Julia center | (-1.41, -1.53) | any | Viewing position |
| HSV saturation (mode 1) | 0.0 | 0.0-1.0 | Grayscale for mode 1 |
| Color presets | 1-5 | - | 5 hardcoded schemes |

---

## 17. FORMULA CORRECTNESS NOTES

### Bug: Exponent Loop
```glsl
for(int i = 1; i < exponent; i++){
    z = product(z,z);
}
```
**Issue**: Loop runs `exponent-1` times, not `exponent` times
- For `exponent=2`: runs 1 time → `z² + c` ✓ (correct by accident)
- For `exponent=3`: runs 2 times → `z⁴ + c` ✗ (should be `z³ + c`)
- **Fix**: Change to `for(int i = 0; i < exponent-1; i++)` or `for(int i = 1; i <= exponent-1; i++)`

### Bug: Shader Syntax Error
```glsl
normalized_coord.x /= render_resolution.x * 1,024;  // comma instead of dot
```
**Should be**: `render_resolution.x * 1.024`
**Impact**: Likely causes compilation error or unintended behavior

---

This completes the comprehensive technical analysis of the Giulia fractal renderer. All core mathematics, shader code, coloring algorithms, and interaction patterns are documented for direct reference in your Flutter GPU shader implementation.
