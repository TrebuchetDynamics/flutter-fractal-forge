# DEEP-DIVE: Four Open-Source Fractal Projects
## Technical Reference for Flutter/GLSL ES 3.0 Fragment Shader App

**Analysis Date:** February 2026
**Projects Analyzed:**
1. **DeepDrill** - Perturbation + Series Approximation (C++ SFML)
2. **FractaVista** - Compute Shader Architecture (C++ OpenGL)
3. **Fractl** - Rust GPU/CPU with WASM (Rust wgpu)
4. **fractals-generator** - Multi-precision Rendering (C++)

---

## PROJECT 1: DeepDrill (C++/SFML)

### File Locations
- **Root:** `flutter-fractal-forge/opensource/repos/renderers/DeepDrill/`
- **Source:** `flutter-fractal-forge/opensource/repos/renderers/DeepDrill/src/`
- **Shaders:** `flutter-fractal-forge/opensource/repos/renderers/DeepDrill/shaders/`

### Architecture Overview

DeepDrill implements perturbation theory + series approximation for deep zooms. It's a multi-component system:

```
src/
├── config.h              # Build config, version (3.2.0), MAP_FORMAT=320
├── ddrill/               # Core drilling engine
│   ├── DeepDrill.h       # Main app class (extends Application)
│   ├── Driller.h         # Orchestrates reference point + probe picking
│   ├── ReferencePoint.h  # Reference orbit structure
│   ├── Approximator.h    # Series approximation coefficients
│   ├── MapAnalyzer.h     # Glitch detection
│   └── SlowDriller.h     # Reference computation
├── dmake/                # Video generation (DeepMake)
│   ├── DeepMake.h        # INI → DIR pipeline
│   └── Maker.h           # Keyframe interpolation
├── dzoom/                # Video recording + FFmpeg integration
│   ├── DeepZoom.h        # Main zoom viewer
│   ├── FFmpeg.h          # FFmpeg launcher
│   ├── Recorder.h        # Frame writer
│   ├── Zoomer.h          # Zoom animation
│   └── NamedPipe.h       # FFmpeg pipe I/O
├── math/                 # Precision arithmetic
│   ├── StandardComplex.h # f64 complex (real, imag)
│   ├── ExtendedComplex.h # 2-tuple (hi, lo) for extended precision
│   ├── ExtendedDouble.h  # (mantissa, exponent) pairs
│   └── PrecisionComplex.h# GMP (mpf_class) for arbitrary precision
├── shared/               # Data structures
│   ├── DrillMap.h        # Pixel result grid + texture channels
│   ├── Coord.h           # (i16 x, i16 y) pixel coordinates
│   ├── Options.h         # Global config (location, drillmap, video, etc)
│   ├── Palette.h         # Color palette management (SFML image)
│   ├── ImageMaker.h      # Drill map → rendered image
│   └── AssetManager.h    # Shader/palette loading
└── util/                 # Utilities
    ├── DynamicFloat.h    # Animated float (start, end, duration)
    ├── Compressor.h      # Zlib compression for mapfiles
    ├── Colors.h          # GPU color structs
    └── Parser.h          # Config parsing
```

### Key Data Structures

#### 1. Location Specification
**File:** `flutter-fractal-forge/opensource/repos/renderers/DeepDrill/src/shared/Options.h` (lines 70-85)

```cpp
struct Location {
    mpf_class real;      // Center X (arbitrary precision GMP)
    mpf_class imag;      // Center Y (arbitrary precision GMP)
    mpf_class zoom;      // Magnification level (GMP)
    isize depth;         // Max iterations
    double escape;       // Escape radius
} location;
```

**Format:** GMP-based arbitrary precision. Used for location files (likely JSON or text).

#### 2. DrillMap Structure
**File:** `flutter-fractal-forge/opensource/repos/renderers/DeepDrill/src/shared/DrillMap.h` (lines 80-130)

```cpp
class DrillMap {
public:
    isize width, height;          // Pixel dimensions
    PrecisionComplex center;      // Center coordinate (GMP)
    PrecisionComplex ul, lr;      // Bounding box (upper-left, lower-right)

    // Multi-channel result storage
    std::vector<DrillResult> resultMap;       // Pixel outcome (DR_ESCAPED, DR_PERIODIC, etc)
    std::vector<u32> firstIterationMap;       // First computed iteration
    std::vector<u32> lastIterationMap;        // Last computed iteration
    std::vector<float> nitcntMap;             // Normalized iteration count
    std::vector<float> distMap;               // Distance estimates
    std::vector<double> derivReMap;           // Derivative (real)
    std::vector<double> derivImMap;           // Derivative (imag)
    std::vector<float> normalReMap;           // Normal vector (real)
    std::vector<float> normalImMap;           // Normal vector (imag)

    // OpenGL textures for GPU colorization
    sf::Texture iterationMapTex;
    sf::Texture nitcntMapTex;
    sf::Texture distMapTex;
    sf::Texture normalReMapTex;
    sf::Texture normalImMapTex;
};
```

**Channels:** 7 independent result channels enable post-processing colorization via shaders.

#### 3. Drill Results Enum
**File:** `flutter-fractal-forge/opensource/repos/renderers/DeepDrill/src/shared/DrillMap.h` (lines 25-35)

```cpp
enum DrillResult : i8 {
    DR_UNPROCESSED,
    DR_ESCAPED,              // Exceeded escape radius
    DR_MAX_DEPTH_REACHED,    // Hit iteration ceiling
    DR_IN_BULB,              // Main bulb detection (optimization)
    DR_IN_CARDIOID,          // Cardioid detection (optimization)
    DR_PERIODIC,             // Period detection (found cycle)
    DR_ATTRACTED,            // Attractor detection
    DR_GLITCH,               // Perturbation glitch (reference failed)
};
```

#### 4. Options Configuration
**File:** `flutter-fractal-forge/opensource/repos/renderers/DeepDrill/src/shared/Options.h` (full structure)

```cpp
struct Options {
    // Perturbation parameters
    struct Perturbation {
        bool enable;              // Enable perturbation
        double tolerance;         // Glitch detection threshold
        double badpixels;         // Max miscolored fraction
        isize rounds;             // Max refinement rounds
        std::optional<GpuColor> color;  // Debug color for glitches
    } perturbation;

    // Series approximation parameters
    struct Approximation {
        bool enable;
        isize coefficients;       // Number of Taylor coefficients
        double tolerance;         // Approximation error threshold
    } approximation;

    // Video output
    struct Video {
        isize frameRate;
        isize keyframes;          // Number of zoom keyframes
        isize startframe;         // First visible keyframe
        DynamicFloat velocity;    // Zoom velocity per frame
        isize bitrate;            // FFmpeg bitrate
    } video;

    // Palette/colorization
    struct Palette {
        fs::path image;           // Palette image path
        GpuColor bgColor;         // Background (set interior)
        ColoringMode mode;        // Classic or Smooth
        DynamicFloat scale;       // Palette stretch
        DynamicFloat offset;      // Palette shift
    } palette;

    // Lighting/3D effect
    struct Lighting {
        bool enable;
        DynamicFloat alpha;       // Light direction (azimuth)
        DynamicFloat beta;        // Light direction (elevation)
    } lighting;
};
```

### Perturbation Algorithm

**File:** `flutter-fractal-forge/opensource/repos/renderers/DeepDrill/src/ddrill/Driller.h`

```cpp
class Driller {
    ReferencePoint ref;           // Reference orbit (computed in high precision)
    Approximator approximator;    // Series approximation coefficients
    std::vector<Coord> probePoints; // Secondary probe points

public:
    void drill();                 // Main entry point

private:
    void collectCoordinates(std::vector<Coord> &remaining);
    ReferencePoint pickReference(const std::vector<Coord> &glitches);
    void pickProbePoints(std::vector<Coord> &probes);

    // Drilling operations
    void drill(ReferencePoint &ref);
    isize drillProbePoints(std::vector<Coord> &probes);
    isize drillProbePoint(Coord &probe);
    void drill(const std::vector<Coord> &remaining, std::vector<Coord> &glitchPoints);
};
```

**Algorithm:**
1. Compute reference point at high precision (extended or GMP)
2. For each pixel, compute perturbation delta (low precision)
3. If glitch detected (reference diverges), pick new reference
4. Use series approximation to skip early iterations

### Precision System

**Three-Tier Architecture:**

#### Tier 1: StandardComplex (double precision)
**File:** `flutter-fractal-forge/opensource/repos/renderers/DeepDrill/src/math/StandardComplex.h`

```cpp
struct StandardComplex {
    double re, im;
    // Methods: norm(), abs(), arg(), operator*(), square(), conjugate()
};
```

#### Tier 2: ExtendedDouble (mantissa + exponent)
**File:** `flutter-fractal-forge/opensource/repos/renderers/DeepDrill/src/math/ExtendedDouble.h`

```cpp
struct ExtendedDouble {
    double mantissa;    // Normalized to [0.5, 1.0)
    long exponent;      // Base-2 exponent

    double asDouble() { return ldexp(mantissa, (int)exponent); }
    void reduce() {     // Normalize mantissa
        int exp;
        mantissa = frexp(mantissa, &exp);
        exponent += exp;
    }
};
```

#### Tier 3: ExtendedComplex (paired double-double)
**File:** `flutter-fractal-forge/opensource/repos/renderers/DeepDrill/src/math/ExtendedComplex.h`

```cpp
struct ExtendedComplex {
    StandardComplex high;  // High-order bits
    StandardComplex low;   // Low-order bits
    // Provides ~106 bits of precision (double-double arithmetic)
};
```

#### Tier 4: PrecisionComplex (GMP arbitrary precision)
Uses `mpf_class` from GMP for reference point computation.

### GPU Colorization Pipeline

**Shaders Directory:** `flutter-fractal-forge/opensource/repos/renderers/DeepDrill/shaders/`

#### Main Colorizer
**File:** `flutter-fractal-forge/opensource/repos/renderers/DeepDrill/shaders/colorizers/gradient.glsl`

```glsl
// Inputs: Multi-channel textures from drill map
uniform sampler2D nitcnt;      // Normalized iteration count
uniform sampler2D normalRe;    // Normal vector (real)
uniform sampler2D normalIm;    // Normal vector (imag)
uniform sampler2D palette;     // Color palette (1D texture)
uniform sampler2D dist;        // Distance estimates
uniform sampler2D texture;     // Overlay texture

// Parameters
uniform float paletteScale;
uniform float paletteOffset;
uniform bool smooth;           // Smooth vs classic coloring
uniform vec4 bgcolor;          // Set interior color
uniform float distThreshold;   // Border thickness
uniform float textureOpacity;  // Texture blend

// Utility functions
vec3 rgb2hsv(vec3 c);         // RGB ↔ HSV conversion
vec3 hsv2rgb(vec3 c);
float decode_int(vec4 v);     // Decode integer from 4-channel texel
float decode_float(vec4 v);   // Decode float from 4-channel texel

// Main pipeline
vec3 deriveColor(vec2 coord) {
    float nic = decode_float(texture2D(nitcnt, coord));
    if (!smooth) nic = floor(nic);
    float px = mod(nic / 64.0 * paletteScale + paletteOffset, 1.0);
    return texture2D(palette, vec2(px, 0.0)).rgb;
}

void main() {
    vec3 diffuseColor = deriveColor(coord);
    vec4 textureColor = deriveTexturePixel(coord, nrmRe, nrmIm);
    diffuseColor = mix(diffuseColor, textureColor.rgb, textureOpacity * textureColor.a);
    diffuseColor = applyBorderEffect(coord, diffuseColor);
    gl_FragColor = vec4(diffuseColor, 1.0);
}
```

**Decode Function (Critical for channel interpretation):**
```glsl
float decode_float(vec4 v) {
    vec4 bits = v * 255.0;
    float sign = mix(-1.0, 1.0, step(bits[3], 128.0));
    float expo = floor(mod(bits[3] + 0.1, 128.0)) * 2.0 +
                 floor((bits[2] + 0.1) / 128.0) - 127.0;
    float sig = bits[0] + bits[1] * 256.0 +
                floor(mod(bits[2] + 0.1, 128.0)) * 256.0 * 256.0;
    return sign * (1.0 + sig / 8388607.0) * pow(2.0, expo);
}
```

**Scaling Filters:**
- Bicubic interpolation
- Trilinear filtering
- Lanczos resampling

### Video Export Pipeline (DeepMake + FFmpeg)

**Files:**
- `flutter-fractal-forge/opensource/repos/renderers/DeepDrill/src/dmake/DeepMake.h`
- `flutter-fractal-forge/opensource/repos/renderers/DeepDrill/src/dzoom/FFmpeg.h`

**DeepMake INI Format → Directory of frames:**
```cpp
class DeepMake : public Application {
    const char *optstring() const;  // Command-line options
    bool isAcceptedInputFormat(Format format) const {
        return format == Format::INI;  // Input: INI config
    }
    bool isAcceptedOutputFormat(Format format) const {
        return format == Format::DIR;  // Output: Frame directory
    }
};
```

**FFmpeg Integration:**
```cpp
class FFmpeg {
public:
    static std::vector<fs::path> paths;  // Located executables
    static fs::path exec;                // Selected FFmpeg binary

    FILE *handle;                        // Pipe handle

    static void init();
    static bool available();
    bool launch(const string &args);     // Execute FFmpeg
    bool isRunning();
    void join();                         // Wait for completion
};
```

**Pipeline:**
1. DeepDrill produces drill map (.mapfile in compressed format)
2. DeepMake reads INI, generates keyframe interpolations
3. Recorder writes frames to disk via NamedPipe
4. FFmpeg encodes pipe stream to video (H.264/VP9)

---

## PROJECT 2: FractaVista (C++/OpenGL)

### File Locations
- **Root:** `flutter-fractal-forge/opensource/repos/renderers/FractaVista/`
- **Source:** `flutter-fractal-forge/opensource/repos/renderers/FractaVista/src/`

### Architecture Overview

```
src/
├── main.cpp                    # Entry point
├── app/
│   └── Application.cpp         # Main window loop + preset I/O
├── core/
│   └── Window.cpp              # SDL3 + OpenGL context
├── fractal/
│   ├── FractalComputer.cpp     # Compute shader dispatch (8× SSAA export)
│   ├── FractalComputer.hpp     # UBO data structures
│   ├── FractalDefinition.hpp   # Fractal type registry
│   ├── FractalTypes.hpp        # Enum + parameter structs
│   └── FractalState.hpp        # Full render state
├── gfx/
│   ├── Shader.cpp              # GL_COMPUTE_SHADER compilation
│   ├── Shader.hpp              # UBO binding
│   ├── Texture.cpp             # RGBA8888 render targets
│   └── Texture.hpp
├── ui/
│   ├── CameraController.cpp    # Pan, zoom, rotation
│   ├── Theme.cpp               # Color scheme
│   └── UIManager.cpp           # ImGui controls
└── util/
    ├── FileUtils.hpp           # Shader loading, path resolution
    ├── JsonUtils.hpp           # nlohmann/json preset serialization
    ├── Logger.hpp              # Structured logging
    └── PlatformUtils.hpp       # File dialogs, OS integration
```

### Fractal Type Definitions
**File:** `flutter-fractal-forge/opensource/repos/renderers/FractaVista/src/fractal/FractalTypes.hpp`

```cpp
enum class FractalType {
    Mandelbrot,
    Julia,
    BurningShip,
    CubicMandelbrot,
    Tricorn,
    Newton
};

struct FractalSpecificParams {
    glm::dvec2 juliaConstant = { -0.8, 0.156 };  // Julia c parameter
};

struct ColorStop {
    glm::vec3 color;
    float position;  // [0, 1] in palette
};

struct ColoringParams {
    bool useSmoothing = true;
    double paletteFrequency = 0.01f;  // Smoothing intensity
    std::vector<ColorStop> palette;   // Dynamic color stops
};
```

**Fractal Registry:**
**File:** `flutter-fractal-forge/opensource/repos/renderers/FractaVista/src/fractal/FractalDefinition.hpp`

```cpp
struct FractalDefinition {
    std::string_view name;
    std::string_view shaderDefine;  // e.g., "FRACTAL_MANDELBROT"
};

static const std::map<FractalType, FractalDefinition> FractalDefinitions = {
    { FractalType::Mandelbrot, { "Mandelbrot", "FRACTAL_MANDELBROT" } },
    { FractalType::Julia, { "Julia", "FRACTAL_JULIA" } },
    { FractalType::BurningShip, { "Burning Ship", "FRACTAL_BURNING_SHIP" } },
    { FractalType::CubicMandelbrot, { "Cubic Mandelbrot", "FRACTAL_CUBIC_MANDELBROT" } },
    { FractalType::Tricorn, { "Tricorn", "FRACTAL_TRICORN" } },
    { FractalType::Newton, { "Newton", "FRACTAL_NEWTON" } }
};
```

**Shader Selection:** Defines are injected into `MainShader.glsl` at compile time.

### Compute Shader Architecture

**File:** `flutter-fractal-forge/opensource/repos/renderers/FractaVista/src/fractal/FractalComputer.cpp`

#### UBO Data Layout (std140)
```cpp
struct alignas(16) ColorStopUBOData {
    glm::vec3 Color;
    float Position;
};

struct PaletteUBOData {
    int NumStops;
    int Padding[3];                    // std140 alignment
    ColorStopUBOData Stops[MAX_PALETTE_STOPS];
};
```

#### GPU Dispatch (Real-time Render)
```cpp
void FractalComputer::generate(const FractalState& state) {
    onResize(state.renderWidth, state.renderHeight);

    Shader& shader = getOrCreateShader(state.type);
    shader.use();

    updatePaletteUBO(state.coloring);
    m_texture->bindImage(0);

    // Set shader uniforms
    shader.setVec2("fullResolution", glm::dvec2{m_width, m_height});
    shader.setVec2("offset", state.offset);           // Pan
    shader.setDouble("zoom", state.zoom);             // Magnification
    shader.setInt("maxIterations", state.maxIterations);
    shader.setBool("useSmoothing", state.coloring.useSmoothing);
    shader.setDouble("paletteFrequency", state.coloring.paletteFrequency);

    if (state.type == FractalType::Julia) {
        shader.setVec2("juliaC", state.specificParams.juliaConstant);
    }

    // Dispatch compute groups (16×16 workgroup size)
    const int groupSize = 16;
    glDispatchCompute(
        (m_width + groupSize - 1) / groupSize,
        (m_height + groupSize - 1) / groupSize,
        1
    );
    glMemoryBarrier(GL_SHADER_IMAGE_ACCESS_BARRIER_BIT);
}
```

#### 8× SSAA Export
**File:** `flutter-fractal-forge/opensource/repos/renderers/FractaVista/src/fractal/FractalComputer.cpp` (lines 126-224)

```cpp
void FractalComputer::saveScreenshot(const ScreenshotRequest& request, const FractalState& state) {
    // Supersample: multiply resolution by request.supersample
    const int ssWidth = state.renderWidth * request.supersample;   // e.g., 1280 * 8
    const int ssHeight = state.renderHeight * request.supersample;

    Texture ssTexture(ssWidth, ssHeight);
    Shader& shader = getOrCreateShader(state.type);

    // Compute at 8× resolution
    shader.use();
    updatePaletteUBO(state.coloring);
    ssTexture.bindImage(0);

    shader.setVec2("fullResolution", glm::dvec2{ssWidth, ssHeight});
    // ... set other uniforms

    glDispatchCompute((ssWidth + 15) / 16, (ssHeight + 15) / 16, 1);
    glMemoryBarrier(GL_SHADER_IMAGE_ACCESS_BARRIER_BIT);

    // Read back pixels
    std::vector<unsigned char> buffer(ssWidth * ssHeight * 4);
    ssTexture.bind();
    glGetTexImage(GL_TEXTURE_2D, 0, GL_RGBA, GL_UNSIGNED_BYTE, buffer.data());

    // Vertical flip (OpenGL y-axis inversion)
    const int rowPitch = ssWidth * 4;
    for (int y = 0; y < ssHeight / 2; ++y) {
        std::span<uint8_t> bufferSpan(buffer.data(), buffer.size());
        auto row1 = bufferSpan.subspan(y * rowPitch, rowPitch);
        auto row2 = bufferSpan.subspan((ssHeight - 1 - y) * rowPitch, rowPitch);
        std::swap_ranges(row1.begin(), row1.end(), row2.begin());
    }

    // Export via SDL_image
    SDL_Surface* surface = SDL_CreateSurfaceFrom(
        ssWidth, ssHeight, SDL_PIXELFORMAT_ABGR8888, buffer.data(), rowPitch
    );

    switch (request.format) {
        case ScreenshotFormat::PNG:
            IMG_SavePNG(surface, pathStr.c_str());
            break;
        case ScreenshotFormat::JPG:
            SDL_Surface* rgbSurface = SDL_ConvertSurface(surface, SDL_PIXELFORMAT_RGB24);
            IMG_SaveJPG(rgbSurface, pathStr.c_str(), 95);
            SDL_DestroySurface(rgbSurface);
            break;
    }
    SDL_DestroySurface(surface);
}
```

**Key Points:**
- Dispatch on 16×16 workgroups
- Supersample by integer multiplier (2×, 4×, 8×)
- Read back via `glGetTexImage()` with ABGR8888 format
- Flip y-axis (OpenGL convention)
- SDL_image exports to PNG/JPG

### Shader Compilation
**File:** `flutter-fractal-forge/opensource/repos/renderers/FractaVista/src/gfx/Shader.cpp` (lines 39-77)

```cpp
void Shader::compileFromPath(const std::filesystem::path& computePath,
                             const std::vector<std::string>& defines) {
    auto optionalComputeCode = FileUtils::loadShaderSource(computePath);
    std::string computeCode = *optionalComputeCode;

    // Inject #define directives after #version
    size_t versionPos = computeCode.find("#version");
    size_t lineEnd = computeCode.find('\n', versionPos);

    std::string defineBlock;
    for (const auto& def : defines) {
        defineBlock += std::format("#define {}\n", def);
    }
    computeCode.insert(lineEnd + 1, defineBlock);

    // Compile GL_COMPUTE_SHADER
    const char* computeCodeCStr = computeCode.c_str();
    GLuint computeShader = glCreateShader(GL_COMPUTE_SHADER);
    glShaderSource(computeShader, 1, &computeCodeCStr, nullptr);
    glCompileShader(computeShader);
    checkCompileErrors(computeShader, "COMPUTE");

    // Link program
    m_programID = glCreateProgram();
    glAttachShader(m_programID, computeShader);
    glLinkProgram(m_programID);
    checkCompileErrors(m_programID, "PROGRAM");

    glDeleteShader(computeShader);
}
```

**Usage Example:**
```cpp
auto shader = std::make_unique<Shader>();
auto shaderPath = FileUtils::getAbsolutePath("assets/shaders/MainShader.glsl");
shader->compileFromPath(shaderPath, { "FRACTAL_MANDELBROT" });
shader->use();
shader->bindUBO("Palette", 0);
```

### Preset Format (JSON)
**File:** `flutter-fractal-forge/opensource/repos/renderers/FractaVista/src/app/Application.cpp` (lines 35-60)

```cpp
// Save preset
m_uiManager->onSavePreset = [this]() {
    auto path = PlatformUtils::SaveFileDialog(m_window.get(), "Save Preset", "preset.fracta",
        { { .name = "FractaVista Preset", .spec = "fracta" } });

    if (path) {
        std::ofstream file(*path);
        json j = m_fractalState;  // nlohmann/json serialization
        file << j.dump(4);
        FRACTAL_INFO("Preset saved to {}", *path);
    }
};

// Load preset
m_uiManager->onLoadPreset = [this]() {
    auto path = PlatformUtils::OpenFileDialog(m_window.get(), "Load Preset", "",
        { { .name = "FractaVista Preset", .spec = "fracta" } });

    if (path && std::filesystem::exists(*path)) {
        std::ifstream file(*path);
        json j = json::parse(file);
        m_fractalState = j;  // nlohmann/json deserialization
        m_fractalState.needsUpdate = true;
    }
};
```

**Implied JSON Schema (from FractalState):**
```json
{
  "type": "Mandelbrot",
  "renderWidth": 1280,
  "renderHeight": 720,
  "offset": [0.0, 0.0],
  "zoom": 1.0,
  "maxIterations": 256,
  "coloring": {
    "useSmoothing": true,
    "paletteFrequency": 0.01,
    "palette": [
      { "color": [0.55, 0.75, 0.95], "position": 0.0 },
      { "color": [1.0, 1.0, 1.0], "position": 1.0 }
    ]
  },
  "specificParams": {
    "juliaConstant": [-0.8, 0.156]
  }
}
```

**File Extension:** `.fracta`

---

## PROJECT 3: Fractl (Rust)

### File Locations
- **Root:** `flutter-fractal-forge/opensource/repos/renderers/Fractl/`
- **Library:** `flutter-fractal-forge/opensource/repos/renderers/Fractl/fractl_lib/src/`
- **Workspace:** `flutter-fractal-forge/opensource/repos/renderers/Fractl/Cargo.toml`

### Feature Flag System

**File:** `flutter-fractal-forge/opensource/repos/renderers/Fractl/fractl_lib/src/lib.rs` (lines 1-48)

```rust
#[cfg(feature = "gpu")]
mod gpu;
mod math;

// Feature constraints
#[cfg(all(feature = "multithread", feature = "gpu"))]
compile_error!("feature \"multithread\" and feature \"gpu\" cannot be enabled at the same time");

#[cfg(not(any(feature = "f32", feature = "f64")))]
compile_error!("feature \"f32\" or feature \"f64\" must be enabled");

#[cfg(all(feature = "f32", feature = "f64"))]
compile_error!("feature \"f32\" and feature \"f64\" cannot be enabled at the same time");

#[cfg(all(feature = "f64", feature = "gpu"))]
compile_error!("feature \"f64\" and feature \"gpu\" cannot be enabled at the same time");

// Precision selection
cfg_if! {
    if #[cfg(feature = "f32")] {
        pub type Float = f32;
    } else if #[cfg(feature = "f64")] {
        pub type Float = f64;
    }
}

pub fn float(n: u32) -> Float {
    cfg_if! {
        if #[cfg(feature = "f32")] {
            n as f32
        } else if #[cfg(feature = "f64")] {
            n as f64
        }
    }
}
```

**Available Features:**
- `f32` / `f64` (mutually exclusive, required)
- `multithread` / `gpu` (mutually exclusive)
- `f64` + `gpu` forbidden (GPU only supports f32)

**Selection Matrix:**
```
┌─────────────┬──────────┬──────────┬──────────┐
│             │ CPU f32  │ CPU f64  │ GPU f32  │
├─────────────┼──────────┼──────────┼──────────┤
│ Precision   │ f32      │ f64      │ f32      │
│ Backend     │ CPU      │ CPU      │ wgpu     │
│ Threading   │ Yes      │ Yes      │ No       │
│ WASM        │ Yes      │ Yes      │ Yes      │
└─────────────┴──────────┴──────────┴──────────┘
```

### GPU Compute Backend (wgpu)

**File:** `flutter-fractal-forge/opensource/repos/renderers/Fractl/fractl_lib/src/gpu.rs` (lines 1-110)

#### Compute Uniform Structure
```rust
#[repr(C)]
#[derive(Copy, Clone, Debug, Default, bytemuck::Pod, bytemuck::Zeroable)]
struct ArgsUniform {
    screen_size: [u32; 2],
    view_size: [f32; 2],
    zoom: [f32; 2],
    center_pos: [f32; 2],
    max_iterations: u32,
    selected_fractal: u32,
    selected_color: u32,
    multi_exponent: f32,
}
```

#### Initialization
```rust
struct WgpuContext {
    device: wgpu::Device,
    queue: wgpu::Queue,
    args_buffer: wgpu::Buffer,
    pipeline: wgpu::ComputePipeline,
    bind_group: wgpu::BindGroup,
    storage_buffer: wgpu::Buffer,
    output_staging_buffer: wgpu::Buffer,
}

async fn new_async() -> Self {
    let instance = wgpu::Instance::default();
    let adapter = instance.request_adapter(&wgpu::RequestAdapterOptions {
        power_preference: wgpu::PowerPreference::HighPerformance,
        compatible_surface: None,
        force_fallback_adapter: false,
    }).await.unwrap();

    let (device, queue) = adapter.request_device(
        &wgpu::DeviceDescriptor {
            label: None,
            features: wgpu::Features::empty(),
            limits: wgpu::Limits::downlevel_defaults(),
        },
        None,
    ).await.unwrap();

    let buffer_len = device.limits().max_compute_workgroups_per_dimension;

    let shader = device.create_shader_module(wgpu::ShaderModuleDescriptor {
        label: None,
        source: wgpu::ShaderSource::Wgsl(std::borrow::Cow::Borrowed(
            include_str!("./shader.wgsl")
        )),
    });

    // ... create buffers and bind groups
}
```

**Key Details:**
- Uses `wgpu` for cross-platform compute (Web, native)
- `downlevel_defaults()` for broad compatibility
- Shader embedded as `shader.wgsl` (see below)
- Chunked processing: splits large buffers into workgroup-sized chunks

#### Compute Dispatch
```rust
async fn gpu_compute_async(&self, local_buffer: &mut [u32]) {
    self.queue.write_buffer(&self.storage_buffer, 0, bytemuck::cast_slice(local_buffer));

    let mut command_encoder = self.device.create_command_encoder(
        &wgpu::CommandEncoderDescriptor { label: None }
    );

    {
        let mut compute_pass = command_encoder.begin_compute_pass(
            &wgpu::ComputePassDescriptor { label: None, timestamp_writes: None }
        );
        compute_pass.set_pipeline(&self.pipeline);
        compute_pass.set_bind_group(0, &self.bind_group, &[]);
        compute_pass.dispatch_workgroups(local_buffer.len() as u32, 1, 1);
    }

    command_encoder.copy_buffer_to_buffer(
        &self.storage_buffer, 0,
        &self.output_staging_buffer, 0,
        self.storage_buffer.size(),
    );

    self.queue.submit(Some(command_encoder.finish()));

    // Read back asynchronously
    let buffer_slice = self.output_staging_buffer.slice(..);
    let (sender, receiver) = flume::bounded(1);
    buffer_slice.map_async(wgpu::MapMode::Read, move |r| sender.send(r).unwrap());

    self.device.poll(wgpu::Maintain::Wait);
    receiver.recv_async().await.unwrap().unwrap();
    {
        let view = buffer_slice.get_mapped_range();
        local_buffer.copy_from_slice(bytemuck::cast_slice(&view));
    }
    self.output_staging_buffer.unmap();
}
```

### Compute Shader (WGSL)

**File:** `flutter-fractal-forge/opensource/repos/renderers/Fractl/fractl_lib/src/shader.wgsl` (lines 1-100)

```wgsl
struct Args {
    screen_size: vec2<u32>,
    view_size: vec2<f32>,
    zoom: vec2<f32>,
    center_pos: vec2<f32>,
    max_iterations: u32,
    selected_fractal: u32,
    selected_color: u32,
    multi_exponent: f32,
}

@group(0) @binding(0)
var<storage, read_write> v_indices: array<u32>;

@group(0) @binding(1)
var<uniform> args: Args;

fn index_to_world_pos(index: u32) -> vec2<f32> {
    let screen_x = index % args.screen_size.x;
    let screen_y = (index - screen_x) / args.screen_size.x;

    let screen_pos_normalized = vec2(
        (f32(screen_x) / f32(args.screen_size.x)) - 0.5,
        (f32(screen_y) / f32(args.screen_size.y)) - 0.5
    );

    return vec2(
        ((screen_pos_normalized.x * args.view_size.x) / args.zoom.x) + args.center_pos.x,
        ((screen_pos_normalized.y * args.view_size.y) / args.zoom.y) + args.center_pos.y,
    );
}

fn mandelbrot_escape_time(world_pos: vec2<f32>) -> u32 {
    var n: u32 = 0u;
    var x: f32 = 0.0;
    var x2: f32 = 0.0;
    var y: f32 = 0.0;
    var y2: f32 = 0.0;

    // Main bulb optimization
    let q = pow(world_pos.x - 0.25, 2.0) + pow(world_pos.y, 2.0);
    let is_in_main_bulb = q * (q + world_pos.x - 0.25) <= 0.25 * pow(world_pos.y, 2.0);

    if is_in_main_bulb {
        return args.max_iterations;
    } else {
        loop {
            if !((x2 + y2 <= 4.0) && (n < args.max_iterations)) {
                break;
            }
            y = 2.0 * x * y + world_pos.y;
            x = x2 - y2 + world_pos.x;
            x2 = pow(x, 2.0);
            y2 = pow(y, 2.0);
            n += 1u;
        }
    }
    return n;
}

fn multibrot_escape_time(world_pos: vec2<f32>) -> u32 {
    var n: u32 = 0u;
    var x: f32 = world_pos.x;
    var y: f32 = world_pos.y;

    loop {
        let x_y_squared = pow(x, 2.0) + pow(y, 2.0);
        if !((x_y_squared <= pow(args.multi_exponent, 2.0)) && (n < args.max_iterations)) {
            break;
        }
        let x_y_squared_exp = pow(x_y_squared, args.multi_exponent / 2.0);
        let exponent_atan = args.multi_exponent * atan2(y, x);
        let x_tmp = x_y_squared_exp * cos(exponent_atan) + world_pos.x;
        y = x_y_squared_exp * sin(exponent_atan) + world_pos.y;
        x = x_tmp;
        n += 1u;
    }
    return n;
}

fn color_histogram(escape_time: u32) -> u32 {
    return color(0u, 0u, u32((f32(escape_time) / f32(args.max_iterations)) * 255.0));
}
```

### Fractal Type Enumeration
**File:** `flutter-fractal-forge/opensource/repos/renderers/Fractl/fractl_lib/src/math.rs` (lines 8-62)

```rust
#[non_exhaustive]
#[derive(Clone, Copy, Debug, Default, PartialEq)]
pub enum FractalType {
    #[default]
    Mandelbrot,
    Multibrot(Float),
}

impl FractalType {
    const NUM_OF_VARIANTS: u8 = 2;
    const DEFAULT_MULTIBROT_ARGUEMENT: Float = 4.0;

    pub const fn id(&self) -> u8 {
        match self {
            Self::Mandelbrot => 0,
            Self::Multibrot(_) => 1,
        }
    }

    pub const fn from_id(id: u8) -> Self {
        match id % Self::NUM_OF_VARIANTS {
            0 => Self::Mandelbrot,
            1 => Self::Multibrot(Self::DEFAULT_MULTIBROT_ARGUEMENT),
            _ => unreachable!(),
        }
    }

    pub const fn next(&self) -> Self {
        Self::from_id(self.id() + 1)
    }

    pub const fn prev(&self) -> Self {
        Self::from_id(self.id() + Self::NUM_OF_VARIANTS - 1)
    }

    pub fn change_multi_parametr(&mut self, by: Float) {
        if let Self::Multibrot(exponent) = self {
            let new_exponent = *exponent + by;
            if new_exponent.is_finite() {
                *self = FractalType::Multibrot(new_exponent);
            }
        }
    }

    pub fn multi_parametr(&self) -> Option<Float> {
        match self {
            Self::Multibrot(exponent) => Some(*exponent),
            _ => None,
        }
    }
}
```

**Escape Time (CPU version, lines 65-115):**
```rust
pub fn escape_time(&self, world_pos: Vector2<Float>, max_iterations: NonZeroU32) -> u32 {
    let mut n = 0;
    let max_iterations = max_iterations.get();

    match self {
        Self::Mandelbrot => {
            let is_in_main_bulb = {
                let q = (world_pos.x - 0.25).powi(2) + world_pos.y.powi(2);
                q * (q + (world_pos.x - 0.25)) <= 0.25 * world_pos.y.powi(2)
            };

            if is_in_main_bulb {
                max_iterations
            } else {
                let (mut x2, mut y2, mut x, mut y) = (0.0, 0.0, 0.0, 0.0);

                while (x2 + y2 <= 4.0) && (n < max_iterations) {
                    y = 2.0 * x * y + world_pos.y;
                    x = x2 - y2 + world_pos.x;
                    x2 = x.powi(2);
                    y2 = y.powi(2);
                    n += 1;
                }
                n
            }
        }
        Self::Multibrot(exponent) => {
            let (mut x, mut y) = (world_pos.x, world_pos.y);

            while ((x.powi(2) + y.powi(2)) <= exponent.powi(2)) && (n < max_iterations) {
                let x_y_squared_exp = (x.powi(2) + y.powi(2)).powf(exponent / 2.0);
                let exponent_atan = exponent * y.atan2(x);
                let x_tmp = x_y_squared_exp * (exponent_atan).cos() + world_pos.x;
                y = x_y_squared_exp * (exponent_atan).sin() + world_pos.y;
                x = x_tmp;
                n += 1;
            }
            n
        }
    }
}
```

### Cargo Workspace Configuration

**File:** `flutter-fractal-forge/opensource/repos/renderers/Fractl/Cargo.toml`

```toml
[workspace]
resolver = "2"
members = [
  "fractl_lib",
  "fractl_gui",
]

[workspace.package]
version = "0.1.0"
description = "Fractal renderer supporting multithreading, gpu compute and wasm"
edition = "2021"
authors = ["Shapur <48966182+Shapur1234@users.noreply.github.com>"]
license = "GPL-3.0-or-later"
repository = "https://github.com/Shapur1234/Fractaller"
readme = "README.md"
keywords = ["fractal", "rendering", "gpu", "parallelism", "wasm"]
categories = ["rendering", "mathematics", "graphics", "multimedia::images", "web-programming"]

[workspace.dependencies]
fractl_lib = { path = "fractl_lib", version = "0.1", default-features = false }

[profile.release]
codegen-units = 1
lto = true

[profile.flamegraph]
inherits = "release"
lto = false
debug = true
panic = "abort"
```

---

## PROJECT 4: fractals-generator (C++)

### File Locations
- **Root:** `flutter-fractal-forge/opensource/repos/renderers/fractals-generator/`
- **Source:** `flutter-fractal-forge/opensource/repos/renderers/fractals-generator/src/main.cpp`
- **Examples:** `flutter-fractal-forge/opensource/repos/renderers/fractals-generator/examples/`

### Multi-Precision Rendering Architecture

**File:** `flutter-fractal-forge/opensource/repos/renderers/fractals-generator/src/main.cpp` (lines 1-120)

```cpp
#include <quadmath.h>              // GCC __float128
#ifdef __GNUC__
typedef __float128 LongReal;
#else
typedef long double LongReal;
#endif

// Render mode enum: selects precision and shader
enum RENDER_MODES {
    FLOAT,                         // Single precision (f32)
    DOUBLE,                        // Emulated double (double-single)
    EMULATED_DOUBLE,               // Native double (f64)
    EMULATED_QUADRUPLE,            // Emulated quad (quad-single)
    FP128,                          // Fixed-point 128-bit reals
    NONE,                           // Placeholder
    DUAL,                           // f32 vs f64 comparison
    DUAL_F128,                      // f64 vs f128 comparison
};

// Global state
LongReal d_zoom = 1.f / 256.f;
LongReal cx = 0.0;                // Complex plane center X
LongReal cy = 0.0;                // Complex plane center Y
double w, h;                       // Render window dimensions
int render_mode = EMULATED_DOUBLE;
int iterations = 100;
std::array<float, 2> c = {0, 0};  // Julia constant
bool smooth = false;               // Smooth coloring
```

**Precision Selection:**
```cpp
void selectAndLoadShader() {
    switch (render_mode) {
        case FLOAT:
            loadShader("./shaders/fractal_f64_em.frag");      // Emulated f64 in f32
            break;
        case DOUBLE:
            loadShader("./shaders/fractal_f64.frag");         // Native f64
            break;
        case EMULATED_DOUBLE:
            loadShader("./shaders/fractal_f64_em.frag");
            break;
        case EMULATED_QUADRUPLE:
            loadShader("./shaders/fractal_f128.frag");        // Emulated f128
            break;
        case FP128:
            loadShader("./shaders/fractal_fp128.frag");       // Fixed-point f128
            break;
        // ... DUAL modes
    }
}
```

### Fractal Type System
```cpp
int type = 0;  // Selected fractal type

// Implied fractal types (from context):
// 0: Mandelbrot
// 1: Julia
// 2: Burning Ship
// 3: Newton fractal
// (others possibly: tricorn, cubic mandelbrot, etc)
```

### Coloring Methods
```cpp
int color = 1;  // Selected coloring algorithm

// Implied coloring types:
// 1: Smooth coloring (with normalized iteration count)
// 2: Histogram coloring
// 3: Distance estimation
// (others: palette, domain coloring, etc)
```

### Screenshot System
```cpp
void take_screenshot() {
    size_t cur;
    sf::Image sf_image;
    sf_image.create(w, h);
    glReadPixels(0, 0, w, h, GL_RGB, GL_UNSIGNED_BYTE, pixels);

    for (unsigned int i = 0; i < (unsigned int) w; i++) {
        for (unsigned int j = 0; j < (unsigned int) h; j++) {
            cur = (((unsigned int) h - j - 1) * (unsigned int) w + i) * 3;
            sf::Color color(pixels[cur], pixels[cur + 1], pixels[cur + 2]);
            sf_image.setPixel(i, j, color);
        }
    }

    sf_image.saveToFile("screen_" + std::to_string(nb_screenshots++) + ".png");
}
```

**Process:**
1. Read pixels with `glReadPixels()` (RGB)
2. Flip y-axis (SFML convention)
3. Save via SFML Image API

### Shader Organization

**File Structure:**
```
shaders/
├── fractal.vert              # Vertex shader (quad rendering)
├── fractal_f64.frag          # Native f64 fragment shader
├── fractal_f64_em.frag       # Emulated f64 in f32
├── fractal_f128.frag         # Emulated f128
├── fractal_fp128.frag        # Fixed-point f128
├── fractal_julia.frag        # Julia variant
└── ... (others)
```

**Shader Loading:**
```cpp
void loadShader(const std::string &filename) {
    sf::Shader::bind(nullptr);

    auto load = [](const std::string &path) {
        std::ifstream file(path);
        std::stringstream buf;
        buf << file.rdbuf();
        return buf.str();
    };

    std::string vert = load("./shaders/fractal.vert");
    std::string frag = load(filename);

    if (!shader.loadFromMemory(vert, frag)) {
        std::cout << "Shader load failed!" << std::endl;
    }
}
```

---

## COMPARATIVE ANALYSIS

### Precision Approaches

| Project | Approach | Range | Accuracy | Use Case |
|---------|----------|-------|----------|----------|
| **DeepDrill** | Triple-tier: Standard (f64) → Extended (double-double) → GMP (arbitrary) | Unlimited | 106+ bits (extended) | Ultra-deep reference points |
| **FractaVista** | Single f64 compute shader + UBO palette | ±10^308 | ~15 digits | Real-time interactive rendering |
| **Fractl** | Selectable f32/f64 (CPU) or f32 (GPU wgpu) | f32: ±10^38; f64: ±10^308 | 7-15 digits | Cross-platform (WASM) |
| **fractals-generator** | Selectable: f32/f64/f128 via shader switching | f32-f128 | 7-34 digits | Precision comparison rendering |

### GPU Backend Comparison

| Project | API | Dispatch | Colorization | Export |
|---------|-----|----------|--------------|--------|
| **DeepDrill** | SFML/OpenGL | CPU pre-compute | Post-process shaders (gradient.glsl) | FFmpeg video |
| **FractaVista** | OpenGL 4.5 (compute) | 16×16 workgroups | Compute shader + UBO palette | PNG/JPG via SDL_image |
| **Fractl** | wgpu (WebGPU) | 1D workgroups | CPU histogram coloring | Memory buffer |
| **fractals-generator** | SFML/OpenGL | Vertex/fragment | Fragment shader per precision tier | PNG via SFML |

### Fractal Types Supported

| Project | Types | Notes |
|---------|-------|-------|
| **DeepDrill** | Mandelbrot (primary) | Perturbation + series approx optimized for Mandelbrot |
| **FractaVista** | Mandelbrot, Julia, BurningShip, CubicMandelbrot, Tricorn, Newton | 6 types; shader defines injected per type |
| **Fractl** | Mandelbrot, Multibrot(exponent) | Parameterized multibrot |
| **fractals-generator** | Mandelbrot, Julia, BurningShip, Newton, Tricorn, Cubic | Multiple types; precision-agnostic |

### Coloring Strategies

| Project | Methods | Key Features |
|---------|---------|--------------|
| **DeepDrill** | Palette gradient, distance estimation, normal mapping, texture overlay | Smooth/classic modes; dynamic palette scaling; lighting |
| **FractaVista** | Palette interpolation, smooth coloring, palette frequency | std140 UBO; color stops with position |
| **Fractl** | Histogram coloring (CPU) | Simple iteration count mapping |
| **fractals-generator** | Smooth coloring, histogram, multiple per precision mode | Depends on fragment shader variant |

---

## IMPLEMENTABLE PATTERNS FOR FLUTTER/GLSL ES 3.0

### 1. Location Specification (From DeepDrill)
```dart
class FractalLocation {
  final double centerX;
  final double centerY;
  final double zoom;
  final int maxIterations;
  final double escapeRadius;

  // Serialize to JSON for preset files
  Map<String, dynamic> toJson() => {
    'centerX': centerX,
    'centerY': centerY,
    'zoom': zoom,
    'maxIterations': maxIterations,
    'escapeRadius': escapeRadius,
  };

  factory FractalLocation.fromJson(Map<String, dynamic> json) => FractalLocation(...);
}
```

### 2. Multi-Stop Palette System (From FractaVista)
```dart
class ColorStop {
  final Color color;
  final double position;  // [0, 1]

  ColorStop({required this.color, required this.position});
}

class Palette {
  final List<ColorStop> stops;
  final double frequency;  // Smoothing factor

  Color interpolate(double t) {
    // Binary search + linear interpolation
    // ...
  }
}
```

### 3. Compute Shader Dispatch (From FractaVista)
**GLSL ES 3.0 → Dart/OpenGL ES:**
```glsl
#version 310 es
precision highp float;

layout(local_size_x = 16, local_size_y = 16) in;
layout(rgba8, binding = 0) uniform image2D resultImage;

uniform vec2 fullResolution;
uniform vec2 offset;
uniform double zoom;
uniform int maxIterations;
uniform bool useSmoothing;

void main() {
    ivec2 pixelCoords = ivec2(gl_GlobalInvocationID.xy);
    if (pixelCoords.x >= int(fullResolution.x) ||
        pixelCoords.y >= int(fullResolution.y)) return;

    // Compute mandelbrot iteration count
    vec4 result = computeFractal(pixelCoords, fullResolution, offset, zoom, maxIterations);
    imageStore(resultImage, pixelCoords, result);
}
```

### 4. Multi-Precision Selection (From Fractl)
```rust
// Dart equivalent: feature branches
#if defined(PRECISION_F32)
    precision mediump float;
#elif defined(PRECISION_F64)
    // Emulate f64 in GLSL ES using double-double
#endif
```

### 5. FFmpeg Video Export (From DeepDrill)
```dart
class VideoExporter {
  Future<void> exportVideo({
    required List<String> framePaths,
    required String outputPath,
    required int frameRate,
    required int bitrate,
  }) async {
    final process = await Process.start('ffmpeg', [
      '-framerate', frameRate.toString(),
      '-i', 'frame_%04d.png',
      '-c:v', 'libx264',
      '-b:v', '${bitrate}k',
      outputPath,
    ]);

    await process.exitCode;
  }
}
```

### 6. Preset Serialization (From FractaVista)
```dart
class FractalPreset {
  final FractalLocation location;
  final Palette palette;
  final int fractalType;
  final Map<String, dynamic> parameters;

  String toJson() => jsonEncode({
    'location': location.toJson(),
    'palette': palette.toJson(),
    'fractalType': fractalType,
    'parameters': parameters,
  });

  static FractalPreset fromJson(String json) => ...;

  Future<void> saveToFile(String path) async {
    await File(path).writeAsString(toJson());
  }
}
```

### 7. Export with Supersampling (From FractaVista)
```dart
Future<Uint8List> takeScreenshot({
  required int supersample,  // 2, 4, or 8
  required int width,
  required int height,
}) async {
  final ssWidth = width * supersample;
  final ssHeight = height * supersample;

  // Dispatch compute shader at ss resolution
  // Read back pixels
  // Downsample via averaging

  return downsampled;
}
```

---

## CRITICAL IMPLEMENTATION DETAILS

### Main Bulb Detection (Optimization)
**All projects use this:**
```glsl
float q = (x - 0.25)^2 + y^2
if (q * (q + (x - 0.25)) <= 0.25 * y^2)
    return maxIterations  // In main bulb: always in set
```

### Normalized Iteration Count (Smooth Coloring)
**DeepDrill & FractaVista:**
```glsl
float nic = float(iterations) + 1.0 - log(log(norm)) / log(2.0)
// nic ∈ [0, maxIterations] with fractional part
```

### Channel Decoding (DeepDrill shaders)
```glsl
float decode_float(vec4 v) {
    vec4 bits = v * 255.0;
    float sign = (bits.w < 128.0) ? 1.0 : -1.0;
    float expo = floor(mod(bits.w, 128.0)) * 2.0 +
                 floor(bits.z / 128.0) - 127.0;
    float mantissa = bits.x + bits.y * 256.0 +
                     mod(bits.z, 128.0) * 65536.0;
    return sign * (1.0 + mantissa / 8388607.0) * pow(2.0, expo);
}
```

---

## SUMMARY TABLE: File Paths for Reference

| Project | File | Purpose |
|---------|------|---------|
| DeepDrill | `src/config.h` | Version, format constants |
| DeepDrill | `src/shared/Options.h` | Complete global config structure |
| DeepDrill | `src/shared/DrillMap.h` | Multi-channel result storage |
| DeepDrill | `src/math/StandardComplex.h` | f64 complex arithmetic |
| DeepDrill | `src/math/ExtendedDouble.h` | Double-double numbers |
| DeepDrill | `src/math/ExtendedComplex.h` | 106-bit precision complex |
| DeepDrill | `src/ddrill/Driller.h` | Perturbation algorithm |
| DeepDrill | `src/ddrill/ReferencePoint.h` | Reference orbit structure |
| DeepDrill | `src/dmake/DeepMake.h` | Video generation pipeline |
| DeepDrill | `src/dzoom/FFmpeg.h` | FFmpeg integration |
| DeepDrill | `shaders/colorizers/gradient.glsl` | Main GPU colorization |
| FractaVista | `src/fractal/FractalTypes.hpp` | Type definitions (6 fractals) |
| FractaVista | `src/fractal/FractalDefinition.hpp` | Shader define registry |
| FractaVista | `src/fractal/FractalComputer.cpp` | Compute shader dispatch + SSAA export |
| FractaVista | `src/gfx/Shader.cpp` | Shader compilation with defines |
| FractaVista | `src/app/Application.cpp` | Preset I/O (JSON) |
| Fractl | `Cargo.toml` | Feature matrix (f32/f64 + CPU/GPU) |
| Fractl | `fractl_lib/src/lib.rs` | Feature flag system + constraints |
| Fractl | `fractl_lib/src/gpu.rs` | wgpu compute context |
| Fractl | `fractl_lib/src/math.rs` | Fractal type + escape time |
| Fractl | `fractl_lib/src/shader.wgsl` | WGSL compute shader |
| fractals-generator | `src/main.cpp` | Precision selection + rendering |

---

## ACTIONABLE TAKEAWAYS

1. **Precision Strategy:** Implement three-tier system: f32 (interactive), f64 (standard), extended (reference)
2. **GPU Architecture:** Use compute shaders with 16×16 workgroups; support 4×-8× supersampling
3. **Colorization:** Multi-channel textures enable flexible post-processing
4. **Export:** FFmpeg pipe integration for video; PNG/JPG for stills via image libraries
5. **Presets:** JSON serialization of location + palette + parameters
6. **Feature Flags:** Cargo-style compile-time selection of precision tiers
7. **Palette:** Interpolation with smoothing frequency parameter
8. **Optimization:** Main bulb + cardioid detection; series approximation for deep zooms
9. **Portability:** wgpu provides WASM + native; SFML/SDL3 cross-platform windowing
10. **Coloring:** Smooth iteration count normalization via logarithmic formula
