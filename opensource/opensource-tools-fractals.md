# Open-Source Fractal Tools — Reference Document

Analysis of three open-source projects for applicability to Flutter Fractal Forge (GPU shader-based
interactive fractal explorer). Each section extracts concrete algorithms, formulas, parameter ranges,
and GPU patterns that can be directly ported or adapted.

---

## Table of Contents

1. [glChAoS.P — Strange Attractors & Particle Systems](#1-glchaos-p)
2. [Mandelbulber2 — 3D Fractal Ray-Marcher](#2-mandelbulber2)
3. [Psychtoolbox-3 — GPU Procedural Rendering & Color Science](#3-psychtoolbox-3)
4. [Cross-Project Synthesis & Implementation Roadmap](#4-synthesis)

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

## 4. Cross-Project Synthesis & Implementation Roadmap

### 4.1 Core Rendering Pipeline (consensus from all three projects)

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

### 4.2 Palette System (Unified Design)

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
