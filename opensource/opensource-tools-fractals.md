# Open-Source Fractal Tools — Reference Document

Analysis of eight open-source projects for applicability to Flutter Fractal Forge (GPU shader-based
interactive fractal explorer). Each section extracts concrete algorithms, formulas, parameter ranges,
and GPU patterns that can be directly ported or adapted.

---

## Table of Contents

1. [glChAoS.P — Strange Attractors & Particle Systems](#1-glchaos-p)
2. [Mandelbulber2 — 3D Fractal Ray-Marcher](#2-mandelbulber2)
3. [Psychtoolbox-3 — GPU Procedural Rendering & Color Science](#3-psychtoolbox-3)
4. [FractalExplorer — Multi-Type 2D Fractal Viewer (C++/raylib)](#4-fractalexplorer)
5. [Fractals-Explorer — WebGL + OpenGL Multi-Backend Explorer](#5-fractals-explorer)
6. [FractalShark — Deep-Zoom with Perturbation Theory (CUDA)](#6-fractalshark)
7. [giulia — Interactive Julia/Mandelbrot GPU Renderer](#7-giulia)
8. [shader-fractals — GLSL Shader Library (2D + 3D)](#8-shader-fractals)
9. [Cross-Project Synthesis & Implementation Roadmap](#9-synthesis)

---

## 1. glChAoS.P

**Repo**: `opensource/glChAoS.P`
**Language**: C++ / OpenGL 4.1 / GLSL
**Purpose**: Real-time visualization of chaotic dynamical systems (strange attractors) as particle
clouds. Up to 265 million particles at 60 fps. Also ships a WebGL2/WASM port (wglChAoS.P).

### 1.1 Strange Attractor Formulas

36 ODE-based strange attractors implemented in `src/src/attractorsDiffEq.cpp`. Integration method
is Euler with fixed step `dt` (configurable per attractor, typically 0.001–0.1):

```
vp = v + dtStepInc * dvdt(v)
```

#### Lorenz System
```
dx/dt = σ(y − x)        σ = 10.0
dy/dt = x(ρ − z) − y   ρ = 28.0  (chaos onset ≈ 24.7)
dz/dt = xy − βz         β = 8/3
Initial: (1, 1, 1), dt = 0.01
```

#### Aizawa Attractor  (`kData = [0.95, 0.7, 0.6, 3.5, 0.25, 0.1]`)
```
x' = (z − b)*x − d*y
y' = (z − b)*y + d*x
xQ = x*x
z' = c + a*z − z³/3 − (xQ + y²)*(1 + e*z) + f*z*xQ*x
```

#### FourWing
```
x' = a*x − b*y*z
y' = x*z − c*y
z' = e*x − d*z + x*y
Typical: a≈10, b≈40, c≈11, d≈40, e≈1
```

#### MultiChuaII (piecewise-linear feedback)
```
f(x) = k7*x + 0.5 * Σ_{i=1}^{5} (k_{2+i−1} − k_{2+i}) * (|x + k_{7+i}| − |x − k_{7+i}|)
x' = k0*(y − f(x))
y' = x − y + z
z' = −k1*y
```

#### Other Implemented Attractors
Rossler, Thomas, Halvorsen, Arneodo, Bouali, Coullet, Dadras, ChenLee, DequanLi, GenesioTesi,
GloboToroid, Hadley, LiuChen, NewtonLeipnik, NoseHoover, QiChen, RayleighBenard, Robinson,
Rucklidge, Sakarya, ShimizuMorioka, SprottLinzB/F, Tamari, TSUCS, WangSunCang, YuWang, ZhouChen.

All ship with pre-tuned `.sca` JSON configs in `ChaoticAttractors/`.

### 1.2 Polynomial Attractors

`src/src/attractorsPolynomial.h` — dynamically-generated polynomial systems:

```
Degree n → (n+1)(n+2)(n+3)/6 coefficients
Degree 2  → 10 coefficients
Degree 3  → 20 coefficients
Parameter range: kMin = −1.25, kMax = 1.25
Evaluation: Σ coeff[i] * xⁱ * yʲ * zᵏ  (i+j+k ≤ n)
```

### 1.3 IFS Variation Functions (`src/src/IFS.h`)

| Variation | Formula |
|-----------|---------|
| Linear    | identity |
| Swirl2D   | `(r·cos(θ+r), r·sin(θ+r))` |
| Swirl4D   | 4D version; θ₁=atan2(y,x), θ₂=atan2(w,z) |
| Spherical | `v / |v|²` (inversion) |
| Polar3D   | `(r, atan2(y,x), acos(z/r))` |

### 1.4 Hypercomplex Fractals via IIM (`attractorsFractalsIIM.h`)

Inverse Iterations Method on degree-n hypercomplex polynomials. IFS transforms applied to both
points and parameters. Max depth 50 iterations; random parameter variation discovers new patterns.

### 1.5 Particle System Architecture

**Transform Feedback pipeline** (`partSystem.cpp`):
- Vertex shader computes next attractor position; result written back to VBO via TFBO
- Circular buffer: fixed allocation (10–100 M particles), ring-overwrite for continuous stream
- Two backends: static single-pass or Transform Feedback (GPU-side stepping)
- Main thread renders; aux thread computes positions (mutex-protected)

### 1.6 Shader Techniques

#### Rendering Modes (`ParticlesFrag.glsl`)
```glsl
#define idxBLENDING 0    // Additive alpha blending
#define idxSOLID    1    // Phong direct lighting
#define idxSOLID_AO 2    // Solid + SSAO
#define idxSOLID_DR 3    // Direct render
```

#### Light Models (`lightModelsFrag.glsl`, 518 lines)
```glsl
// Phong
specular = pow(max(dot(V, R), 0.0), shininess)  // R = reflect(-L, N)

// Blinn-Phong
H = normalize(V + L)
specular = pow(max(dot(H, N), 0.0), shininess)

// GGX (Cook-Torrance PBR)
// Full Fresnel / distribution / geometry functions included
```

#### SSAO (`ambientOcclusionFrag.glsl`, 202 lines)
- 9-tap Catmull-Rom bicubic reconstruction for smooth AO gradients
- Bilateral filtering preserves silhouettes

#### Post-Processing (`filtersFrag.glsl`, 484 lines)
- Separable Gaussian blur: O(2σ) taps vs O(σ²) — horizontal pass then vertical pass
- Bilateral denoise: edge-aware with `sigmaRange` color threshold
- FXAA: luminance-edge detection + adaptive blur (~2% GPU cost vs 25% for 4×MSAA)

#### Color Correction (`postRenderingFrag.glsl`, 434 lines)
```glsl
// Order of operations:
col = contrast * (col - 0.5) + 0.5 + brightness;
col = exposure * pow(col, 1.0 / gamma);   // default gamma = 2.3
// Tone mapping: Reinhard or ACES
```

#### Poisson Disk Shadow Sampling
16-tap pattern for soft shadows (from `postRenderingFrag.glsl`):
```glsl
vec2 poissonDisk[16] = vec2[](
    vec2(-0.94201624, -0.39906216),
    vec2( 0.94558609, -0.76890725),
    // ... 14 more
);
float shadow = 0.0;
for (int i = 0; i < 16; i++)
    shadow += shadowTest(uv + poissonDisk[i] * shadowRadius);
shadow /= 16.0;
```

#### Distance-Based Alpha Attenuation
```glsl
float alphaAtten = exp(-0.1 * sign(d) * pow(abs(d + 1.0) + 1.0, alphaDistAtten * 0.1));
float alpha = clamp(originalAlpha * alphaAtten * alphaK, 0.0, 1.0);
```

#### Velocity-Based Coloring
```glsl
float mag = clamp(velocity_magnitude, 0.0, 1.0);
vec3 color = (palette_lookup(mag)) * colIntensity;
```

### 1.7 Color Palettes (`palettes.cpp`)

30+ scientifically-designed 256-entry RGB LUTs: Magma, Viridis, Inferno, Plasma (matplotlib),
plus custom Aya Sofia, etc.

Config fields (from `.sca` JSON):
```json
"PalInvert": true,   "PalClamp": false,
"PalOffset": 0.0,    "PalRange": 1.0,
"PalH": 0.0,         "PalS": 0.0,   "PalL": 0.0,
"ColorVel": 150.0
```

### 1.8 3D DLA (`attractorsDLA3D.h`)

Random walkers that aggregate on contact with existing structure. nanoflann KD-tree for O(log n)
nearest-neighbor queries. Xorshiro128p PRNG. PLY import/export.

### 1.9 Applicability Summary

| Technique | Priority | Notes |
|-----------|----------|-------|
| ODE attractor formulas (Lorenz, Aizawa, …) | High | Adapt step to GLSL fragment shader |
| Velocity-based palette lookup | High | 1D texture sampler, continuous coloring |
| Separable Gaussian blur (glow) | High | 2-pass, O(2σ) |
| Bilateral filtering | Medium | Edge-aware smoothing at boundaries |
| Poisson disk shadow sampling | Medium | 16-tap soft shadows |
| IFS variation functions | Medium | swirl2D, spherical, polar3D |
| FXAA anti-aliasing | Medium | Single-pass, cheap |
| Tone mapping (ACES/Reinhard) | Medium | After color correction |
| SSAO | Low | Expensive on mobile |
| DLA3D | Low | CPU-only practical |

---

## 2. Mandelbulber2

**Repo**: `opensource/mandelbulber2`
**Language**: C++/Qt5 + OpenCL
**Purpose**: Professional 3D fractal renderer with 460+ formulas, ray-marching, physically-based
shading, and distributed rendering. OpenCL kernels exist for every C++ formula.

### 2.1 Ray-Marching Core Loop

From `mandelbulber2/opencl/engines/ray_recursion.cl`:

```glsl
float scan = 0.0;
for (int count = 0; count < MAX_STEPS && scan < maxScan; count++) {
    vec3 pos = rayOrigin + rayDir * scan;
    float dist = DistanceField(pos);          // fractal DE
    if (dist < detailSize) {                  // surface found
        BinarySearchRefinement(pos, rayDir);  // bisect for precise hit
        break;
    }
    scan += dist * searchAccuracy;            // sphere tracing step
}
```

**Key parameters**:
- `detailSize`: convergence threshold (1e-6 – 1e-8 typical)
- `searchAccuracy`: step multiplier (0.8–1.0; < 1 for safety on thin features)
- `maxScan`: max march distance (scene-dependent)
- `MAX_STEPS`: 32–512 (higher = more detail, slower)

### 2.2 Distance Estimator Types

#### Type 1: Analytic Logarithmic DE (power fractals)

Used by: Mandelbulb, all power-n variants.

```glsl
// Per iteration:
DE = pow(r, power - 1.0) * DE * power + 1.0;

// After escape:
float finalDE = 0.5 * log(r) * r / DE;
```

#### Type 2: Analytic Linear DE (IFS/folding fractals)

Used by: Mandelbox, Sierpinski, Menger.

```glsl
// Per fold / scale operation:
DE = DE * fabs(scale) + 1.0;

// Final distance:
float finalDE = (r - 2.0) / DE;
```

#### Type 3: Numerical Delta DE (arbitrary transforms)

```glsl
float delta = max(length(point) * 1e-6, detailSize * 0.1);
float r0 = FractalIterate(point);
float r1 = FractalIterate(point + vec3(delta, 0, 0));
// ≈ gradient magnitude → distance
float dist = delta * r0 / abs(r1 - r0);
```

Slower but handles any transformation.

### 2.3 Fractal Formulas — Exact Implementations

#### Mandelbulb (power 8) — from `fractal_mandelbulb.cpp`

```glsl
vec3 mandelbulbStep(vec3 z, vec3 c, float power, inout float DE) {
    float r = length(z);
    float theta = asin(z.z / r);      // elevation
    float phi   = atan(z.y, z.x);    // azimuth

    float rp = pow(r, power - 1.0);
    DE = rp * DE * power + 1.0;
    rp *= r;

    z.x = cos(theta * power) * cos(phi * power) * rp;
    z.y = cos(theta * power) * sin(phi * power) * rp;
    z.z = sin(theta * power) * rp;
    return z + c;
}
// Bailout: r > 10.0
// Default power: 8
```

#### Quaternion (power 2) — from `fractal_quaternion.cpp`

3D simplification of quaternion algebra (w component set to 0):
```glsl
vec3 quaternionStep(vec3 z, vec3 c, inout float DE) {
    DE = 2.0 * length(z) * DE;
    return vec3(
        z.x*z.x - z.y*z.y - z.z*z.z,
        2.0 * z.x * z.y,
        2.0 * z.x * z.z
    ) + c;
}
// Bailout: length(z) > 10.0
```

#### Mandelbox — from `fractal_mandelbox.cpp`

```glsl
vec3 mandelboxStep(vec3 z, vec3 c, inout float DE,
                   float foldLimit, float foldValue,
                   float mR2, float fR2, float scale) {
    // Box fold
    if (z.x >  foldLimit) z.x =  foldValue - z.x;
    if (z.x < -foldLimit) z.x = -foldValue - z.x;
    if (z.y >  foldLimit) z.y =  foldValue - z.y;
    if (z.y < -foldLimit) z.y = -foldValue - z.y;
    if (z.z >  foldLimit) z.z =  foldValue - z.z;
    if (z.z < -foldLimit) z.z = -foldValue - z.z;

    // Spherical fold
    float r2 = dot(z, z);
    if (r2 < mR2) {
        float k = fR2 / mR2;
        z  *= k;
        DE *= k;
    } else if (r2 < fR2) {
        float k = fR2 / r2;
        z  *= k;
        DE *= k;
    }

    z  *= scale;
    DE  = DE * fabs(scale) + 1.0;
    return z + c;
}
// Typical params:
//   foldLimit = 1.0, foldValue = 2.0
//   mR2 = 0.25, fR2 = 4.0
//   scale = 2.5–3.0
// Bailout: length(z) > 100.0
```

#### Sierpinski 3D V2 — IFS tetrahedron

```glsl
// 4 tetrahedron vertices
const vec3 va = vec3( 0.0,       0.0,      1.0/sqrt(3.0));
const vec3 vb = vec3( 0.0,  -2.0/sqrt(3.0), -1.0);
const vec3 vc = vec3(-1.0,   1.0/sqrt(3.0), -1.0);
const vec3 vd = vec3( 1.0,   1.0/sqrt(3.0), -1.0);

vec3 sierpinskiStep(vec3 z, float scale2, inout float DE) {
    // Find nearest vertex
    vec3 nearest = va;
    float minDist = length(z - va);
    // ... compare vb, vc, vd ...

    z = scale2 * (z - nearest) + nearest;
    DE *= scale2;
    return z;
}
// scale2 ≈ 2.0, max iterations = 10–20
```

### 2.4 Coloring Algorithms

From `mandelbulber2/opencl/engines/fractal_coloring.cl`:

#### Smooth Iteration Coloring (continuous, no banding)
```glsl
// After escape at iteration n with |z| = r:
float smooth = float(n) + 1.0 - log(log(r)) / log(power);
float colorIndex = fract(smooth * colorScale);  // 0..1
vec3  color = texture(palette, colorIndex).rgb;
```

#### Additive Multi-Component Color Model
```glsl
float colorValue = 0.0;

// Orbit trap: distance to origin at closest approach
colorValue += minDistToOrigin * orbitTrapWeight;

// Auxiliary color from fold operations (Mandelbox)
colorValue += aux_color * auxWeight;        // incremented per fold

// Iteration radius history
colorValue += radius * radWeight;
colorValue += (radius / DE) * radDivDEWeight;

// Initial condition
colorValue += length(c) * icWeight;

// Lookup in 1D palette LUT
vec3 color = palette_lookup(fract(colorValue));
```

#### Coloring Function by Fractal Type
| Function | Used By | Method |
|----------|---------|--------|
| `coloringFunctionDefault` | Most power fractals | Smooth iteration + orbit trap |
| `coloringFunctionABox` | Mandelbox | Fold event counter |
| `coloringFunctionIFS` | Sierpinski, DarkBeam | Closest vertex distance |

### 2.5 Normal Calculation

```glsl
// Numerical gradient of distance field
vec3 calcNormal(vec3 p, float eps) {
    return normalize(vec3(
        DistanceField(p + vec3(eps, 0.0, 0.0)) - DistanceField(p - vec3(eps, 0.0, 0.0)),
        DistanceField(p + vec3(0.0, eps, 0.0)) - DistanceField(p - vec3(0.0, eps, 0.0)),
        DistanceField(p + vec3(0.0, 0.0, eps)) - DistanceField(p - vec3(0.0, 0.0, eps))
    ));
}
// eps = 0.001 * detailSize  (scale with zoom level)
```

### 2.6 Lighting & Shading

From `shader_light_shading.cl`:

```glsl
// Phong shading (primary model)
float diff = max(dot(N, L), 0.0);
vec3  R    = reflect(-L, N);
float spec = pow(max(dot(V, R), 0.0), shininess);
vec3 color = (ambient + diff * diffuse + spec * specular) * surfaceColor;
```

Light types: Directional, Point (1/r, 1/r², 1/r³ decay options), Conical, Projection.

### 2.7 Advanced Effects

#### Soft Shadows (ray-march to light)
```glsl
float softShadow(vec3 hitPos, vec3 lightDir, float softness) {
    float shadow = 1.0;
    float scan   = detailSize * 2.0;
    for (int i = 0; i < SHADOW_STEPS; i++) {
        float d = DistanceField(hitPos + lightDir * scan);
        shadow = min(shadow, softness * d / scan);
        if (shadow < 0.001) return 0.0;
        scan += d;
    }
    return shadow;
}
```

#### Ambient Occlusion (along surface normal)
```glsl
float ao(vec3 pos, vec3 normal, int samples, float radius) {
    float occlusion = 0.0;
    for (int i = 1; i <= samples; i++) {
        float dist  = float(i) / float(samples) * radius;
        float d     = DistanceField(pos + normal * dist);
        occlusion  += (dist - d) / dist;
    }
    return 1.0 - occlusion / float(samples);
}
```

#### Global Illumination (Monte Carlo)
From `shader_global_illumination.cl`:
```glsl
// Each bounce picks a random hemisphere direction
vec3 randomDirection = normalize(normal + randomVector());
// Trace secondary ray; multiply accumulated color by reflectance
// Typical: 1–4 bounces, 16–64 samples per pixel
```

#### Volumetric Fog
```glsl
float fogOpacity = 1.0 - exp(-fogDensity * marchDistance);
vec3  finalColor = mix(fractalColor, fogColor, fogOpacity);
```

### 2.8 Parameter Ranges for UI Sliders

```
Mandelbulb:
  power:          2 – 16   (default 8)
  maxIterations: 32 – 512  (default 64–128)
  bailout:        8 – 20   (default 10)
  colorScale:   0.01 – 1.0

Mandelbox:
  foldLimit:  0.5 – 1.5  (default 1.0)
  foldValue:  1.5 – 2.5  (default 2.0)
  mR²:        0.1 – 0.5  (default 0.25)
  fR²:        1.0 – 8.0  (default 4.0)
  scale:      2.0 – 4.0  (default 2.5–3.0)

Lighting:
  lightTheta:  0 – 2π
  lightPhi:   −π/2 – π/2
  ambient:     0.0 – 0.5
  specular:    0.0 – 1.0
  shininess:   8 – 256
  aoSamples:   4 – 16
  shadowSoft:  0.0 – 5.0
```

### 2.9 Applicability Summary

| Technique | Priority | Notes |
|-----------|----------|-------|
| Mandelbulb analytic DE | High | Port directly to GLSL |
| Quaternion 3D | High | 3 lines of math |
| Mandelbox box-fold + sphere-fold | High | Full algorithm above |
| Smooth iteration coloring | High | Eliminates banding |
| Orbit trap coloring | High | Adds detail cost-free |
| Normal calculation (gradient) | High | Required for lighting |
| Phong shading | High | Baseline lighting |
| Soft shadows (secondary march) | Medium | Costly but dramatic |
| Ambient occlusion (normal march) | Medium | 4–8 samples sufficient |
| Sierpinski IFS | Medium | Port the 4-vertex step |
| GI Monte Carlo | Low | Too slow on mobile |
| Depth of field | Low | Use blur post-process instead |

---

## 3. Psychtoolbox-3

**Repo**: `opensource/Psychtoolbox-3`
**Language**: MATLAB/Octave + C/C++ + GLSL
**Purpose**: Neuroscience visual-stimulus toolkit — GPU-accelerated procedural generation,
high-precision color science, display calibration, and a complete Mandelbrot demo.

### 3.1 Mandelbrot Shader (Direct Reference)

`Psychtoolbox/PsychDemos/MandelbrotShader.frag.txt` — a minimal, clean Mandelbrot fragment shader:

```glsl
uniform vec2  center;
uniform float zoom;
const   float maxiter = 150.0;

void main() {
    vec2 uv = gl_TexCoord[0].xy;
    float Creal = center.x + (uv.x - 0.5) / zoom;
    float Cimag = center.y + (uv.y - 0.5) / zoom;

    float real = Creal, imag = Cimag, r2 = 0.0, iter = 0.0;

    for (; iter < maxiter && r2 < 4.0; iter++) {
        float tmp = real;
        real = real*real - imag*imag + Creal;
        imag = 2.0*tmp*imag + Cimag;
        r2   = real*real + imag*imag;
    }

    // Anti-banding: fractional iteration via fract()
    float t     = fract(iter * 0.01);
    vec4  color = mix(OuterColor1, OuterColor2, t);
    gl_FragColor = (iter < maxiter) ? InnerColor : color;
}
```

**Key choices**:
- Escape radius: `r2 < 4.0` (equivalent to `|z| < 2`)
- 150 iterations default (adjustable per zoom level)
- `fract(iter * 0.01)` prevents banding — same as smooth iteration mod 1

### 3.2 Smooth Iteration Coloring (Precise Formula)

Full log-log smooth iteration count:
```glsl
// After escape at iteration n with |z|² = r2:
float smoothIter = float(n) + 1.0 - log(log(sqrt(r2))) / log(2.0);
float t = fract(smoothIter * colorScale);
vec3 color = mix(color1, color2, t);
```

### 3.3 Procedural Texture Pattern (Virtual Texture)

The toolkit renders fractals as "virtual textures" — a 1×1 physical GPU texture drives an
infinite-resolution computed image via fragment shader:

```matlab
% MATLAB host
shader       = LoadGLSLProgramFromFiles('MandelbrotShader.frag.txt');
mandelbrottex = Screen('SetOpenGLTexture', win, [], 0,
                       GL.TEXTURE_RECTANGLE_EXT, 1, 1, 1, shader);
```

For Flutter: equivalent to a `FragmentShader` applied to a single-pixel `ImageShader` filling
the viewport — all computation happens per-fragment with no pre-computed texture.

### 3.4 Interactive Pan/Zoom Pattern (`MandelbrotDemo.m`)

```matlab
% Map screen rect to complex plane dynamically
srcRect = CenterRectOnPoint([-0.5 -0.5 0.5 0.5] / zoom, cx, cy);
Screen('DrawTexture', win, mandelbrottex, srcRect, winRect);
```

In GLSL terms: pass `center` and `zoom` as uniforms each frame; derive complex `c` from:
```glsl
vec2 c = center + (fragCoord / resolution - vec2(0.5)) / zoom;
```

### 3.5 Perlin / Simplex Noise Library

`PsychOpenGL/PsychGLSLShaders/ClassicPerlinNoiseLib.frag.txt` (108 lines):

```glsl
// Fade function (smooth step × 3)
vec3 fade(vec3 t) {
    return t*t*t*(t*(t*6.0 - 15.0) + 10.0);
}

// Fast inverse sqrt
vec4 taylorInvSqrt(vec4 r) {
    return 1.79284291400159 - 0.85373472095314 * r;
}
```

Use cases for fractals: noise-based perturbation of Julia parameters, hybrid fractal-noise textures,
dithering to break banding.

### 3.6 Color Science & Gamma Correction

#### sRGB Gamma (from `SRGBGammaCorrect.m`)
```glsl
vec3 linearToSRGB(vec3 col) {
    // Piecewise transfer function (IEC 61966-2-1)
    bvec3 lo = lessThan(col, vec3(0.00304));
    return mix(
        1.055 * pow(col, vec3(1.0/2.4)) - 0.055,   // gamma segment
        12.92 * col,                                  // linear segment
        vec3(lo)
    );
}
```

Apply **after** all color arithmetic. Without this, iteration bands look clipped and unnatural.

#### Color Space Matrices
- RGB → XYZ: 3×3 matrix (`RGBToXYZMatrix.m`)
- XYZ → sRGB primaries (`XYZToSRGBPrimary.m`)
- LMS cone response: `MacBoynToLMS.m`

These are useful for perceptually-uniform palette design — build palettes in XYZ/Lab space, convert
to RGB for the shader.

### 3.7 Anti-Aliasing Techniques (`AntiAliasing.m`)

| Method | Cost | Quality |
|--------|------|---------|
| Hardware FSAA (MSAA) | GPU fixed cost | Good edges |
| Supersampling (SSAA) | N× full render | Best quality |
| FXAA (post-process) | ~2% extra | Good enough |
| Adaptive sampling | Variable | Best efficiency |

For fractals: SSAA 4× then downscale is cleanest. FXAA as fast alternative.

### 3.8 Convolution & Filtering Shaders

- `Convolve2DRectTextureShader.frag.txt` — generic 2D convolution kernel
- `BilinearTextureFilterShader.frag.txt` — smooth texture sampling for zoom
- Gaussian blur shaders — post-process glow / defocus

### 3.9 HDR Support

`GenericLuminanceToRGBA8_FormattingShader.frag.txt` (87 lines): encodes 16-bit luminance into
RGBA8 using LUT texture. Enables >8-bit precision per channel for banding-free gradients.

### 3.10 Shader Parameter Pattern (All Procedural Shaders)

Consistent uniform interface used across 99 shaders:

```glsl
// Vertex shader outputs
varying vec2  texCoord;   // Screen position → complex plane
varying vec4  baseColor;  // Per-object color tint
varying float Angle;      // Rotation

// Fragment shader uniforms
uniform vec4  Offset;               // Global color offset
uniform vec2  validModulationRange; // Clamp range [min, max]
uniform float FreqTwoPi;            // Frequency parameter
```

For fractals, map: `FreqTwoPi` → `zoom`, `Offset` → `center + colorOffset`.

### 3.11 Applicability Summary

| Technique | Priority | Notes |
|-----------|----------|-------|
| Mandelbrot shader (direct) | High | Adapt syntax for GLSL ES 3.0 |
| Smooth iteration (`fract`) | High | Prevents banding, 1 line |
| sRGB gamma correction | High | Essential for correct output |
| Virtual texture pattern | High | Flutter: FragmentShader on viewport |
| Pan/zoom uniform pattern | High | `c = center + (uv - 0.5) / zoom` |
| Perlin noise library | Medium | Perturbation / hybrid effects |
| SSAA supersampling | Medium | Render 2× → downscale |
| FXAA | Medium | Cheap single-pass AA |
| Convolution shaders | Low | Specialized post-effects |
| HDR 16-bit LUT encoding | Low | Only if targeting OLED/HDR displays |

---

## 4. FractalExplorer

**Repo**: `opensource/FractalExplorer`
**Language**: C++ / GLSL 3.30 (desktop) + GLSL 1.00 ES (web via emscripten)
**Framework**: raylib + OpenGL 3.3
**Purpose**: Interactive GPU-accelerated 2D fractal explorer with 10 fractal types. Clean reference
implementation with one shader file per fractal type.

### 4.1 Fractals Implemented

| Fractal | Formula | Key Detail |
|---------|---------|-----------|
| Multibrot | `z^n + c`, z₀=0 | Generalised Mandelbrot; real n (default 2) |
| Multicorn | `conj(z)^n + c` | Conjugate before power → tricorn at n=2 |
| Burning Ship | `(|Re z| + i|Im z|)^n + c` | Abs values before power |
| Julia | `z^n + c_fixed` | z₀ = pixel; c is user-adjustable |
| Newton z³−1 | `z − a·(P(z)/P'(z))` | 3 roots → 3 basins of attraction |
| Newton sin(z) | `z − a·(sin z / cos z)` | Transcendental variant |
| Polynomial deg-2/3 | `P(z) + c` | User-configurable roots |

### 4.2 Complete Complex Number Library (GLSL)

Directly portable to Flutter fragment shaders:

```glsl
// Multiply: (a+bi)(c+di) = (ac−bd) + (ad+bc)i
vec2 ComplexMultiply(vec2 a, vec2 b) {
    return vec2(a.x*b.x - a.y*b.y,
                a.x*b.y + a.y*b.x);
}

// Divide: (a+bi)/(c+di)
vec2 ComplexDivide(vec2 a, vec2 b) {
    float d = b.x*b.x + b.y*b.y;
    return vec2((a.x*b.x + a.y*b.y) / d,
                (a.y*b.x - a.x*b.y) / d);
}

// Power: z^p = r^p · e^(i·p·θ)
vec2 ComplexPow(vec2 z, float power) {
    float r2 = z.x*z.x + z.y*z.y;
    if (r2 == 0.0) return vec2(0.0);
    float mag   = pow(r2, power / 2.0);
    float angle = power * atan(z.y, z.x);
    return vec2(mag * cos(angle), mag * sin(angle));
}

float ComplexAbsSquared(vec2 z) { return z.x*z.x + z.y*z.y; }
vec2  ComplexConjugate(vec2 z)  { return vec2(z.x, -z.y); }
```

**Integer power optimisation** (avoids atan/log for whole-number exponents):
```glsl
if (mod(power, 1.0) == 0.0 && power > 0.0) {
    vec2 newZ = z;
    for (int i = 1; i < int(power); i++)
        newZ = ComplexMultiply(newZ, z);
    z = newZ + c;
}
```

### 4.3 Escape-Time Loop (Multibrot)

```glsl
// Escape radii: 2.0 (banding) or 16.0 (smooth)
float R = colorBanding == 1 ? 2.0 : 16.0;

vec2 c = /* pixel → complex plane */;
vec2 z = vec2(0.0);
int iterations = 0;

while (ComplexAbsSquared(z) <= R*R && iterations < maxIterations) {
    z = ComplexPow(z, power) + c;
    iterations++;
}
```

### 4.4 Smooth Coloring

```glsl
// nu removes banding — continuous iteration count
float nu = log(log(ComplexAbsSquared(z)) / 2.0 / log(2.0)) / log(power);
float colorValue = float(iterations) + 1.0 - nu;
float hue = mod(colorValue * 3.0, 360.0);   // 3× cycles hue faster
finalColor = hsv2rgb(vec3(hue, 1.0, 1.0));
```

### 4.5 HSV → RGB Conversion

```glsl
vec3 hsv2rgb(vec3 c) {
    float h = c.x, s = c.y, v = c.z;
    float ch = s * v;
    float x  = ch * (1.0 - abs(mod(h/60.0, 2.0) - 1.0));
    float m  = v - ch;
    vec3 rgb;
    if      (h < 60.0)  rgb = vec3(ch, x,  0.0);
    else if (h < 120.0) rgb = vec3(x,  ch, 0.0);
    else if (h < 180.0) rgb = vec3(0.0, ch, x);
    else if (h < 240.0) rgb = vec3(0.0, x,  ch);
    else if (h < 300.0) rgb = vec3(x,  0.0, ch);
    else                rgb = vec3(ch, 0.0, x);
    return rgb + vec3(m);
}
```

### 4.6 Newton Fractal (z³ − 1)

```glsl
// Polynomial step: z ← z − a · P(z)/P'(z)
// P(z) = z³ − 1,  P'(z) = 3z²
for (int i = 0; i < maxIterations; i++) {
    vec2 pz  = /* ThirdDegreePolynomial(z) */;
    vec2 dpz = /* ThirdDegreePolynomialDerivative(z) */;
    vec2 rz  = ComplexMultiply(a, ComplexDivide(pz, dpz));
    z -= rz;
    if (abs(rz.x) <= tolerance && abs(rz.y) <= tolerance) {
        // Color by which root z converged to
        for (int k = 0; k < 3; k++) {
            if (distance(z, roots[k]) <= tolerance) {
                finalColor = hsv2rgb(vec3(float(k) * 120.0, 1.0, 1.0));
                return;
            }
        }
    }
}
// Tolerance: ~0.35; Newton a param: (1.0, 0.0) default
```

### 4.7 Newton sin(z)

```glsl
vec2 ComplexSin(vec2 z) {
    return vec2(sin(z.x)*cosh(z.y), cos(z.x)*sinh(z.y));
}
vec2 ComplexCos(vec2 z) {
    return vec2(cos(z.x)*cosh(z.y), -sin(z.x)*sinh(z.y));
}
// Step: z ← z − sin(z)/cos(z)  = z − tan(z)
z -= ComplexDivide(ComplexSin(z), ComplexCos(z));
```

### 4.8 Uniform Reference

| Uniform | Type | Default | Range |
|---------|------|---------|-------|
| `position` | vec2 | center of set | ℝ² |
| `zoom` | float | varies | (0, ∞) |
| `offset` | vec2 | (0,0) | pixel space |
| `maxIterations` | int | 20–300 | 10–1024 |
| `power` | float | 2.0 | 1–10+ |
| `c` | vec2 | varies | ℝ² |
| `colorBanding` | int | 0 | {0, 1} |
| `widthStretch` | float | aspect ratio | ℝ⁺ |

### 4.9 Applicability Summary

| Technique | Priority | Notes |
|-----------|----------|-------|
| Complete complex math library | High | Copy-paste to GLSL ES |
| Smooth iteration (nu formula) | High | Eliminates banding |
| HSV→RGB conversion | High | Same in all projects |
| Newton fractal implementation | High | Convergence coloring pattern |
| sin/cos complex functions | Medium | For transcendental variants |
| Integer power optimisation | Medium | 2–3× faster for z², z³ |

---

## 5. Fractals-Explorer

**Repo**: `opensource/Fractals-Explorer`
**Language**: JavaScript/GLSL ES 3.0 (web) + C++/GLSL (native) + C++/OpenCL
**Purpose**: Multi-backend fractal explorer (WebGL, OpenGL, OpenCL, software CPU). 5 fractal types
with rotation support and 7 Mandelbrot coloring algorithms.

### 5.1 Coordinate Transform (Rotation Included)

```glsl
// Screen pixel → complex plane with rotation
vec2 toCartesian(vec2 pixel) {
    float centerX = (resolution.x / 2.0) - offset.x;
    float centerY = (resolution.y / 2.0) + offset.y;
    return vec2((pixel.x - centerX) / zoom,
               -(pixel.y - centerY) / zoom);
}

vec2 setRotation(vec2 pos, float angle) {
    float s = sin(angle), c = cos(angle);
    return vec2(pos.x*c - pos.y*s,
                pos.x*s + pos.y*c);
}
```

### 5.2 GLSL Macro-Based Complex Arithmetic

```glsl
#define product(a, b) vec2(a.x*b.x - a.y*b.y, a.x*b.y + a.y*b.x)
#define add(a, b)     vec2(a.x + b.x, a.y + b.y)
#define div(a, b)     vec2((a.x*b.x+a.y*b.y)/(b.x*b.x+b.y*b.y), \
                           (a.y*b.x-a.x*b.y)/(b.x*b.x+b.y*b.y))
#define conjugate(z)  vec2(z.x, -z.y)
```

Variable-power loop (GPU-safe with compile-time MAX_POW bound):
```glsl
vec2 comp_powf(vec2 z, int n) {
    vec2 a = z;
    for (int i = 0; i < MAX_POW; i++) {
        if (i >= n - 1) break;
        a = product(a, a);
    }
    return a;
}
```

### 5.3 Seven Mandelbrot Coloring Algorithms

```glsl
float a_2 = z.x*z.x, b_2 = z.y*z.y;
float smooth_ = float(iter) + 1.0 - log(abs(sqrt(a_2 + b_2))) / log(2.0);

// Case 0 (default):
FragColor = vec4(smooth_ * 0.05, value, smooth_ * value, 1.0);

// Case 2 (delta encoding):
float delta = log2(z.x) * value * exp(b_2 / a_2);
FragColor = vec4(delta, value, log(delta / (1.0 - delta*value)), 1.0);

// Case 5 (double-smooth):
float s2 = smooth_ + 1.0 - log(smooth_ * abs(sqrt(a_2+b_2))) / log(2.0);
float s3 = sin(z.x * 3.14159) * log(smooth_ / s2);
FragColor = vec4(sin(s3), sin(smooth_), cos(s2), 1.0);

// Case 6 (cosine palette — most visually appealing):
vec3 val = 0.5 + 0.5*cos(3.0 + smooth_*0.15 + vec3(0.0, 0.6, 1.0));
FragColor = vec4(val * sin(float(iter)), 1.0);
```

**Case 6 is the cleanest portable coloring formula** — the cosine palette trick produces smooth,
naturally-cycling gradients without a texture lookup.

### 5.4 Julia / Tricorn / Burning Ship Coloring

```glsl
float smooth_ = float(iter) + 1.0 - log(abs(sqrt(dot(c0,c0)))) / log(2.0);
FragColor = vec4(
    RGB.x * value * atan(smooth_),   // atan() gives non-linear stretch
    RGB.y * value,
    atan(1.0 / smooth_),
    RGB.z * smooth_
);
```

### 5.5 Newton Fractal (Template-Substituted GLSL)

The host replaces `%%FUNCTION`, `%%DERIVATIVE`, `%%ROOTS` at runtime before GPU compilation:
```glsl
vec2 p(vec2 z)    { return %%FUNCTION;   }   // e.g. z³ − 1
vec2 p_pr(vec2 z) { return %%DERIVATIVE; }   // e.g. 3z²

vec2 newton(vec2 z, vec2 a) {
    return add(z, -mul(div(p(z), p_pr(z)), a));
}
```

### 5.6 Camera / Zoom Pattern (C++)

```cpp
void ZoomIntoPoint(vec2i cursor, float delta) {
    vec2f prevComplex = toCartesian(cursor);
    zoom += delta;
    // Re-center so cursor stays fixed under zoom
    offset = prevComplex - toCartesian(cursor);
}
```

This is the correct zoom-into-cursor algorithm, preserving the invariant that the world point
under the cursor doesn't move.

### 5.7 Applicability Summary

| Technique | Priority | Notes |
|-----------|----------|-------|
| Cosine palette coloring (Case 6) | High | Best formula, no texture needed |
| Rotation matrix in fragment shader | High | `sin/cos` 2×2 rotate |
| Macro-based complex ops | High | Readable, compiler-inlineable |
| `atan()` color stretch | Medium | Non-linear hue stretch |
| Double-smooth iteration (Case 5) | Medium | Expensive but unique |
| Zoom-into-cursor algorithm | High | Required for good UX |
| Template Newton shaders | Low | Shader recompilation needed |

---

## 6. FractalShark

**Repo**: `opensource/FractalShark`
**Language**: C++/CUDA
**Purpose**: Extreme deep-zoom Mandelbrot renderer supporting magnifications up to 10^150,000.
Implements perturbation theory, bilinear approximation (BLA), and linear approximation (LA) to
maintain sub-pixel accuracy without arbitrary-precision arithmetic in the hot loop.

### 6.1 Precision Hierarchy

| Type | Bits | Decimal digits | Zoom range |
|------|------|----------------|-----------|
| float | 32 | ~7 | 1× – 10² |
| double | 64 | ~16 | 1× – 10^15 |
| dblflt (head+tail float) | 64 | ~14 | 10² – 10^30 |
| dbldbl (head+tail double) | 128 | ~31 | 10^15 – 10^60 |
| quad-double | 256 | ~66 | 10^60 – 10^120 |
| GPU NTT (16384 limbs) | ~500K | ~158,000 | 10^120 – 10^150,000 |

### 6.2 Double-Float Arithmetic (GPU-Portable)

The `dblflt` type emulates 64-bit precision from two 32-bit floats. Directly portable to GLSL:

```glsl
// head + tail decomposition
struct dblflt { float head, tail; };

dblflt add_dblflt(dblflt a, dblflt b) {
    float s   = a.head + b.head;
    float err = (a.head - s) + b.head;   // Knuth 2-sum
    return dblflt(s, a.tail + b.tail + err);
}

dblflt mul_dblflt(dblflt a, dblflt b) {
    // Dekker split
    float t   = a.head * b.head;          // exact product (head)
    float err = fma(a.head, b.head, -t);  // rounding residual
    return dblflt(t, err + a.head*b.tail + a.tail*b.head);
}
```

**In GLSL ES**: `fma()` is available in GLSL ES 3.1+; for ES 3.0 approximate with:
`err = a.head*b.head - t;`

### 6.3 Perturbation Theory — Deep Zoom Formula

Core insight: compute one reference orbit Z_n at high precision (CPU), then iterate all pixels as
small perturbations δ around it:

```
δ_{n+1} = 2·Z_ref_n·δ_n + δ_n² + Δc

where:
  Z_ref_n = reference orbit at iteration n  (pre-computed, stored as array)
  δ_n     = per-pixel delta                 (computed in float on GPU)
  Δc      = pixel offset from reference     (small, fits in float)
```

**GPU implementation** (from `Perturb.cuh`):
```glsl
// Per GPU thread:
float dx = delta_x, dy = delta_y;
for (int i = refStart; i < maxIter; i++) {
    float Zx = refOrbit[i].x, Zy = refOrbit[i].y;  // table lookup
    float new_dx = 2.0*(Zx*dx - Zy*dy) + dx*dx - dy*dy + dc_x;
    float new_dy = 2.0*(Zx*dy + Zy*dx) + 2.0*dx*dy       + dc_y;
    dx = new_dx; dy = new_dy;

    // Rebasing: if |δ| > |Z_ref + δ|, restart reference
    if (dx*dx + dy*dy > (Zx+dx)*(Zx+dx) + (Zy+dy)*(Zy+dy)) {
        dx = Zx + dx; dy = Zy + dy; refStart = i;
    }
    if (dx*dx + dy*dy > 4.0) { escape_iter = i; break; }
}
```

This reduces deep-zoom per-pixel work from O(n × precision_cost) to O(n × float_cost).

### 6.4 Bilinear Approximation (BLA)

For periodic regions, a linear map approximates many iterations at once:

```
δ' = A·δ_x − A·δ_y + B·Δc_x − B·Δc_y
   (matrix coefficients A, B pre-computed per LA stage)
```

Stages selected via binary search on bailout radius. Each stage skips O(period) iterations.

### 6.5 Loop Unrolling for Performance

Templates instantiate the iteration kernel with 1/2/4/8/16 inner iterations per escape check:
```cuda
// 4-unrolled inner loop
ITERATE; ITERATE; ITERATE; ITERATE;
if (ESCAPED) { ... }
```
Reduces branch overhead from 1 check/iteration to 1 check/4 iterations.

### 6.6 Smooth Iteration (Same Formula)

```glsl
// Standard log-log smoothing (same as all other projects):
float smooth_iter = float(n) + 1.0 - log2(log2(length(z)));
```

### 6.7 Applicability Summary

| Technique | Priority | Notes |
|-----------|----------|-------|
| Double-float arithmetic (head+tail) | High | Extend zoom to 10^28 in shader |
| Smooth iteration formula | High | Same across all projects |
| Perturbation theory framework | Medium | Needs reference orbit pipeline |
| Rebasing check | Medium | Required for perturbation correctness |
| Loop unrolling template | Low | Micro-opt, less critical in GLSL |
| BLA/LA acceleration | Low | Complex to implement |

**For Flutter**: implement `dblflt` structs in GLSL ES 3.0 to push usable zoom depth from ~10^7
(float) to ~10^14 (dblflt) before hitting precision loss.

---

## 7. giulia

**Repo**: `opensource/giulia`
**Language**: C++ / GLSL 4.0 + OpenCL 1.2
**Framework**: OpenGL 4.0 + ImGui + GLFW
**Purpose**: Interactive Mandelbrot/Julia explorer with dual-precision shaders and 5 color presets.
Ships a single precision and a double precision shader for each fractal.

### 7.1 Fractal Formula

```
z_{n+1} = z_n^exponent + c
Escape when |z| < 4.0  (note: uses 4.0, not 2.0)
Default iterations: 32
```

**Known bug**: the exponent loop runs `exponent − 1` times, so `exponent=3` actually computes z⁴.
Fix: initialise result to `z` and iterate `exponent − 1` multiplications, not `exponent`.

### 7.2 Shader Formulas

#### Magnitude & Product
```glsl
float magnitude(vec2 z) {
    return sqrt(z.x*z.x + z.y*z.y);
}

vec2 product(vec2 a, vec2 b) {
    return vec2(a.x*b.x - a.y*b.y, a.x*b.y + a.y*b.x);
}
```

#### Main Iteration Loop
```glsl
int iter = 0;
while (iter < max_iter && magnitude(z) < 4.0) {
    z = product(z, z) + c;   // z² + c
    iter++;
}
```

#### Coordinate Mapping
```glsl
// Resolution: 1024.0 (hardcoded — adapt to uniform in Flutter)
vec2 uv = (gl_FragCoord.xy - 0.5 * vec2(1024.0)) / 1024.0;
vec2 c  = center + uv * zoom;
```

### 7.3 Five Color Presets

```glsl
// Scheme 0: grayscale
color = vec3(t);

// Scheme 1: blue gradient
color = vec3(0.0, 0.0, t);

// Scheme 2: warm (red-yellow)
color = vec3(t, t*0.5, 0.0);

// Scheme 3: HSV cycling
color = hsv2rgb(vec3(t * 360.0, 1.0, 1.0));

// Scheme 4: cosine bands (most aesthetic)
color = 0.5 + 0.5 * cos(6.28318 * (t + vec3(0.0, 0.33, 0.67)));
```

Scheme 4 is the **cosine palette trick** — same as Fractals-Explorer Case 6. Three-channel cosine
with 120° offsets produces smooth, naturally-balanced gradients without any texture lookup.

### 7.4 HSV → RGB (Compact Form)

```glsl
vec3 hsv2rgb(vec3 c) {
    vec4 K = vec4(1.0, 2.0/3.0, 1.0/3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}
```

This is the most compact portable HSV→RGB — 3 lines, no branching.

### 7.5 Julia Selection Pattern

```glsl
// Mandelbrot mode: c = pixel coordinate, z₀ = 0
// Julia mode:      z₀ = pixel coordinate, c = fixed point
uniform bool juliaMode;
uniform vec2 juliaC;

void main() {
    vec2 z = juliaMode ? uv : vec2(0.0);
    vec2 c = juliaMode ? juliaC : uv;
    // ... iterate
}
```

Mouse-click on Mandelbrot view sets `juliaC`, instantly rendering the corresponding Julia set.
This is the correct dual-mode shader pattern.

### 7.6 Applicability Summary

| Technique | Priority | Notes |
|-----------|----------|-------|
| Escape radius 4.0 vs 2.0 | High | Use 4.0 for smoother smooth-coloring |
| Cosine palette (scheme 4) | High | Best no-texture coloring |
| Compact HSV→RGB (3-line) | High | Use this version |
| Mandelbrot/Julia dual-mode uniform | High | Clean Flutter shader architecture |
| Double precision shader variant | Medium | Separate `.frag` file per precision tier |

---

## 8. shader-fractals

**Repo**: `opensource/shader-fractals`
**Language**: GLSL (Shadertoy-style)
**Purpose**: Library of 11 standalone GLSL shaders — 5 × 2D (escape-time + geometric) and
6 × 3D (ray-marched). Thin C++ host; shaders are the entire product.

### 8.1 Shader Inventory

| File | Type | Technique | Render Cost |
|------|------|-----------|-------------|
| `mandelbrot.glsl` | 2D escape | z² + c, 10,000 iter | Fast |
| `julia.glsl` | 2D escape | z² + c_fixed, 10,000 iter | Fast |
| `sierpinski_triangle.glsl` | 2D IFS | Vertex reflection | Very fast |
| `sierpinski_carpet.glsl` | 2D IFS | Modular grid removal | Fastest |
| `koch_curve.glsl` | 2D IFS | Line reflection | Fast |
| `mandelbulb.glsl` | 3D ray-march | Spherical z^n, DE | Moderate |
| `mandelbox.glsl` | 3D ray-march | Box+sphere fold | Expensive (2500 steps) |
| `menger_sponge.glsl` | 3D ray-march | Cross fold | Moderate |
| `sierpinski_tetrahedron.glsl` | 3D ray-march | Tetrahedral fold | Moderate |
| `menger_broccoli.glsl` | 3D ray-march | Animated Menger | Moderate |
| `menger_mushroom.glsl` | 3D ray-march | Animated Mandelbox | Expensive |

### 8.2 2D Fractals

#### Mandelbrot (10,000 iterations)
```glsl
const int RECURSION_LIMIT = 10000;
vec2 c = /* pixel → complex plane */;
vec2 z = c;  // Mandelbrot: z₀ = c (note: some use z₀ = 0)
for (int i = 0; i < RECURSION_LIMIT; i++) {
    z = vec2(z.x*z.x - z.y*z.y, 2.0*z.x*z.y) + c;
    if (dot(z, z) > 4.0) { escape_iter = i; break; }
}
```
Coloring: `pow(float(i) / float(RECURSION_LIMIT), 1.0 - iTime*0.01)` — animated fade.

#### Julia (Fixed c)
```glsl
// 6 preset c values:
vec2 c_presets[6] = vec2[](
    vec2(-0.8,   0.156),    // Dendritic
    vec2(-0.4,   0.6),      // Spiral
    vec2( 0.285, 0.01),     // Cauliflower
    vec2(-0.70176, -0.3842),// Flame
    vec2(-0.835, -0.2321),  // Rabbit
    vec2( 0.45,  0.1428)    // Nautilus
);
```

#### Sierpinski Triangle (IFS vertex reflection)
```glsl
// 3 vertices at 120° apart
vec2 v0 = vec2(0.0,  1.0);
vec2 v1 = vec2(-0.866, -0.5);
vec2 v2 = vec2( 0.866, -0.5);

for (int i = 0; i < depth; i++) {   // depth: 0–8
    // Reflect toward nearest vertex
    float d0 = distance(z, v0);
    float d1 = distance(z, v1);
    float d2 = distance(z, v2);
    vec2 nearest = (d0 < d1 && d0 < d2) ? v0 :
                   (d1 < d2)             ? v1 : v2;
    z = mix(z, nearest, 0.5);
}
```

#### Sierpinski Carpet (Modular grid)
```glsl
// Check if point is in the removed center thirds
for (int i = 0; i < depth; i++) {   // depth: 0–6
    z = fract(z * 3.0);             // scale up by 3
    // If in the middle third of both x and y → in hole
    if (z.x > 1.0/3.0 && z.x < 2.0/3.0 &&
        z.y > 1.0/3.0 && z.y < 2.0/3.0) {
        fragColor = holeColor;
        return;
    }
}
```

#### Koch Curve (Line reflection)
```glsl
// Each iteration bumps middle third of each segment outward
// Reflection angles: 330° outward, 120° inward
for (int i = 0; i < iterations; i++) {
    vec2 a = ..., b = ...;          // segment endpoints
    vec2 mid = (a + b) * 0.5;
    // Reflect z about segment if within segment strip
    z = reflectAboutLine(z, a, b);
}
```

### 8.3 3D Fractals — Ray-Marching Architecture

All 3D shaders share this structure:

```glsl
// Ray setup
vec3 camPos = vec3(0.0, 0.0, -3.0);
vec3 rayDir = normalize(vec3(uv, 1.0));

// March
float t = 0.0;
for (int i = 0; i < MAX_STEPS; i++) {
    vec3 p   = camPos + rayDir * t;
    float d  = distanceEstimator(p);
    t       += d;
    if (d < EPSILON || t > FAR) break;
}

// Shade hit point
vec3 normal = calcNormal(p);
vec3 color  = hsv2rgb(vec3(t * 0.1, 0.8, 1.0));
```

#### Mandelbulb Distance Estimator
```glsl
float mandelbulbDE(vec3 pos) {
    vec3 z = pos;
    float dr = 1.0, r = 0.0;
    const int ITER = 10;
    float power = 8.0;  // animated: 8.0 + 5.0*sin(iTime)

    for (int i = 0; i < ITER; i++) {
        r = length(z);
        if (r > 2.0) break;

        // Convert to spherical, rotate, scale
        float theta = acos(z.z / r) * power;
        float phi   = atan(z.y, z.x) * power;
        float rp    = pow(r, power);

        // Derivative update
        dr = pow(r, power - 1.0) * power * dr + 1.0;

        // Back to Cartesian
        z = rp * vec3(sin(theta)*cos(phi),
                      sin(phi)*sin(theta),
                      cos(theta)) + pos;
    }
    return 0.5 * log(r) * r / dr;
}
```
Parameters: power=8 (default), animated ±5 range, 250 ray steps, EPSILON=0.001.

#### Mandelbox Distance Estimator
```glsl
float mandelboxDE(vec3 pos) {
    vec3 z  = pos;
    float dr = 1.0;
    float scale = -5.446;    // negative = folded outward

    for (int i = 0; i < 15; i++) {
        // Box fold: clamp each axis to [-1, 1], reflect
        z = clamp(z, -1.0, 1.0) * 2.0 - z;

        // Sphere fold
        float r2 = dot(z, z);
        if      (r2 < 0.25) { z *= 4.0; dr *= 4.0; }   // inner sphere
        else if (r2 < 1.0)  { z /= r2;  dr /= r2; }    // outer sphere

        z  = z * scale + pos;
        dr = dr * abs(scale) + 1.0;
    }
    return length(z) / abs(dr);
}
// 2500 ray steps — very expensive; reduce to 200–300 for mobile
```

#### Menger Sponge Distance Estimator
```glsl
float mengerDE(vec3 pos) {
    vec3 z  = pos;
    float r;
    float scale = 3.0;
    int n = 0;

    while (n < 25 && (r = length(z)) < 2.0) {
        // Fold: reflect z into positive octant
        z = abs(z);
        // Cross fold: remove bars in each axis pair
        if (z.x - z.y < 0.0) z.xy = z.yx;
        if (z.x - z.z < 0.0) z.xz = z.zx;
        if (z.y - z.z < 0.0) z.yz = z.zy;

        z *= scale;
        z -= vec3(scale - 1.0) * 0.5;
        // Restore central cube if pushed out
        if (z.z < -(scale-1.0) * 0.5)
            z.z += scale - 1.0;
        n++;
    }
    return (length(z) - 1.5) * pow(scale, -float(n));
}
// 100 ray steps
```

#### Sierpinski Tetrahedron Distance Estimator
```glsl
float sierpinskiDE(vec3 z) {
    float scale = 2.0;
    int n = 0;

    while (n < 15 && length(z) < 2.0) {
        // Fold toward nearest vertex of tetrahedron
        if (z.x + z.y < 0.0) z.xy = -z.yx;
        if (z.x + z.z < 0.0) z.xz = -z.zx;
        if (z.y + z.z < 0.0) z.yz = -z.zy;

        z = z * scale - vec3(scale - 1.0);
        n++;
    }
    return length(z) * pow(scale, -float(n));
}
// Note: different fold conditions vs Menger (sum-based vs comparison-based)
```

### 8.4 Normal Calculation (All 3D Shaders)

```glsl
vec3 calcNormal(vec3 p) {
    const float eps = 0.001;
    return normalize(vec3(
        distanceEstimator(p + vec3(eps,0,0)) - distanceEstimator(p - vec3(eps,0,0)),
        distanceEstimator(p + vec3(0,eps,0)) - distanceEstimator(p - vec3(0,eps,0)),
        distanceEstimator(p + vec3(0,0,eps)) - distanceEstimator(p - vec3(0,0,eps))
    ));
}
```

### 8.5 Shadertoy-Style Uniforms (→ Flutter Mapping)

| Shadertoy | Flutter equivalent | Notes |
|-----------|-------------------|-------|
| `iResolution` | `uniform vec2 u_resolution` | Canvas size |
| `iTime` | `uniform float u_time` | Animation controller |
| `iMouse` | `uniform vec4 u_mouse` | Gesture input |
| `iFrame` | `uniform int u_frame` | Manual frame counter |
| `mainImage(out, in)` | `void main()` + `fragColor` | Entry point rename |

### 8.6 Julia Preset Coordinates

Six tested interesting Julia set parameters:

| Name | c |
|------|---|
| Dendritic | (−0.8, 0.156) |
| Spiral | (−0.4, 0.6) |
| Cauliflower | (0.285, 0.01) |
| Flame | (−0.70176, −0.3842) |
| Rabbit | (−0.835, −0.2321) |
| Nautilus | (0.45, 0.1428) |

### 8.7 Performance by Shader

| Shader | MAX_STEPS | Iterations | Mobile suitable? |
|--------|-----------|-----------|-----------------|
| Sierpinski Carpet | N/A | 6 | Yes (fastest) |
| Sierpinski Triangle | N/A | 8 | Yes |
| Koch Curve | N/A | 6 | Yes |
| Julia / Mandelbrot | N/A | 1,000–5,000 | Yes (reduce from 10,000) |
| Mandelbulb | 250 | 10 | Tablet/Desktop |
| Menger Sponge | 100 | 25 | Tablet/Desktop |
| Sierpinski Tetra | 150 | 15 | Tablet/Desktop |
| Mandelbox | 2,500 | 15 | Desktop only |

### 8.8 Applicability Summary

| Technique | Priority | Notes |
|-----------|----------|-------|
| Julia preset coordinates | High | 6 tested good parameters |
| Sierpinski carpet/triangle IFS | High | Fast, visually striking, easy |
| Mandelbulb DE (exact formula) | High | Port to Flutter 3D shader |
| Menger Sponge DE | High | Cross-fold pattern |
| Sierpinski Tetrahedron DE | High | Different fold → different shape |
| Mandelbox DE | Medium | Powerful but very slow |
| Shadertoy → Flutter uniform map | High | Required for every 3D shader |
| Koch curve line reflection | Medium | Good 2D geometric fractal |

---

## 9. Cross-Project Synthesis & Implementation Roadmap

### 9.1 Core Rendering Pipeline (consensus from all eight projects)

```
1. For each fragment (screen pixel):
   a. Map pixel → complex/3D coordinates using center + zoom uniforms
   b. Iterate fractal formula (Mandelbrot, Mandelbulb, attractor ODE, etc.)
   c. Compute escape iteration count (and smooth it)
   d. Lookup color via 1D palette texture
   e. Apply gamma correction
   f. Write gl_FragColor

2. Post-processing passes (optional):
   a. Glow: separable Gaussian blur + composite
   b. FXAA or SSAA
   c. Color correction (exposure, contrast, brightness)
   d. Tone mapping (Reinhard / ACES)
```

### 9.2 Palette System (Unified Design)

Use 256-entry 1D RGBA textures (from glChAoS.P's LUTs + Mandelbulber2's gradient system):

```glsl
uniform sampler2D palette;         // 256×1 RGBA texture
uniform float     paletteOffset;   // 0.0 – 1.0 rotation
uniform float     paletteRange;    // 0.1 – 1.0 (compresses bands)
uniform float     paletteHue;      // HSL hue shift
uniform float     paletteSat;      // HSL saturation
uniform float     paletteLit;      // HSL lightness

float t = fract((colorValue + paletteOffset) * paletteRange);
vec3  c = texture(palette, vec2(t, 0.5)).rgb;
// Apply HSL adjustments to c ...
```

Palettes to ship: Magma, Viridis, Inferno, Plasma, plus 4–6 custom fractal-optimized ones.

### 4.3 Smooth Coloring (Unified Formula)

All three projects converge on the same technique:

```glsl
// 2D escape-time fractals (Mandelbrot, Julia):
float smoothColor(float n, float r2, float power) {
    return n + 1.0 - log(log(sqrt(r2))) / log(power);
}

// 3D fractals (Mandelbulb):
float smoothColor3D(float n, float r, float power) {
    return n + 1.0 - log(log(r)) / log(power);
}

// ODE attractors (glChAoS.P style):
float speed = length(dvdt(z));  // velocity magnitude
float t = clamp(speed * colorIntensity, 0.0, 1.0);
```

### 4.4 Implementation Phases

#### Phase 1 — Core (2D fractals, MVP)
- [ ] Mandelbrot set with smooth coloring
- [ ] Julia set (same shader, different uniform mode)
- [ ] Pan/zoom gestures (center + zoom uniforms)
- [ ] 5 built-in palettes (Magma, Viridis, + 3 custom)
- [ ] sRGB gamma correction
- [ ] FXAA post-pass

#### Phase 2 — 3D Fractals
- [ ] Mandelbulb (power 2, 4, 8) with ray-marching
- [ ] Quaternion fractal
- [ ] Mandelbox
- [ ] Numerical gradient normals
- [ ] Phong shading + directional light
- [ ] Soft shadows (secondary ray march)
- [ ] Simple AO (4-sample along normal)
- [ ] Camera orbit controls

#### Phase 3 — Strange Attractors
- [ ] Lorenz, Aizawa, Rossler as GPU particle streams
- [ ] ODE stepping in vertex shader via Transform Feedback (or compute shader)
- [ ] Velocity-based palette coloring
- [ ] Particle point sprite rendering
- [ ] Glow post-processing (separable Gaussian)

#### Phase 4 — Quality & Extras
- [ ] SSAA 4× anti-aliasing
- [ ] Bilateral filtering at set boundary
- [ ] Orbit trap coloring modes (point, line, circle)
- [ ] IFS variation functions (swirl2D, spherical, polar3D)
- [ ] Mandelbox fold-count coloring
- [ ] Separable Gaussian glow with user-controlled sigma
- [ ] Exposure / contrast / brightness controls
- [ ] Tone mapping (Reinhard)
- [ ] Multiple attractor types (10+)

#### Phase 5 — Advanced
- [ ] Lyapunov exponent search for auto-discovery of beautiful regions
- [ ] Noise-perturbed fractals (Perlin noise + fractal hybrid)
- [ ] Color animation (palette rotation over time)
- [ ] Depth-of-field (blur post-process, not ray-march DOF)
- [ ] Export at 4K (render to FBO)

### 4.5 Shader Parameter Reference Card

```glsl
// --- 2D Fractal Uniforms ---
uniform vec2  u_center;         // Complex plane center, e.g. (-0.5, 0.0)
uniform float u_zoom;           // Pixels per unit, e.g. 300.0
uniform int   u_maxIter;        // 64 – 512
uniform float u_bailout;        // 4.0 (squared), or 10.0 for 3D
uniform float u_power;          // 2.0 (Mandelbrot), 8.0 (Mandelbulb)

// --- Coloring Uniforms ---
uniform sampler2D u_palette;    // 256×1 RGBA
uniform float u_colorOffset;    // 0.0 – 1.0
uniform float u_colorRange;     // 0.01 – 2.0
uniform float u_colorSmooth;    // 0.0 = step, 1.0 = smooth

// --- Post-Processing Uniforms ---
uniform float u_gamma;          // 2.2 (sRGB) or 2.3 (glChAoS.P default)
uniform float u_exposure;       // 1.0 default
uniform float u_brightness;     // 0.0 default
uniform float u_contrast;       // 1.0 default
uniform float u_glowSigma;      // 0.0 = off, 1.0 – 10.0
uniform float u_glowStrength;   // 0.0 – 1.0

// --- 3D Ray-Marcher Uniforms ---
uniform vec3  u_camPos;
uniform mat3  u_camRot;
uniform int   u_maxSteps;       // 32 – 256
uniform float u_stepAccuracy;   // 0.8 – 1.0
uniform float u_detailSize;     // 1e-6 – 1e-4 (scale with zoom)
uniform vec3  u_lightDir;       // normalized
uniform float u_ambient;        // 0.1 – 0.3
uniform float u_specular;       // 0.0 – 1.0
uniform float u_shininess;      // 16 – 128
uniform float u_aoRadius;       // 0.5 – 2.0
uniform int   u_aoSamples;      // 4 – 8

// --- Attractor Uniforms ---
uniform float u_dt;             // 0.001 – 0.05
uniform vec3  u_attractorParams[6];  // k0..k5 per attractor
uniform float u_colorVel;       // 50.0 – 200.0
```

### 4.6 Performance Guidelines (from all three projects)

| Target | Max Iterations | Max Steps | AA | Expected FPS |
|--------|---------------|-----------|-----|-------------|
| Mobile (mid) | 64 | 32 | none | 60 |
| Mobile (high) | 128 | 64 | FXAA | 60 |
| Desktop | 256 | 128 | FXAA | 60 |
| Desktop (quality) | 512 | 256 | SSAA 4× | 30 |
| Export 4K | 1024 | 512 | SSAA 4× | <5 |

- Start with 256×256 tile rendering for interactive zoom; upgrade on release
- Scale `detailSize` inversely with zoom level to maintain consistent visual quality
- Palette texture: 256×1 RGBA8 is sufficient; no need for 32F unless banding is visible
- Separable Gaussian: σ=3 requires only 7 taps per axis (much cheaper than naive 2D)

### 4.7 Key References Found in These Projects

| Reference | Topic |
|-----------|-------|
| Inigo Quilezles (iquilezles.org) | Distance functions, ray-marching, smooth coloring |
| Tom Lowe (Mandelbox paper) | Box-folding + IFS theory |
| Fractal Forums (www.fractalforums.com) | Mandelbulb discovery + variants |
| DarkBeam | Sierpinski & IFS folding |
| Ashima Arts | Modern simplex noise GLSL |
| Christoph Peters | GGX / Cook-Torrance PBR |
| John Hart (1996) | Ray-marching distance fields (original paper) |
