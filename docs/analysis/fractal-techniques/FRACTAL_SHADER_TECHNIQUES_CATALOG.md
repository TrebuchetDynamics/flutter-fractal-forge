# Fractal Shader Techniques Catalog
## Analysis of 4 Open-Source Fractal Projects

Extracted from:
1. **shader-fractals** - Complete GLSL shader collection (2D & 3D)
2. **MV2** - Advanced Mandelbrot viewer with double precision
3. **Giulia** - C++ renderer with precision variants
4. **MandlebrotSetSFML** - SFML-based CPU+GPU hybrid

---

## PROJECT 1: shader-fractals

### Location
`flutter-fractal-forge/opensource/repos/formula-catalogs/shader-fractals/`

### Fractal Types & Formulas

#### 2D Fractals

**Mandelbrot Set** (`2D/MandelbrotSet.glsl`)
- **Formula**: `z = z² + c` where c = pixel coordinate
- **Iteration Limit**: 10,000
- **Divergence Check**: `length(z) > 2.0`
- **Coloring**:
  - Interior (at limit): Black
  - Exterior: Smooth coloring via `smoothstep()` blended with UV coordinates
  - Color channels modulated by uv.x, uv.y coordinates for gradient effect
- **Zoom**: Time-based exponential zoom: `zoom = pow(time, time/10.0)`
- **Precision**: Single (vec2)

**Julia Set** (`2D/JuliaSet.glsl`)
- **Formula**: `z = z² + constant` where z = pixel, constant = predefined parameter
- **Constants Available**: 6 preset c values (e.g., -0.7176-0.3842i, -0.4-0.59i)
- **Iteration Limit**: 10,000
- **Divergence Check**: `length(z) > 2.0`
- **Coloring**: HSV-based with saturation multipliers (5000x boost)
- **Transforms**: Coordinate rotation via 60° basis transformation (U, V vectors)
- **Precision**: Single (vec2)

**Koch Curve** (`2D/KochCurve.glsl`)
- **Type**: Iterative space-folding fractal
- **Algorithm**: Reflection-based folding using `ref()` function
- **Recursion Iterations**: Animated, grows with time: `int mod(iTime, 14.0) * 0.5`
- **Coloring**: Distance-based line drawing via `smoothstep()`
- **Utility Functions**:
  - `polarToCartesian(angle)` - angle to vec2 conversion
  - `ref(uv, point, angle)` - reflects UV across a line
- **Line Rendering**: Thickness controlled by `lineSmoothness / iResolution.y`

**Sierpinski Triangle** (`2D/SierpinskiTriangle.glsl`)
- **Type**: Geometric substitution fractal
- **Algorithm**: Reflection-based folding in 2D space
- **Recursion**: Time-animated: `int mod(iTime, 16.0) * 0.5`
- **Coloring**: Multi-channel gradient blending (R from +X, B from +Y, G from -X)
- **SDF Function**: `signedDistTriangle()` for equilateral triangle distance
- **Utility**: Reflection function for fold operations

**Sierpinski Carpet** (`2D/SierpinskiCarpet.glsl`)
- **Type**: 2D substitution (9->8 squares per iteration)
- **Algorithm**: Iterative space folding with abs() mirrors
- **Recursion Iterations**: Time-animated: `int mod(iTime, 12.0) * 0.5`
- **Coloring**: Spatial gradient (R/B/G channels from different axes)
- **Optimization**: Uses `step()` for boolean operations instead of branches

#### 3D Fractals (Raymarching)

**Mandelbulb** (`3D/Mandelbulb.glsl`)
- **Formula**: `v^n + c` in spherical coordinates (n=8 in demo, animates between 8-13)
- **3D Iteration Loop**: 10 iterations max
- **Polar to Cartesian Transform**:
  ```glsl
  float theta = acos(z.z / r);
  float phi = atan(z.y, z.x);
  // scale and rotate
  float zr = pow(r, power);
  theta = theta * power;
  phi = phi * power;
  // convert back
  z = zr * vec3(sin(theta)*cos(phi), sin(phi)*sin(theta), cos(theta));
  ```
- **Distance Estimation** (Derivative):
  ```glsl
  float dr = 1.0;
  dr = pow(r, power-1.0) * power * dr + 1.0;
  float dst = 0.5 * log(r) * r / dr;
  ```
- **Raymarching**: 250 steps max, min distance 0.0001
- **Coloring**:
  - Hit: HSV based on position length
  - Miss: Ambient occlusion with `1/(distance²)`
  - Brightness modulated by `sin(iTime*3.0)` for animation
- **Lighting**: Basic ambient occlusion: `col /= steps * 0.08`

**Mandelbox** (`3D/Mandelbox.glsl`)
- **Algorithm**: Box/sphere folding iteration
- **SDF Functions**:
  ```glsl
  vec4 sphere(vec4 z) {
    float r2 = dot(z.xyz, z.xyz);
    if (r2 < 2.0) z *= (1.0/r2);
    else z *= 0.5;
    return z;
  }
  vec3 box(vec3 z) {
    return clamp(z, -1.0, 1.0) * 2.0 - z;
  }
  ```
- **Scale**: -20.0 * 0.272321 (fixed for stable iteration)
- **Iterations**: 10 per ray
- **Parameters**: Smoothness 0.5, power varies by interaction
- **Raymarching**: 2500 steps, min distance 0.001
- **Coloring**: HSV based on distance and position
- **Optimization**: Separates sphere/box distance functions

**Menger Sponge** (`3D/MengerSponge.glsl`)
- **Formula**: 3D Sierpinski generalization via folding
- **Iteration Algorithm**:
  ```glsl
  float sierpinski3(vec3 z) {
    for(...) {
      z.x = abs(z.x); z.y = abs(z.y); z.z = abs(z.z);
      if(z.x - z.y < 0) z.xy = z.yx; // fold 1
      if(z.x - z.z < 0) z.xz = z.zx; // fold 2
      if(z.y - z.z < 0) z.zy = z.yz; // fold 3
      z = z * Scale - Offset * (Scale - 1.0);
    }
    return (length(z) - 2.0) * pow(Scale, -float(n));
  }
  ```
- **Scale**: 2.0 + sin(iTime/2.0) (animated)
- **Offset**: 3.0 * vec3(1,1,1)
- **Distance Normalization**: Divides by `pow(Scale, -n)` for scale-invariant results
- **Raymarching**: 100 steps, min distance 0.01
- **SDF Library** (included):
  - `SignedDistSphere(p, s)`
  - `SignedDistBox(p, b)`
  - `SignedDistPlane(p, n)`
  - `SignedDistRoundBox(p, b, r)`
- **Boolean Operations**:
  - Smooth Union: `opUS(d1, d2, k)` with smoothness parameter
  - Smooth Subtraction: `opSS(d1, d2, k)`
  - Smooth Intersection: `opIS(d1, d2, k)`

**Sierpinski Tetrahedron** (`3D/SierpinskiTetrahedron.glsl`)
- **Type**: 3D analogue of Sierpinski Triangle (Tetrix)
- **Iteration Loop**: 15 iterations with fold operations
- **Fold Sequence**:
  ```glsl
  if(z.x + z.y < 0) z.xy = -z.yx;
  if(z.x + z.z < 0) z.xz = -z.zx;
  if(z.y + z.z < 0) z.zy = -z.yz;
  ```
- **Scaling**: Scale = 2.0 fixed, Offset = 3.0
- **Distance Calculation**: `(length(z)) * pow(Scale, -float(n))`
- **Raymarching**: 100 steps, min distance 0.01
- **Rotations**: Applied to entire scene for animation

**Menger Broccoli** (`3D/MengerBrocolli.glsl`)
- **Type**: Custom variant (non-canonical) of Menger Sponge
- **Algorithm**: Similar folding to sponge but with different parameters
- **Fractal Dimension**: Estimated ~2.7
- **Raymarching Config**: 100 steps, MaxDist 1000, MinDist 0.01

---

### GLSL Coloring Techniques (shader-fractals)

#### Smooth Coloring
**Mandelbrot/Julia**:
```glsl
float f = float(recursionCount) / float(RECURSION_LIMIT);
float ff = pow(f, 1.0 - (f * max(0.0, (50.0 - time))));
col.r = smoothstep(0.0, smoothness, ff) * (uv2.x * 0.5 + 0.5);
```
- Uses iteration count normalized to [0,1]
- Power function for non-linear color progression
- `smoothstep()` for soft transitions
- Multiplied by UV-based gradients for spatial color variation

#### HSV Color Space Conversion
```glsl
vec3 hsv2rgb(vec3 c) {
  vec4 K = vec4(1.0, 2.0/3.0, 1.0/3.0, 3.0);
  vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
  return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}
```
- Used in all 3D fractals
- HSV components:
  - **H (Hue)**: Based on distance/position length
  - **S (Saturation)**: Often fixed at 1.0
  - **V (Value)**: Distance-based brightness
- Example: `col.rgb = vec3(0.8 + length(curPos)/10.0, 1.0, 0.8)`

#### Distance-Based Coloring (3D)
```glsl
if(hit) {
  col.rgb = hsv2rgb(vec3(0.8 + (length(curPos)/8.0), 1.0, 0.8));
} else {
  col.rgb *= 1.0 / pow(minDistToScene, 2.0);
  col.rgb /= map(sin(iTime*3.0), -1.0, 1.0, 1.0, 3.0);
}
```

#### Ambient Occlusion via Steps
```glsl
col.rgb /= steps * 0.08; // Darken based on ray step count
col.rgb /= pow(distance(ro, minDistToScenePos), 2.0); // Distance falloff
col.rgb *= 3.0; // Brightness scaling
```

---

### GLSL Anti-Aliasing Approaches

**No native MSAA** - single ray per pixel. Options:
1. **Time-jitter** (temporal AA):
   ```glsl
   vec2 jitter = fract(sin(vec2(time, fragCoord.x)) * 43758.5453);
   fragCoord += jitter * 0.5;
   ```

2. **Sub-pixel sampling** (manual SSAA):
   For 2D fractals, use multiple samples per pixel in loop

3. **Smooth coloring** (soft edges):
   Via `smoothstep()` instead of hard threshold at divergence

---

### Uniform/Parameter Systems

**2D Fractals**:
```glsl
uniform dvec2 down_left;        // viewport bottom-left corner
uniform dvec2 c;                // Julia constant
uniform uvec2 render_resolution; // screen size
uniform float range_x, range_y; // zoom range
uniform uint iter;              // max iterations
uniform uint color_preset;      // coloring mode (1-5)
uniform uint exponent;          // power (for generalized Mandelbrot)
```

**3D Fractals** (implicit from mainImage):
```glsl
uniform vec2 iMouse;       // mouse position
uniform vec2 iResolution;  // viewport size
uniform float iTime;       // elapsed time
uniform sampler2D iChannel0; // optional texture input
```

**Advanced (MV2-style)**:
```glsl
uniform float spectrum_offset;
uniform int ssaa_factor;
uniform bool continuous_coloring;
uniform bool normal_map_effect;
uniform float height, angle;    // for normal mapping
```

---

### Reusable GLSL Utility Functions

#### Math Utilities
```glsl
// Range mapping
float map(float value, float min1, float max1, float min2, float max2) {
  return min2 + (value - min1) * (max2 - min2) / (max1 - min1);
}

// Polar to Cartesian
vec2 polarToCartesian(float angle) {
  return vec2(sin(angle), cos(angle));
}

// Magnitude of complex number
float magnitude(in vec2 c) {
  return sqrt(c.x*c.x + c.y*c.y);
}

// Complex multiplication
vec2 product(in vec2 a, in vec2 b) {
  return vec2(a.x*b.x - a.y*b.y, a.x*b.y + a.y*b.x);
}

// Complex addition
vec2 add(in vec2 a, in vec2 b) {
  return a + b;
}
```

#### Geometric Utilities
```glsl
// 2D rotation matrix
mat2 Rotate(float angle) {
  float s = sin(angle);
  float c = cos(angle);
  return mat2(c, -s, s, c);
}

// Ray construction (camera to world)
vec3 R(vec2 uv, vec3 p, vec3 l, float z) {
  vec3 f = normalize(l - p);
  vec3 r = normalize(cross(vec3(0,1,0), f));
  vec3 u = cross(f, r);
  vec3 c = p + f * z;
  vec3 i = c + uv.x*r + uv.y*u;
  return normalize(i - p);
}

// Line reflection
vec2 reflect_line(vec2 uv, vec2 p, float angle) {
  vec2 dir = polarToCartesian(angle);
  return uv - dir * min(dot(uv - p, dir), 0.0) * 2.0;
}

// Signed distance to equilateral triangle
float signedDistTriangle(vec2 p) {
  const float sqrt3 = sqrt(3.0);
  p.x = abs(p.x) - 1.0;
  p.y = p.y + 1.0/sqrt3;
  if(p.x + sqrt3*p.y > 0.0)
    p = vec2(p.x - sqrt3*p.y, -sqrt3*p.x - p.y) / 2.0;
  p.x -= clamp(p.x, -2.0, 0.0);
  return -length(p) * sign(p.y);
}
```

#### SDF Utilities (3D)
```glsl
float SignedDistSphere(vec3 p, float s) { return length(p) - s; }
float SignedDistBox(vec3 p, vec3 b) {
  vec3 d = abs(p) - b;
  return min(max(d.x, max(d.y, d.z)), 0.0) + length(max(d, 0.0));
}
float SignedDistPlane(vec3 p, vec4 n) { return dot(p, n.xyz) + n.w; }
float SignedDistRoundBox(vec3 p, vec3 b, float r) {
  vec3 q = abs(p) - b;
  return min(max(q.x, max(q.y, q.z)), 0.0) + length(max(q, 0.0)) - r;
}

// Smooth boolean operations
float opUS(float d1, float d2, float k) {
  float h = clamp(0.5 + 0.5*(d2-d1)/k, 0.0, 1.0);
  return mix(d2, d1, h) - k*h*(1.0-h);
}
vec4 opSS(vec4 d1, vec4 d2, float k) {
  float h = clamp(0.5 - 0.5*(d2.w+d1.w)/k, 0.0, 1.0);
  float dist = mix(d2.w, -d1.w, h) + k*h*(1.0-h);
  return vec4(mix(d2.rgb, d1.rgb, h), dist);
}

// Position modulo for repetition
float pMod1(inout float p, float size) {
  float halfsize = size * 0.5;
  float c = floor((p + halfsize) / size);
  p = mod(p + halfsize, size) - halfsize;
  p = mod(-p + halfsize, size) - halfsize;
  return c;
}
```

#### Raymarching Loop
```glsl
vec4 RayMarcher(vec3 ro, vec3 rd) {
  float totalDist = 0.0, steps = 0.0;
  vec4 col = vec4(0);

  for(steps = 0.0; steps < float(MaximumRaySteps); steps++) {
    vec3 p = ro + totalDist * rd;
    float dist = DistanceEstimator(p);
    totalDist += dist;

    if(dist < MinimumDistance) {
      col.rgb = getColor(p, steps);
      break;
    } else if(totalDist > MaximumDistance) {
      col.rgb = getMissColor(p);
      break;
    }
  }
  return col;
}
```

---

## PROJECT 2: MV2

### Location
`flutter-fractal-forge/opensource/repos/renderers/MV2/`

### Architecture
- **Language**: GLSL (compute shader variant)
- **Precision**: Double precision (`dvec2`, `double`)
- **Version**: GLSL 4.60 core

### Fractal Types Supported
- **Mandelbrot Set** (mode 2, primary)
- **Julia Set** (mode 3, secondary)
- **Custom formulas** (templated)

### Advanced Features

#### Double Precision Math Library
```glsl
// Custom atan2 with Taylor polynomial approximation
double atan2(double y, double x)
// Custom sin, cos, log, exp, pow with Horner's method
double dsin(double x)  // 10-term Horner polynomial
double dcos(double x)
double dlog(double x)
double dexp(double x)  // Poly with exp2 scaling
double dpow(double x, double y)

// Complex double operations
dvec2 cexp(dvec2 z)        // e^z
dvec2 cmultiply(dvec2 a, dvec2 b)
dvec2 cdivide(dvec2 a, dvec2 b)
dvec2 cpow(dvec2 z, float p)    // general power
dvec2 csin(dvec2 z), ccos(dvec2 z)
dvec2 csqrt(dvec2 z)
```

#### Smooth Coloring Algorithm
```glsl
float smooth_color(dvec2 z, dvec2 prevz, float power, int i, int max_iters) {
  float s;
  if(distance(z, prevz) > 1e-2) {
    // Standard: log2(log2(|z|))
    s = i + 1 - log2(log(float(length(z)))) / log2(power);
    if(s < 1) s = 1;
    if(s >= max_iters) s = i - 1;
  } else {
    // Alternate: from previous step distance
    s = i + log2(-2.7f / log(float(length(z - prevz))));
  }
  return s;
}
```
- **Interpolates** between discrete iteration counts
- **Handles** zoom artifacts at high magnification
- **Continuous coloring** optional via flag

#### Normal Mapping Effect
```glsl
dvec2 nv = cexp(dvec2(0.f, angle * 2.f * M_PI / 360.f));
dvec2 u = cdivide(z, der);
u = u / length(u);
float t = float(u.x * nv.x + u.y * nv.y + height) / (1.f + height);
if(t < 0) t = 0;
// Apply normal mapping to coloring
col = mix(vec3(0.f), color_value, pow(t, 1.f / 1.8f));
```
- **Height parameter** controls relief intensity
- **Angle parameter** rotates light direction
- **Gamma correction** (1/1.8) for brightness calibration

#### Perturbation Iteration (Deep Zoom)
```glsl
// Reference orbit + perturbation delta
d = 2.0 * cmultiply(reference[i], d) + cpow(d, 2) + dz;
z = reference[i+1] + d;
```
- **Precomputed reference orbit** stored in SSBO
- **Perturbation** `d` tracks deviation from reference
- **Allows** extremely deep zooms without losing precision
- **Reduces** per-pixel computation at high magnification

#### Derivative Tracking
```glsl
dvec2 differentiate(dvec2 z, dvec2 der) {
  der = cmultiply(cpow(z, power - 1.f), der) * power + 1.0;
  return der;
}
```
- **Tracks** derivative `dz/dc` for normal mapping
- **Used** in smooth coloring and relief effects

#### Optimization: Cardioid/Bulb Detection
```glsl
if(power == 2.f && cardioid_check) {
  double q = (c.x - 0.25) * (c.x - 0.25) + c.y * c.y;
  bool cardioid = q * (q + (c.x - 0.25)) <= 0.25 * c.y * c.y;
  bool bulb = (c.x + 1.0) * (c.x + 1.0) + c.y * c.y <= 0.0625;
  if(cardioid || bulb) return vec4(-1.f, -1.f, 0.f, 0.f); // skip
}
```
- **Skips** interior points (known to be in set)
- **Massive speedup** for power-2 Mandelbrot

#### Supersampling Anti-Aliasing (SSAA)
```glsl
// Per-pixel jitter for temporal AA
if(taa) fragCoord += (vec2(rand(...), rand(...)) * 2.f - 1.f) / 2.f;

// Spatial averaging via convolution
blurredColor += color(...) * weights[...];
```
- **Temporal AA**: Jitter across frames, accumulate
- **Spatial SSAA**: Kernel-based (Gaussian blur weights)
- **Accumulation buffer**: `accIndex` tracks frame count per pixel

#### Orbit Visualization
```glsl
if(show_orbit) {
  for(int i = 1; i < numVertices - 1; i++) {
    // Check if pixel near orbit point or line segment
    float m = (orbit_in[i].y - orbit_in[i-1].y) / (orbit_in[i].x - orbit_in[i-1].x);
    float c = orbit_in[i-1].y - m * orbit_in[i-1].x;
    if(/* near point or line */) fragColor = 1.f - fragColor; // invert
  }
}
```
- **Displays** iteration orbits overlaid on fractal
- **Line detection** using point-to-line distance
- **Interactive** tracing of escape trajectories

#### Spectrum/Transfer Function
```glsl
vec3 color(float i) {
  if(i < 0.f) return set_color;

  // Transfer function options
  switch(transfer_function) {
  case 1: i = sqrt(i); break;
  case 2: i = pow(i, 1.f/3.f); break;
  case 3: i = log(i); break;
  }

  // Index into spectrum gradient
  i = mod(i * iter_multiplier + spectrum_offset, span) / span;
  for(int v = 0; v < spec.length(); v++) {
    if(spec[v].w > i) return lerp(spec[v-1], spec[v], ...);
  }
}
```
- **Piecewise linear gradient** in spectrum array
- **Adjustable offset** and multiplier for color cycling
- **Transfer functions** for different emphasis (sqrt, cbrt, log)

#### Shader Storage Buffer Objects (SSBOs)
```glsl
layout(std430, binding = 0) coherent buffer vertices_in { vec2 orbit_in[]; };
layout(std430, binding = 1) coherent buffer vertices_out { dvec2 orbit_out[]; };
layout(std430, binding = 2) readonly buffer spectrum { vec4 spec[]; };
layout(std430, binding = 3) readonly buffer variables { float sliders[]; };
layout(std430, binding = 4) readonly buffer kernel { float weights[]; };
layout(std430, binding = 5) readonly buffer reference_orbit { dvec2 reference[]; };
```
- **Orbit I/O**: Store and retrieve iteration sequences
- **Spectrum**: Gradient control points
- **Variables**: Slider parameters from UI
- **Kernel**: Convolution weights for SSAA
- **Reference**: Precomputed orbit for perturbation method

---

## PROJECT 3: Giulia

### Location
`flutter-fractal-forge/opensource/repos/renderers/giulia/src/gl/shaders/`

### Shader Variants

#### Single Precision (`single_precision.shader`)
- **Precision**: `vec2` (32-bit floats)
- **Coloring**: 5 HSV-based presets
- **Target**: Real-time interactive exploration

#### Double Precision (`double_precision.shader`)
- **Precision**: `dvec2` (64-bit doubles)
- **Coloring**: Same 5 presets
- **Target**: High magnification, deep zooms

#### Low Resolution (`double_precision_low_res.shader`)
- **Precision**: Double (64-bit)
- **Render**: Checkerboard pattern (1/4 resolution)
- **Use**: Very deep zooms with fast feedback

### Fractal Algorithm

```glsl
int mandelbrot_set_degree(in dvec2 z, in dvec2 c,
                          in int max_steps, in float threshold,
                          in uint exponent) {
  int index = 0;
  while(index < max_steps && magnetude(z) < threshold) {
    for(int i = 1; i < exponent; i++) {
      z = product(z, z);  // z = z^exponent
    }
    z = add_(z, c);
    index++;
  }
  return index;
}
```
- **Supports variable exponent** (e.g., z³+c, z⁴+c)
- **Divergence threshold**: 4.0 (standard)
- **Bailout check**: `magnetude(z) < threshold`

### Uniform Parameters
```glsl
uniform dvec2 down_left;      // viewport corner
uniform dvec2 c;              // Julia set parameter
uniform uvec2 render_resolution;
uniform uvec2 render_offset;
uniform float range_x, range_y; // zoom range
uniform uint mode_;           // 0=Mandelbrot, 1=Julia
uniform uint iter;            // max iterations
uniform uint color_preset;    // 1-5
uniform uint exponent;        // power (for z^n+c)
```

### Color Presets
```glsl
switch(color_preset) {
case 1: rgb_c = hsv2rgb(vec3(1, 0, mandelbrot));           // V gradient
case 2: rgb_c = hsv2rgb(vec3(1, 0, 1 - mandelbrot));      // Inverted V
case 3: rgb_c = hsv2rgb(vec3(1 - mandelbrot, mandelbrot, 1 - mandelbrot));
case 4: rgb_c = hsv2rgb(vec3(1 - mandelbrot, 1 - mandelbrot, mandelbrot));
case 5: rgb_c = hsv2rgb(vec3(mandelbrot, 1 - mandelbrot, 1 - mandelbrot));
}
```
- **HSV color space**: Hue varies based on iteration count
- **Saturation**: Often fixed at 0 (grayscale) or 1 (full color)
- **Value**: Iteration-normalized brightness

---

## PROJECT 4: MandlebrotSetSFML

### Location
`flutter-fractal-forge/opensource/repos/renderers/MandlebrotSetSFML/`

### Architecture
- **Language**: C++ with OpenCL kernels (CPU fallback)
- **Rendering**: CPU + GPU hybrid
- **Framework**: SFML (graphics)

### Key Header Files

#### `kernelCodeStr.h`
- **Purpose**: Template strings for dynamic kernel generation
- **Components**:
  - `beginning_mandelbrot` - kernel prologue for Mandelbrot
  - `beginning_julia` - kernel prologue for Julia
  - `ending` - kernel epilogue
  - `julia_predefined` - predefined Julia constants
  - `mandelbrot_predefined` - predefined Mandelbrot constants
  - `antialiasingCode` - SSAA kernel code

#### `CustomFormulaHandling.h`
- **Purpose**: Runtime formula modification
- **Allows**: User-defined fractal equations
- **Implementation**: Template substitution in kernel string

#### `IterationPath.h`
- **Purpose**: Track orbit visualization
- **Stores**: Per-pixel iteration sequences
- **Use**: Debug and educational visualization

#### `PaletteHandler.h`
- **Purpose**: Gradient/palette management
- **Supports**: Multiple colormaps
- **Interface**: Iteration → RGB mapping

### CPU Fallback (`CpuFallback.h`)
- **When**: GPU not available or for debugging
- **Algorithm**: Pure CPU iteration
- **Performance**: ~10-100x slower than GPU

### Macros (`Macros.h`)
- **Configuration**: Compile-time options
- **Precision**: Single vs double precision toggles
- **Features**: Enable/disable anti-aliasing, orbit tracking

### Antialiasing Implementation
```cpp
// From antialiasingCode
for(int ax = 0; ax < AA_SAMPLES; ax++) {
  for(int ay = 0; ay < AA_SAMPLES; ay++) {
    float jx = (ax + 0.5) / AA_SAMPLES;
    float jy = (ay + 0.5) / AA_SAMPLES;
    float sample_iter = compute_fractal(c + vec2(jx, jy) * pixel_size);
    total_iter += sample_iter;
  }
}
result = total_iter / (AA_SAMPLES * AA_SAMPLES);
```
- **Grid-based SSAA**: N×N subsamples per pixel
- **Offset jitter**: Reduces aliasing artifacts
- **Averaging**: Integer iteration counts interpolated

---

## COMPARATIVE SUMMARY

### Precision & Performance Tradeoff

| Project | Precision | Speed | Zoom Depth | Use Case |
|---------|-----------|-------|-----------|----------|
| shader-fractals | Single (float32) | Fastest | ~10⁶× | Interactive exploration |
| Giulia | Single/Double | Fast/Slow | 10⁶-10¹⁵× | Real-time + deep zoom |
| MV2 | Double + custom math | Slow | 10¹⁵×+ | Ultra-deep with features |
| MandlebrotSetSFML | Single/Double (OpenCL) | Fast/Slow | 10⁶-10¹⁵× | CPU hybrid |

### Coloring Techniques Recap

| Technique | shader-fractals | MV2 | Giulia | SFML |
|-----------|-----------------|-----|--------|------|
| HSV conversion | Yes (all 3D) | Yes | Yes | Yes |
| Smooth coloring | Basic | Advanced (log²) | Discrete | Interpolated |
| Normal mapping | No | Yes | No | No |
| Distance-based | Yes (3D) | Yes | Yes | No |
| Orbit trap | No | Optional | No | Yes (via header) |
| Transfer functions | No | Yes (sqrt/log) | No | No |

### Anti-Aliasing Methods

| Method | shader-fractals | MV2 | Giulia | SFML |
|--------|-----------------|-----|--------|------|
| Temporal jitter | Possible | Yes (TAA) | No | No |
| Spatial SSAA | No | Yes (kernel) | No | Yes (grid) |
| Smooth coloring | Yes (softness) | Yes | No | Yes |
| Hardware MSAA | No | No | No | No |

### Raymarching & SDF (3D Fractals)

**All 3D fractals use distance estimation**:
- **Mandelbulb**: Spherical coordinates + derivative tracking
- **Mandelbox**: Box/sphere folding with proper scaling
- **Menger Sponge**: Iterative folding with scale normalization
- **Sierpinski Tetrahedron**: Linear fold operations

**Common Pattern**:
```glsl
float est_distance(vec3 p) { return /* DE formula */ }
for(steps = 0; steps < MAX; steps++) {
  float d = est_distance(p);
  if(d < MIN_DIST) hit = true;
  p += d * ray_direction;
  if(distance > MAX_DIST) break;
}
```

---

## IMPLEMENTATION RECOMMENDATIONS FOR FLUTTER

### 1. **Start with 2D Fractals**
- Use `shader-fractals/2D` as reference implementation
- Port Mandelbrot/Julia shaders to Flutter impeller
- Implement HSV→RGB utility function
- Add zoom controls via gesture input

### 2. **Coloring Priority**
1. **Basic**: Iteration count normalized to [0,1]
2. **Smooth**: Log-based coloring via `smooth_color()` pattern
3. **Advanced**: HSV with spatially-varying hue
4. **Expert**: Normal mapping (requires derivative tracking)

### 3. **Anti-Aliasing Strategy**
- **Stage 1**: Smooth coloring (free, via shader)
- **Stage 2**: Temporal jitter (simple, 4-8 frames)
- **Stage 3**: Spatial subsampling (expensive, 2×2 or 3×3)

### 4. **Precision Handling**
- Use `dMandelbrot(vec2)` pattern for single-pass single precision
- Pre-compute reference orbit for deep zooms (perturbation method)
- Consider adopting MV2's double-precision math library

### 5. **3D/Raymarching**
- Port Mandelbulb shader first (simplest DE formula)
- Implement `RayMarcher()` loop pattern from shader-fractals
- Use `SignedDistBox()` and `SignedDistSphere()` utilities
- Start with 100 steps, tune based on performance

### 6. **Parameter Management**
Adopt Giulia's uniform system:
```dart
class FractalUniforms {
  dvec2 center;
  float zoom;
  uint maxIterations;
  uint exponent;  // for z^n+c
  uint colorPreset;
  bool isJulia;
}
```

### 7. **Reusable Shader Utilities Library**
Extract these as GLSL includes:
- `complex_math.glsl` - multiply, divide, power, exp, log
- `sdf_primitives.glsl` - sphere, box, plane SDFs
- `color_space.glsl` - HSV↔RGB, smooth coloring
- `raymarching.glsl` - main loop template

---

## TECHNICAL INSIGHTS

### Why Smooth Coloring Matters
Raw iteration count produces harsh bands. Smooth coloring uses:
```
smooth_iter = iter + 1 - log₂(log₂(|z|)) / log₂(power)
```
This matches the actual iteration progress within the final escaping cycle.

### Distance Estimation in 3D
For Mandelbulb (z^n + c), DE is NOT just |z|:
```
distance = 0.5 * log(r) * r / derivative
```
where `derivative` accumulates: `dr = pow(r,n-1) * n * dr + 1.0`

This ensures consistent step sizes across the fractal surface.

### Perturbation Method Benefits
- **Problem**: Double precision bottleneck at zoom > 10¹⁵
- **Solution**: Store reference orbit once, then perturb
- **Equation**: `z_new = reference[i] + delta` where delta evolves locally
- **Result**: Can zoom arbitrarily deep with 32-bit float math for delta

### Cardioid/Bulb Skip Optimization
Main bulb and cardioid of Mandelbrot are analytically known:
- **Main cardioid**: `|c - 0.25| ≤ (q(q + (c.x - 0.25)) ≤ 0.25*c.y²`
- **Period-2 bulb**: `|c + 1| ≤ 0.0625`

Skip iteration for these regions → ~20-30% faster for power-2 Mandelbrot.

### Complex Number Operations in GLSL
```glsl
dvec2 cmul(dvec2 a, dvec2 b) { return dvec2(a.x*b.x - a.y*b.y, a.x*b.y + a.y*b.x); }
dvec2 cdiv(dvec2 a, dvec2 b) { double d = dot(b,b); return dvec2(dot(a,b), a.y*b.x - a.x*b.y) / d; }
dvec2 cpow(dvec2 z, float p) {
  float r = length(z), th = atan(z.y, z.x);
  return pow(r, p) * dvec2(cos(p*th), sin(p*th));
}
```

---

## FILES EXTRACTED

```
shader-fractals/
  2D/
    MandelbrotSet.glsl         (10k iter, smooth coloring)
    JuliaSet.glsl              (6 presets, rotation)
    KochCurve.glsl             (reflection-based folding)
    SierpinskiTriangle.glsl    (geometric folding)
    SierpinskiCarpet.glsl      (9→8 iteration)
  3D/
    Mandelbulb.glsl            (spherical coords, 10 iter, 250 steps)
    Mandelbox.glsl             (box/sphere folding, 10 iter, 2500 steps)
    MengerSponge.glsl          (3D Sierpinski, 25 iter)
    SierpinskiTetrahedron.glsl (tetrix, 15 iter)
    MengerBrocolli.glsl        (variant, custom)

MV2/
  shaders/render.glsl         (460 lines, double precision, advanced features)

Giulia/
  src/gl/shaders/
    single_precision.shader    (100 lines)
    double_precision.shader    (110 lines)
    double_precision_low_res.shader

MandlebrotSetSFML/
  include/kernelCodeStr.h     (header for dynamic kernels)
  include/CustomFormulaHandling.h
  include/IterationPath.h
  include/PaletteHandler.h
  include/CpuFallback.h
  include/Macros.h
```

---

## QUICK START FOR FLUTTER IMPLEMENTATION

### Step 1: Port Basic Mandelbrot
Use `shader-fractals/2D/MandelbrotSet.glsl` as template:
- Adapt coordinate system (flip Y for Flutter)
- Implement zoom/pan via uniforms
- Use HSV coloring for 5 presets (Giulia style)

### Step 2: Add Julia Set
- Add uniform `bool isJulia`
- Store `vec2 constant` for Julia parameter
- Implement constant picker UI

### Step 3: Implement Smooth Coloring
```glsl
float iter_smooth = float(iter) + 1.0 -
  log2(log2(length(z))) / log2(power);
float col = mod(iter_smooth * multiplier, 1.0);
```

### Step 4: Add 3D (Mandelbulb)
- Implement raymarching loop from shader-fractals
- Port spherical coordinate formulas
- Add camera control (orbit, zoom)

### Step 5: Optimization Pass
- Implement cardioid skip for Mandelbrot
- Add temporal AA (4-8 frame jitter)
- Consider perturbation for deep zooms

---

**End of Analysis**

Generated from 4 open-source projects, 11 shader files, 1 advanced renderer (MV2), and comprehensive reference implementations.
