# Fractal Shader Techniques - Quick Reference Index

## What's in the Catalog?

📄 **Main Document**: `FRACTAL_SHADER_TECHNIQUES_CATALOG.md` (917 lines)

---

## Quick Lookup by Topic

### Fractal Formulas

| Fractal | File | Formula | Iterations |
|---------|------|---------|-----------|
| Mandelbrot | `shader-fractals/2D/MandelbrotSet.glsl` | z² + c | 10,000 |
| Julia | `shader-fractals/2D/JuliaSet.glsl` | z² + const | 10,000 |
| Koch Curve | `shader-fractals/2D/KochCurve.glsl` | Folding | ~7 |
| Sierpinski Triangle | `shader-fractals/2D/SierpinskiTriangle.glsl` | Folding | 8 |
| Sierpinski Carpet | `shader-fractals/2D/SierpinskiCarpet.glsl` | Folding (9→8) | 6 |
| Mandelbulb | `shader-fractals/3D/Mandelbulb.glsl` | v^n + c (n=8-13) | 10 |
| Mandelbox | `shader-fractals/3D/Mandelbox.glsl` | Box/sphere fold | 10 |
| Menger Sponge | `shader-fractals/3D/MengerSponge.glsl` | 3D Sierpinski | 25 |
| Sierpinski Tetrahedron | `shader-fractals/3D/SierpinskiTetrahedron.glsl` | Tetrix | 15 |

### Coloring Techniques

| Technique | Location | Complexity | Best For |
|-----------|----------|-----------|----------|
| Discrete iteration | All | Simple | Quick rendering |
| Smooth coloring | MV2 (line 332-344) | Intermediate | Banding removal |
| HSV conversion | All 3D shaders | Simple | Color variety |
| Distance-based | 3D shaders | Simple | 3D fractal shading |
| Normal mapping | MV2 (line 423-426) | Advanced | Relief effects |
| Orbit trap | MV2 (line 477-490) | Advanced | Pattern analysis |
| Transfer functions | MV2 (line 304-314) | Intermediate | Color remapping |

### Anti-Aliasing Methods

| Method | Implementation | Cost | Quality |
|--------|----------------|------|---------|
| Smooth coloring | smoothstep() | Free | Medium |
| Temporal jitter | rand() per frame | 4-8 frames | Good |
| Spatial SSAA (2×2) | 4 samples/pixel | 4× | Excellent |
| Spatial SSAA (3×3) | 9 samples/pixel | 9× | Best |
| Kernel blur | Convolution | 9-25× | Excellent |

### Precision Handling

| Level | Type | Depth | Speed | Use Case |
|-------|------|-------|-------|----------|
| Single | vec2 (32-bit) | ~10⁶× | Fastest | Interactive |
| Double | dvec2 (64-bit) | ~10¹⁵× | Slow | Deep zoom |
| Custom math | GLSL lib | ~10²⁰× | Very slow | Ultra-deep |
| Perturbation | Reference + delta | ~∞ | Fast | Extreme zoom |

### 3D Raymarching

| Component | Pattern | Location |
|-----------|---------|----------|
| Ray construction | `vec3 R(...)` | SierpinskiTetrahedron:127-135 |
| Distance estimation | `float DistanceEstimator(p)` | Mandelbulb:82-86 |
| Raymarching loop | Main loop 100-120 steps | MengerSponge:205-225 |
| Coloring on hit | HSV from position | Mandelbulb:124-133 |
| Lighting/AO | Step count + distance | Mandelbox:135-137 |

### Reusable Utility Functions

**Math** (see catalog for full code):
- `magnetude(vec2)` - complex magnitude
- `product(vec2, vec2)` - complex multiplication
- `map(float, ...)` - linear remapping

**Geometry**:
- `Rotate(angle)` - 2D rotation matrix
- `polarToCartesian(angle)` - angle→vec2
- `ref(uv, p, angle)` - line reflection
- `signedDistTriangle(p)` - triangle SDF

**SDF Primitives**:
- `SignedDistSphere(p, s)`
- `SignedDistBox(p, b)`
- `SignedDistPlane(p, n)`
- `SignedDistRoundBox(p, b, r)`

**Boolean Operations**:
- `opUS(d1, d2, k)` - smooth union
- `opSS(d1, d2, k)` - smooth subtraction
- `opIS(d1, d2, k)` - smooth intersection

---

## Project Comparison

### Precision Support
- **shader-fractals**: Single only ✓
- **Giulia**: Single + Double ✓✓
- **MV2**: Double + custom math ✓✓✓
- **MandlebrotSetSFML**: Single + Double (OpenCL) ✓✓

### Advanced Features
- **Normal mapping**: MV2 only
- **Orbit visualization**: MV2 only
- **Perturbation method**: MV2 only
- **Cardioid skip optimization**: Giulia, MV2
- **Transfer functions**: MV2 only
- **Custom formulas**: MandlebrotSetSFML

### 3D Support
- **shader-fractals**: Yes (5 types)
- **Others**: Mandelbrot/Julia only

---

## Implementation Roadmap for Flutter

```
Phase 1: 2D Basics (1-2 weeks)
  ├─ Port Mandelbrot shader
  ├─ Implement pan/zoom controls
  └─ Add 5 color presets

Phase 2: Advanced 2D (1 week)
  ├─ Julia Set with constant picker
  ├─ Smooth coloring
  └─ Temporal AA (4-frame jitter)

Phase 3: 3D Exploration (2-3 weeks)
  ├─ Mandelbulb renderer
  ├─ Camera controls
  └─ Raymarching optimization

Phase 4: Polish (1-2 weeks)
  ├─ Spatial SSAA (optional)
  ├─ Perturbation for deep zoom
  └─ Custom formula support
```

---

## Code Extraction Summary

**11 Shader Files Analyzed**:
- 5 × 2D fractals (Mandelbrot, Julia, Koch, Sierpinski×2)
- 5 × 3D fractals (Mandelbulb, Mandelbox, Menger Sponge, Tetrix, Broccoli)
- 1 × Advanced renderer (MV2 - 460 lines, double precision)

**3 Precision Variants** (Giulia):
- Single precision (vec2, fast)
- Double precision (dvec2, slow)
- Low-res double (checkerboard, feedback)

**Utility Library Extracted**:
- 25+ reusable GLSL functions
- Complete SDF primitive set
- Smooth boolean operations
- Color space conversions

---

## Key Insights

### Why Smooth Coloring?
Raw iteration produces harsh bands. Smooth coloring interpolates:
```
smooth_iter = iter + 1 - log₂(log₂(|z|)) / log₂(power)
```

### Why Distance Estimation in 3D?
Ensures consistent ray step sizes across fractal surface:
```
distance = 0.5 * log(r) * r / derivative
```

### Why Perturbation Method?
Overcomes double-precision ceiling (~10¹⁵ zoom):
- Store reference orbit once
- Track local perturbation `delta` with 32-bit floats
- Result: Unlimited zoom depth

### Why Cardioid Skip?
Main features are analytically known:
```
if(|c - 0.25| ≤ ...) skip;  // ~20-30% faster
```

---

## Related Resources

**In this Repository**:
- `FRACTAL_SHADER_TECHNIQUES_CATALOG.md` - Full technical analysis
- `opensource/repos/formula-catalogs/shader-fractals/README.md` - Fractal mathematics
- `opensource/repos/renderers/MV2/` - Advanced renderer reference
- `opensource/Giulia/` - Precision handling example

**External**:
- [Inigo Quilez - SDF primitives](http://iquilezles.org)
- [ShaderToy](https://www.shadertoy.com) - GLSL sandbox
- Mandelbrot set theory documentation

---

**Generated**: February 17, 2025  
**Coverage**: 4 projects, 11+ shader files, 900+ line analysis
