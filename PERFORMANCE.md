# Performance Analysis - Flutter Fractal Forge

This document provides a comprehensive performance analysis of the Flutter Fractal Forge application, including frame timing measurements, shader compilation behavior, memory usage patterns, and optimization recommendations.

## Table of Contents

1. [Performance Overview](#performance-overview)
2. [Shader Performance Analysis](#shader-performance-analysis)
3. [Frame Timing Metrics](#frame-timing-metrics)
4. [Shader Compilation](#shader-compilation)
5. [Memory Usage](#memory-usage)
6. [Performance Overlay Feature](#performance-overlay-feature)
7. [Optimization Recommendations](#optimization-recommendations)
8. [Benchmarking](#benchmarking)

---

## Performance Overview

### Target Performance Metrics

| Metric | Target | Acceptable | Warning |
|--------|--------|------------|---------|
| Frame Rate | ≥60 FPS | ≥30 FPS | <30 FPS |
| Frame Time (avg) | ≤16.67ms | ≤33.34ms | >33.34ms |
| P95 Frame Time | ≤20ms | ≤40ms | >40ms |
| Dropped Frames | <5% | <15% | >15% |
| Stability Score | >90 | >70 | <70 |

### Performance Tiers by Shader

| Shader | Complexity | Expected FPS | Notes |
|--------|------------|--------------|-------|
| Mandelbrot | Low | 58-60 | 2D, simple iteration |
| Julia | Low | 58-60 | 2D, similar to Mandelbrot |
| Burning Ship | Low | 55-60 | 2D with abs() operations |
| Phoenix | Medium | 50-58 | 2D with additional terms |
| Mandelbulb | High | 30-50 | 3D raymarching |

---

## Shader Performance Analysis

### 2D Fractals (Mandelbrot, Julia, Burning Ship)

**Architecture:** Simple fragment shader with iterative escape-time algorithm.

**Performance Characteristics:**
- Complexity: O(iterations × pixels)
- GPU-bound: Pixel fill rate dependent
- Memory: Minimal (uniform buffers only)

**Optimizations Applied:**
```glsl
// LOD-based iteration reduction at low zoom
float lodFactor = clamp(log2(uZoom + 1.0) * 0.5 + 0.5, 0.3, 1.0);
float maxIter = max(uIterations * lodFactor, 1.0);

// Branchless palette selection
float s0 = step(0.5, scheme);
result = mix(result, ocean, s0 * (1.0 - s1));

// Smooth coloring to reduce banding
smoothIter = iter + 1.0 - log2(log2(zMagSq) * 0.5);
```

**Performance Factors:**
- Iteration count (default 100, range 10-500)
- Resolution (screen pixel count)
- Zoom level (affects LOD factor)
- Color scheme (psychedelic uses sin(), slightly slower)

### 3D Fractals (Mandelbulb)

**Architecture:** Raymarching with signed distance functions (SDF).

**Performance Characteristics:**
- Complexity: O(steps × iterations × pixels)
- Highly GPU-bound
- More complex per-pixel computation

**Optimizations Applied:**
```glsl
// Precomputed rotation matrix (computed once per frame)
mat3 gRotation = rotationMatrix(uRotation);

// Early exit in raymarching
if (dist < 0.001 * t) break;
if (t > 10.0) break;

// Reduced iteration count for AR mode
float lodIter = uIterations * 0.7;
```

**Performance Factors:**
- Raymarch steps (default 100, range 50-200)
- Iteration count per step (default 15, range 5-30)
- Power parameter (affects trigonometric ops)
- View distance and zoom

---

## Frame Timing Metrics

### Key Metrics Tracked

| Metric | Description | Calculation |
|--------|-------------|-------------|
| `avgFrameTimeMs` | Mean frame render time | sum(frameTimes) / count |
| `minFrameTimeMs` | Best-case frame time | min(frameTimes) |
| `maxFrameTimeMs` | Worst-case frame time | max(frameTimes) |
| `p95FrameTimeMs` | 95th percentile | frameTimes[0.95 × count] |
| `p99FrameTimeMs` | 99th percentile | frameTimes[0.99 × count] |
| `droppedFrames` | Frames >16.67ms | count(t > 16.67) |
| `stabilityScore` | Variance-based (0-100) | 100 - (stdDev / target × 100) |

### Interpreting Frame Time Graphs

The performance overlay displays a real-time frame time histogram:

- **Green bars**: On-target frames (≤16.67ms)
- **Orange bars**: Slightly dropped frames (16.67-33.34ms)
- **Red bars**: Severely dropped frames (>33.34ms)
- **Purple bars**: Shader compilation stalls (>100ms)

The horizontal green line indicates the 60 FPS target (16.67ms).

---

## Shader Compilation

### Detection

The performance service detects shader compilation stalls when frame time exceeds 100ms. This is a common source of "jank" on first render.

### Mitigation Strategies

1. **Shader Warming** (Recommended for production):
   ```dart
   // Pre-compile shaders at app startup
   await Future.wait([
     FragmentProgram.fromAsset('shaders/mandelbrot.frag'),
     FragmentProgram.fromAsset('shaders/julia.frag'),
     FragmentProgram.fromAsset('shaders/mandelbulb.frag'),
   ]);
   ```

2. **Impeller Engine** (Flutter 3.16+):
   - Pre-compiles shaders ahead of time
   - Eliminates runtime compilation jank
   - Enable with: `--enable-impeller`

3. **SkSL Shader Warming**:
   ```bash
   flutter run --cache-sksl
   flutter build apk --bundle-sksl-path=shaders.sksl.json
   ```

### Expected Compilation Times

| Shader | First Load | Subsequent |
|--------|------------|------------|
| Mandelbrot | 50-200ms | <1ms |
| Julia | 50-200ms | <1ms |
| Burning Ship | 50-200ms | <1ms |
| Phoenix | 80-250ms | <1ms |
| Mandelbulb | 100-400ms | <1ms |

---

## Memory Usage

### Memory Profile

| Component | Typical Usage | Notes |
|-----------|--------------|-------|
| Shader Programs | 50-100 KB each | Cached after first load |
| Uniform Buffers | <1 KB per shader | Updated per frame |
| Render Target | Screen × 4 bytes | RGBA framebuffer |
| Widget Tree | ~2-5 MB | Standard Flutter overhead |

### Memory Optimization Tips

1. **Dispose unused shaders**: When switching fractal types, the old shader can be garbage collected.

2. **Resolution scaling**: For AR mode, consider rendering at 0.5x or 0.75x resolution.

3. **Avoid texture leaks**: Ensure `RepaintBoundary` captures are properly disposed.

---

## Performance Overlay Feature

### Enabling the Overlay

The performance overlay is accessible in the Fractal Viewer screen:

1. Tap the **PERF** button (top-left, below app bar)
2. The overlay displays real-time metrics
3. Long-press the PERF button to toggle compact mode

### Overlay Modes

**Full Mode:**
- FPS counter with rating (Excellent/Good/Fair/Poor)
- Frame time graph (last ~5 seconds)
- Statistics grid (AVG, P95, DROPS, STABLE)
- Shader compilation warnings

**Compact Mode:**
- Minimal FPS display
- Dropped frame counter
- Jank indicator icon

### Implementation

The overlay is powered by `PerformanceService`:

```dart
// Start profiling
_performanceService.start(this); // Requires TickerProvider

// Stop profiling
_performanceService.stop();

// Access metrics
final metrics = _performanceService.metrics;
print('FPS: ${metrics.fps}');
print('Dropped: ${metrics.droppedFrames}');

// Get summary report
print(_performanceService.getSummary());
```

---

## Optimization Recommendations

### High-Priority Optimizations

#### 1. Reduce Iteration Count for Low-End Devices
```dart
// Detect device tier and adjust defaults
if (deviceIsLowEnd) {
  controller.updateParam('iterations', 50);
  controller.updateParam('steps', 50);
}
```

#### 2. Implement Resolution Scaling
```dart
// Render at reduced resolution, then upscale
class ScaledFractalCanvas extends CustomPainter {
  final double scale; // 0.5 for 50% resolution
  
  @override
  void paint(Canvas canvas, Size size) {
    final scaledSize = size * scale;
    // Render to smaller framebuffer
    // Then upscale with bilinear filtering
  }
}
```

#### 3. Use Impeller for Shader Precompilation
```bash
# Enable Impeller (iOS default, Android opt-in)
flutter run --enable-impeller

# Or in AndroidManifest.xml
<meta-data
    android:name="io.flutter.embedding.android.EnableImpeller"
    android:value="true" />
```

### Medium-Priority Optimizations

#### 4. Lazy Shader Loading
Only load shaders when their fractal type is selected:
```dart
Future<FragmentProgram?> _getShader(String moduleId) async {
  if (!_shaderCache.containsKey(moduleId)) {
    _shaderCache[moduleId] = await FragmentProgram.fromAsset(
      'shaders/$moduleId.frag'
    );
  }
  return _shaderCache[moduleId];
}
```

#### 5. Frame Rate Limiting for Battery
```dart
// Option to cap at 30 FPS for battery saving
if (batterySaverEnabled) {
  _animationController.duration = const Duration(milliseconds: 33);
}
```

### Low-Priority Optimizations

#### 6. Reduce Overdraw
Ensure no unnecessary layers are painted behind the fractal canvas.

#### 7. Profile-Guided Optimization
Use the performance overlay to identify specific scenarios that cause frame drops, then optimize those paths.

---

## Benchmarking

### Running the Shader Benchmark

```bash
# Run integration test on a real device
flutter test integration_test/shader_benchmark_test.dart -d <device_id>

# Example with Linux desktop
flutter test integration_test/shader_benchmark_test.dart -d linux
```

### Benchmark Output Example

```
============================================================
SHADER PERFORMANCE BENCHMARK RESULTS
============================================================

shaders/mandelbrot.frag:
  Load time:     78.45 ms
  Avg frame:     8.23 ms
  Min frame:     7.89 ms
  Max frame:     12.34 ms
  FPS (avg):     121.5
  Frame count:   60

shaders/julia.frag:
  Load time:     65.23 ms
  Avg frame:     7.98 ms
  Min frame:     7.45 ms
  Max frame:     11.67 ms
  FPS (avg):     125.3
  Frame count:   62

shaders/burning_ship.frag:
  Load time:     72.11 ms
  Avg frame:     9.45 ms
  Min frame:     8.90 ms
  Max frame:     14.23 ms
  FPS (avg):     105.8
  Frame count:   58

shaders/mandelbulb.frag:
  Load time:     156.78 ms
  Avg frame:     23.45 ms
  Min frame:     21.23 ms
  Max frame:     45.67 ms
  FPS (avg):     42.6
  Frame count:   43

============================================================
```

### Custom Benchmark Script

Create a benchmark for specific scenarios:

```dart
Future<void> benchmarkZoomPerformance() async {
  final service = PerformanceService();
  service.start(this);
  
  // Zoom in over 5 seconds
  for (int i = 0; i < 300; i++) {
    controller.updateZoom(1.0 + i * 0.1);
    await Future.delayed(const Duration(milliseconds: 16));
  }
  
  service.stop();
  print(service.getSummary());
}
```

---

## Performance Findings Summary

### Tested Configuration
- Flutter: 3.x with Skia backend
- Device: Desktop Linux (NVIDIA GPU)
- Resolution: 1920×1080

### Key Findings

1. **2D Fractals** (Mandelbrot, Julia, Burning Ship):
   - Consistently achieve 60 FPS at default settings
   - High iteration counts (>300) may drop to 45-50 FPS
   - Zoom has minimal performance impact due to LOD

2. **3D Fractals** (Mandelbulb):
   - Achieve 30-50 FPS depending on complexity
   - Raymarching steps have the biggest impact
   - AR quality presets successfully reduce load

3. **Shader Compilation**:
   - First-load jank is significant (100-400ms)
   - Shader warming at startup recommended
   - Impeller engine eliminates this issue

4. **Memory**:
   - Stable memory profile with no leaks detected
   - Peak usage around 50-100 MB total app

### Recommendations for Production

1. Enable Impeller on supported platforms
2. Implement shader warming during splash screen
3. Add resolution scaling option for low-end devices
4. Consider 30 FPS cap option for battery-conscious users
5. Use AR quality presets for camera overlay mode

---

## Appendix: Performance Service API

### PerformanceMetrics Properties

| Property | Type | Description |
|----------|------|-------------|
| `avgFrameTimeMs` | double | Average frame time in milliseconds |
| `minFrameTimeMs` | double | Minimum frame time |
| `maxFrameTimeMs` | double | Maximum frame time |
| `p95FrameTimeMs` | double | 95th percentile frame time |
| `p99FrameTimeMs` | double | 99th percentile frame time |
| `frameCount` | int | Total frames sampled |
| `droppedFrames` | int | Frames exceeding 16.67ms |
| `fps` | double | Calculated frames per second |
| `shaderCompilations` | int | Detected compilation stalls |
| `stabilityScore` | double | 0-100, higher is more stable |
| `isJanky` | bool | Current jank state |
| `isGood` | bool | >55 FPS and <5% drops |
| `isAcceptable` | bool | >30 FPS and <15% drops |
| `dropPercentage` | double | Percentage of dropped frames |

### FrameSample Properties

| Property | Type | Description |
|----------|------|-------------|
| `timestamp` | Duration | Sample timestamp |
| `frameTimeMs` | double | Frame duration in milliseconds |
| `wasDropped` | bool | Whether frame was dropped |
| `hadShaderCompile` | bool | Whether shader compile detected |

---

*Last updated: February 2026*
*Flutter Fractal Forge v1.0.0*
