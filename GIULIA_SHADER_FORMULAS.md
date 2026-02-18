# Giulia Fractal Shaders - Quick Reference & Copy-Paste Formulas

Direct extraction of all mathematical formulas and shader code from the Giulia project, ready for Flutter implementation.

---

## 1. COMPLEX NUMBER ARITHMETIC (Core Math)

### Magnitude / Modulus
```glsl
// Returns |a + bi| = sqrt(a² + b²)
float magnitude(vec2 z) {
    return sqrt(z.x * z.x + z.y * z.y);
}

// For double precision
double magnitude(dvec2 z) {
    return sqrt(z.x * z.x + z.y * z.y);
}
```

### Complex Multiplication: (a+bi)(c+di) = (ac-bd) + (ad+bc)i
```glsl
vec2 product(vec2 a, vec2 b) {
    return vec2(
        a.x * b.x - a.y * b.y,
        a.x * b.y + a.y * b.x
    );
}

// Double precision version
dvec2 product(dvec2 a, dvec2 b) {
    return dvec2(
        a.x * b.x - a.y * b.y,
        a.x * b.y + a.y * b.x
    );
}
```

### Complex Addition
```glsl
vec2 add(vec2 a, vec2 b) {
    return vec2(a.x + b.x, a.y + b.y);
}
```

---

## 2. ITERATION KERNELS

### Basic Mandelbrot/Julia Iterator

**Single Precision**:
```glsl
// Returns iteration count at escape
int iterate_mandelbrot(vec2 z, vec2 c, int max_iterations, float escape_threshold) {
    int iter = 0;
    while (iter < max_iterations && magnitude(z) < escape_threshold) {
        z = product(z, z) + c;  // z = z² + c
        iter++;
    }
    return iter;
}
```

**Double Precision**:
```glsl
int iterate_mandelbrot(dvec2 z, dvec2 c, int max_iterations, float escape_threshold) {
    int iter = 0;
    while (iter < max_iterations && magnitude(z) < escape_threshold) {
        z = product(z, z) + c;
        iter++;
    }
    return iter;
}
```

### Variable Exponent Iterator (z^n + c)

**Single Precision**:
```glsl
int iterate_power(vec2 z, vec2 c, int max_iterations, float escape_threshold, uint power) {
    int iter = 0;
    while (iter < max_iterations && magnitude(z) < escape_threshold) {
        // Compute z^power by repeated squaring
        vec2 result = z;
        for (uint i = 1u; i < power; i++) {
            result = product(result, z);
        }
        z = result + c;
        iter++;
    }
    return iter;
}
```

**Double Precision**:
```glsl
int iterate_power(dvec2 z, dvec2 c, int max_iterations, float escape_threshold, uint power) {
    int iter = 0;
    while (iter < max_iterations && magnitude(z) < escape_threshold) {
        dvec2 result = z;
        for (uint i = 1u; i < power; i++) {
            result = product(result, z);
        }
        z = result + c;
        iter++;
    }
    return iter;
}
```

### Giulia's Original Loop (as written - note the off-by-one behavior)
```glsl
// From single_precision.shader - note: exponent-1 iterations
int mandebrot_set_degree(vec2 z, vec2 c, int max_steps, float threshold, uint exponent) {
    int index = 0;
    while (index < max_steps && magnitude(z) < threshold) {
        for(int i = 1; i < exponent; i++) {
            z = product(z, z);  // This runs exponent-1 times
        }
        z = z + c;
        index++;
    }
    return index;
}
```

---

## 3. COLOR ALGORITHMS

### HSV to RGB Conversion

```glsl
// Standard HSV hexagonal sector algorithm
// Input: vec3(hue [0..1], saturation [0..1], value [0..1])
// Output: vec3(red, green, blue) in [0..1]
vec3 hsv2rgb(vec3 hsv) {
    vec4 K = vec4(1.0, 2.0/3.0, 1.0/3.0, 3.0);
    vec3 p = abs(fract(hsv.xxx + K.xyz) * 6.0 - K.www);
    return hsv.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), hsv.y);
}

// Alternative: Using built-in if more readable
vec3 hsv2rgb_verbose(vec3 hsv) {
    float h = hsv.x;
    float s = hsv.y;
    float v = hsv.z;

    float c = v * s;
    float x = c * (1.0 - abs(mod(h * 6.0, 2.0) - 1.0));
    float m = v - c;

    vec3 rgb;
    if (h < 1.0/6.0) rgb = vec3(c, x, 0.0);
    else if (h < 2.0/6.0) rgb = vec3(x, c, 0.0);
    else if (h < 3.0/6.0) rgb = vec3(0.0, c, x);
    else if (h < 4.0/6.0) rgb = vec3(0.0, x, c);
    else if (h < 5.0/6.0) rgb = vec3(x, 0.0, c);
    else rgb = vec3(c, 0.0, x);

    return rgb + vec3(m, m, m);
}
```

### Normalized Iteration Coloring

```glsl
// Maps iteration count [0..max_iter] to color
vec3 color_from_iterations(int iterations, int max_iterations) {
    float normalized = float(iterations) / float(max_iterations);
    // Now use normalized [0..1] for color schemes below
    return normalized * vec3(1.0);  // Grayscale
}
```

### Giulia's 5 Color Presets

```glsl
vec3 apply_color_preset(float normalized_iterations, int preset) {
    switch(preset) {
        case 1:
            // Grayscale
            return hsv2rgb(vec3(1.0, 0.0, normalized_iterations));
        case 2:
            // Inverted grayscale
            return hsv2rgb(vec3(1.0, 0.0, 1.0 - normalized_iterations));
        case 3:
            // Hue inverted with iteration-based saturation
            return hsv2rgb(vec3(1.0 - normalized_iterations, normalized_iterations, 1.0 - normalized_iterations));
        case 4:
            // Inverse relationship
            return hsv2rgb(vec3(1.0 - normalized_iterations, 1.0 - normalized_iterations, normalized_iterations));
        case 5:
            // Hue follows iteration count
            return hsv2rgb(vec3(normalized_iterations, 1.0 - normalized_iterations, 1.0 - normalized_iterations));
        default:
            return vec3(0.0);
    }
}
```

---

## 4. COORDINATE TRANSFORMATION

### Pixel to Complex Plane

```glsl
// Given screen position (gl_FragCoord), map to complex plane
// Inputs:
//   gl_FragCoord: screen pixel coordinate (origin bottom-left for OpenGL)
//   bottom_left: complex number at screen bottom-left
//   range_x: horizontal extent in complex plane
//   range_y: vertical extent (usually = range_x for 1:1 aspect)
//   render_offset: pixel offset for split-screen (e.g., 1000 for right half)
//   render_resolution: resolution in pixels (e.g., 1000 for half of 2000×1000)

vec2 screen_to_complex(vec2 screen_pos, vec2 bottom_left, float range_x, float range_y,
                       vec2 render_offset, vec2 render_resolution) {
    // Normalize to [0..1] within the rendered region
    vec2 normalized = (screen_pos - render_offset) / render_resolution;

    // Scale to complex plane extent
    return bottom_left + vec2(
        range_x * normalized.x,
        range_y * normalized.y
    );
}

// Simplified version for full-screen rendering
vec2 screen_to_complex_simple(vec2 pixel_pos, vec2 center, float range_x, float aspect_ratio) {
    vec2 normalized = pixel_pos / vec2(1000.0);  // Hardcoded resolution
    return center + vec2(
        range_x * normalized.x,
        range_x * aspect_ratio * normalized.y
    );
}
```

### Complex Plane to Screen (for cursor rendering)

```glsl
// Given a complex number, find screen position
vec2 complex_to_screen(vec2 complex_pos, vec2 bottom_left, float range_x,
                       vec2 render_resolution) {
    vec2 relative = complex_pos - bottom_left;
    return vec2(
        (relative.x / range_x) * render_resolution.x,
        (relative.y / range_x) * render_resolution.y  // Assumes 1:1 aspect
    );
}
```

---

## 5. ZOOM & PAN CALCULATIONS

### Zoom In (Scroll Up)
```glsl
// Center zoom on cursor position
float new_range = range / 2.0;
vec2 new_center = center + vec2(new_range / 2.0, new_range * aspect / 2.0);
```

**In C++**:
```cpp
range_x /= 2.0;
position.real += range_x / 2.0;
position.imaginary += range_x * aspect_ratio / 2.0;
```

### Zoom Out (Scroll Down)
```cpp
range_x *= 2.0;
position.real -= range_x / 4.0;
position.imaginary -= range_x * aspect_ratio / 4.0;
```

### Pan (Drag with Spacebar)
```cpp
// delta = current_mouse - anchor (in screen pixels)
position.real -= (range_x * delta.x) / WIDTH * 2.0;  // 2.0 because left half is half width
position.imaginary += (range_x * aspect_ratio * delta.y) / HEIGHT;
```

---

## 6. ESCAPE THRESHOLDS & PARAMETERS

### Standard Values Used in Giulia

```glsl
const float ESCAPE_RADIUS = 4.0;           // Magnitude threshold
const int DEFAULT_ITERATIONS = 32;         // Initial iteration count
const uint DEFAULT_EXPONENT = 2u;          // Power for z^n + c
const float DEFAULT_ASPECT_RATIO = 1.0;    // Square pixels
const vec2 MANDELBROT_CENTER = vec2(-2.2, -1.5);
const vec2 JULIA_CENTER = vec2(-1.41, -1.53);
const float DEFAULT_RANGE = 3.0;           // complex plane units
```

### Why 4.0?
For escape iteration, we check `|z| < 4` because:
- For z^2 + c, if |z| ≥ 2 and iterating, |z| → ∞
- Using 4.0 gives extra safety margin and matches Mandelbrot convention
- Higher values (8-16) may include faint exterior coloring
- Lower values (2-3) may clip interesting boundary details

---

## 7. COMPLETE FRAGMENT SHADER TEMPLATE

### Minimal Working Shader

```glsl
#version 330 core

out vec4 FragColor;

// Uniforms (from CPU)
uniform dvec2 center;              // Complex plane center
uniform float range_x;             // Horizontal extent
uniform uint iterations;           // Max iteration count
uniform uint exponent;             // Polynomial power
uniform int color_preset;          // Which color scheme

// Constants
const float ESCAPE = 4.0;

// Helper functions
double magnitude(dvec2 z) {
    return sqrt(z.x * z.x + z.y * z.y);
}

dvec2 product(dvec2 a, dvec2 b) {
    return dvec2(a.x * b.x - a.y * b.y, a.x * b.y + a.y * b.x);
}

vec3 hsv2rgb(vec3 c) {
    vec4 K = vec4(1.0, 2.0/3.0, 1.0/3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

uint iterate(dvec2 z, dvec2 c) {
    uint iter = 0u;
    while (iter < iterations && magnitude(z) < ESCAPE) {
        dvec2 z_power = z;
        for (uint i = 1u; i < exponent; i++) {
            z_power = product(z_power, z);
        }
        z = z_power + c;
        iter++;
    }
    return iter;
}

void main() {
    // Map pixel to complex plane
    vec2 pixel = gl_FragCoord.xy / vec2(1000.0);  // Adjust to actual resolution
    dvec2 z = center + dvec2(
        range_x * pixel.x,
        range_x * pixel.y
    );

    // For Julia set, z is the variable and c is fixed (uniform)
    // For Mandelbrot, c = z
    dvec2 c = z;  // Change to uniform for Julia

    uint iter = iterate(dvec2(0.0), c);
    float norm = float(iter) / float(iterations);

    // Color mapping
    vec3 color;
    if (color_preset == 1) {
        color = hsv2rgb(vec3(1.0, 0.0, norm));
    } else if (color_preset == 2) {
        color = hsv2rgb(vec3(1.0, 0.0, 1.0 - norm));
    } else {
        color = vec3(norm);  // Grayscale fallback
    }

    FragColor = vec4(color, 1.0);
}
```

---

## 8. KNOWN BUGS IN GIULIA CODE

### Bug 1: Shader Syntax Error
**File**: `single_precision.shader`, line 75
```glsl
// WRONG:
normalized_coord.x /= render_resolution.x * 1,024;  // comma!

// CORRECT:
normalized_coord.x /= render_resolution.x * 1.024;
```

### Bug 2: Exponent Loop Off-by-One
**File**: `single_precision.shader`, line 49-50
```glsl
// Current (buggy):
for(int i = 1; i < exponent; i++) {
    z = product(z, z);  // Runs exponent-1 times
}

// For exponent=2: z² (correct by luck)
// For exponent=3: z⁴ (wrong, should be z³)
// For exponent=4: z⁸ (wrong, should be z⁴)

// CORRECT:
for(uint i = 0u; i < exponent - 1u; i++) {
    z = product(z, z);
}
// Or:
for(uint i = 1u; i < exponent; i++) {
    z = product(z, z);
    // Still z^i*2 but... actually simpler:
}

// SIMPLEST (correct):
vec2 result = z;
for(uint i = 1u; i < exponent; i++) {
    result = product(result, z);  // result = z^(i+1)
}
z = result + c;
```

---

## 9. PERFORMANCE-CRITICAL SECTIONS

### Hot Path (executed per-fragment)
```glsl
// This runs 1000×1000 = 1M times per frame
while (iter < max_iter && magnitude(z) < escape_threshold) {
    z = product(z, z) + c;
    iter++;
}
```

**Optimization opportunities**:
1. Unroll loop if max_iter is small (32)
2. Use squared magnitude to avoid sqrt: `magnitude_squared(z) < 16.0`
3. Early exit if z becomes huge (> 1e6)

### Magnitude Optimization
```glsl
// ORIGINAL (with sqrt):
float magnitude(vec2 z) {
    return sqrt(z.x * z.x + z.y * z.y);
}

// OPTIMIZED (no sqrt for threshold check):
float magnitude_squared(vec2 z) {
    return z.x * z.x + z.y * z.y;
}

// Use in iteration:
while (iter < max_iter && magnitude_squared(z) < 16.0) {  // 4.0²
    ...
}
```

---

## 10. TEST VALUES & EXPECTED OUTPUTS

### Mandelbrot Set
- **Center**: (-0.75, 0)
- **Interesting region**: real ∈ [-2, 1], imag ∈ [-1.25, 1.25]
- **Deep zoom target**: (-0.7469, 0.1102) + ε for Seahorse Valley

### Julia Set (c = -0.7 + 0.27015i)
- **Interesting**: Swirling tendrils, high contrast

### Julia Set (c = -0.4 + 0.6i)
- **Interesting**: "Spiral" pattern

### Iteration Color Test
- At boundary between set and exterior, iter → max_iter/2
- Deep interior (set): iter = max_iter
- Far exterior: iter ≈ 2-4

### HSV Color Test
```
hsv2rgb(vec3(0.0, 1.0, 1.0)) = vec3(1.0, 0.0, 0.0)  // Red
hsv2rgb(vec3(1.0, 0.0, 0.5)) = vec3(0.5, 0.5, 0.5)  // Gray
hsv2rgb(vec3(0.5, 1.0, 1.0)) = vec3(0.0, 1.0, 1.0)  // Cyan
```

---

## 11. PLATFORM-SPECIFIC CONSIDERATIONS

### Desktop (OpenGL 4.0+)
- Use `dvec2`, `double` for precision
- Use `layout` qualifiers
- Use `#version 400 core`

### Mobile (OpenGL ES 3.0)
- No `double` type - use `vec2` + precision hints
- Use `mediump` or `highp` qualifiers
- Use `#version 300 es`
- Iteration limits may be lower (16-32 instead of 256)

### Flutter Shaders
- Likely GLSL ES 1.0 or 3.0 dialect
- Check Flutter documentation for available precisions
- May need to split double-precision into pair of floats (4D vector)

---

## 12. OPEN QUESTIONS FOR FLUTTER PORT

1. **Framebuffer resolution**: Is it dynamic or fixed?
2. **Precision**: Can Flutter support `double`/64-bit in shaders?
3. **Uniform passing**: How to set complex numbers (2D vectors)?
4. **Interaction**: How to handle zoom/pan from Dart?
5. **Color output**: Does Flutter expect RGB or RGBA?
6. **Coordinate system**: Is origin top-left or bottom-left?

---

This reference consolidates all formulas, shader code, and implementation details from Giulia. Use it as a direct source for implementing fractal rendering in your Flutter GPU shader application.
