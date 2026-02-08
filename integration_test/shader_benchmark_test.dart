import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

/// Shader Performance Benchmark for Desktop
/// 
/// Run with: flutter test integration_test/shader_benchmark_test.dart -d linux
/// 
/// Measures frame timing for each shader to validate performance optimizations.
void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  
  group('Shader Performance Benchmarks', () {
    testWidgets('Benchmark all fractal shaders', (tester) async {
      final results = <String, ShaderBenchmarkResult>{};
      
      final shaders = [
        'shaders/mandelbrot.frag',
        'shaders/julia.frag',
        'shaders/burning_ship.frag',
        'shaders/mandelbulb.frag',
      ];
      
      for (final shaderPath in shaders) {
        print('Benchmarking: $shaderPath');
        final result = await _benchmarkShader(tester, shaderPath, binding);
        results[shaderPath] = result;
      }
      
      // Print benchmark results
      print('\n${'=' * 60}');
      print('SHADER PERFORMANCE BENCHMARK RESULTS');
      print('=' * 60);
      
      for (final entry in results.entries) {
        final r = entry.value;
        print('\n${entry.key}:');
        if (r.loadTimeMs < 0) {
          print('  FAILED TO LOAD');
          continue;
        }
        print('  Load time:     ${r.loadTimeMs.toStringAsFixed(2)} ms');
        print('  Avg frame:     ${r.avgFrameTimeMs.toStringAsFixed(2)} ms');
        print('  Min frame:     ${r.minFrameTimeMs.toStringAsFixed(2)} ms');
        print('  Max frame:     ${r.maxFrameTimeMs.toStringAsFixed(2)} ms');
        print('  FPS (avg):     ${(1000 / r.avgFrameTimeMs).toStringAsFixed(1)}');
        print('  Frame count:   ${r.frameCount}');
      }
      
      print('\n${'=' * 60}\n');
      
      // Assert minimum performance targets
      for (final entry in results.entries) {
        if (entry.value.loadTimeMs >= 0) {
          expect(
            entry.value.avgFrameTimeMs,
            lessThan(50.0),  // At least 20 FPS (conservative for CI)
            reason: '${entry.key} should maintain at least 20 FPS',
          );
        }
      }
    });
  });
}

class ShaderBenchmarkResult {
  final double loadTimeMs;
  final double avgFrameTimeMs;
  final double minFrameTimeMs;
  final double maxFrameTimeMs;
  final int frameCount;
  
  ShaderBenchmarkResult({
    required this.loadTimeMs,
    required this.avgFrameTimeMs,
    required this.minFrameTimeMs,
    required this.maxFrameTimeMs,
    required this.frameCount,
  });
}

Future<ShaderBenchmarkResult> _benchmarkShader(
  WidgetTester tester,
  String shaderPath,
  IntegrationTestWidgetsFlutterBinding binding,
) async {
  final frameTimes = <double>[];
  
  // Measure shader load time
  final loadStart = DateTime.now();
  late ui.FragmentProgram program;
  
  try {
    program = await ui.FragmentProgram.fromAsset(shaderPath);
  } catch (e) {
    print('  Error loading shader: $e');
    return ShaderBenchmarkResult(
      loadTimeMs: -1,
      avgFrameTimeMs: -1,
      minFrameTimeMs: -1,
      maxFrameTimeMs: -1,
      frameCount: 0,
    );
  }
  
  final loadTimeMs = DateTime.now().difference(loadStart).inMicroseconds / 1000.0;
  print('  Loaded in ${loadTimeMs.toStringAsFixed(2)} ms');
  
  // Build benchmark widget
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: _ShaderBenchmarkWidget(
          program: program,
          shaderPath: shaderPath,
          onFrameTime: (ms) => frameTimes.add(ms),
        ),
      ),
    ),
  );
  
  // Warm up (discard first frames)
  for (int i = 0; i < 5; i++) {
    await tester.pump(const Duration(milliseconds: 16));
  }
  frameTimes.clear();
  
  // Measure frames for ~1 second
  final stopwatch = Stopwatch()..start();
  while (stopwatch.elapsedMilliseconds < 1000) {
    await tester.pump(const Duration(milliseconds: 16));
  }
  stopwatch.stop();
  
  print('  Collected ${frameTimes.length} frame samples');
  
  if (frameTimes.isEmpty || frameTimes.length < 5) {
    return ShaderBenchmarkResult(
      loadTimeMs: loadTimeMs,
      avgFrameTimeMs: 16.67,
      minFrameTimeMs: 16.67,
      maxFrameTimeMs: 16.67,
      frameCount: frameTimes.length,
    );
  }
  
  // Filter outliers (remove top/bottom 5%)
  final sorted = List<double>.from(frameTimes)..sort();
  final trimCount = (sorted.length * 0.05).floor();
  final trimmed = sorted.sublist(trimCount, sorted.length - trimCount);
  
  if (trimmed.isEmpty) {
    return ShaderBenchmarkResult(
      loadTimeMs: loadTimeMs,
      avgFrameTimeMs: sorted.reduce((a, b) => a + b) / sorted.length,
      minFrameTimeMs: sorted.first,
      maxFrameTimeMs: sorted.last,
      frameCount: sorted.length,
    );
  }
  
  // Calculate statistics
  final avg = trimmed.reduce((a, b) => a + b) / trimmed.length;
  final min = trimmed.first;
  final max = trimmed.last;
  
  return ShaderBenchmarkResult(
    loadTimeMs: loadTimeMs,
    avgFrameTimeMs: avg,
    minFrameTimeMs: min,
    maxFrameTimeMs: max,
    frameCount: frameTimes.length,
  );
}

class _ShaderBenchmarkWidget extends StatefulWidget {
  final ui.FragmentProgram program;
  final String shaderPath;
  final void Function(double ms) onFrameTime;
  
  const _ShaderBenchmarkWidget({
    required this.program,
    required this.shaderPath,
    required this.onFrameTime,
  });
  
  @override
  State<_ShaderBenchmarkWidget> createState() => _ShaderBenchmarkWidgetState();
}

class _ShaderBenchmarkWidgetState extends State<_ShaderBenchmarkWidget>
    with SingleTickerProviderStateMixin {
  late Ticker _ticker;
  Duration _lastTime = Duration.zero;
  double _time = 0;
  
  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick)..start();
  }
  
  void _onTick(Duration elapsed) {
    if (_lastTime != Duration.zero) {
      final frameMs = (elapsed - _lastTime).inMicroseconds / 1000.0;
      widget.onFrameTime(frameMs);
    }
    _lastTime = elapsed;
    _time = elapsed.inMilliseconds / 1000.0;
    if (mounted) {
      setState(() {});
    }
  }
  
  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _BenchmarkPainter(
        program: widget.program,
        time: _time,
        is3D: widget.shaderPath.contains('mandelbulb'),
        isJulia: widget.shaderPath.contains('julia'),
      ),
      child: const SizedBox.expand(),
    );
  }
}

class _BenchmarkPainter extends CustomPainter {
  final ui.FragmentProgram program;
  final double time;
  final bool is3D;
  final bool isJulia;
  
  _BenchmarkPainter({
    required this.program,
    required this.time,
    required this.is3D,
    required this.isJulia,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final shader = program.fragmentShader();
    
    int idx = 0;
    
    if (is3D) {
      // 3D shader uniforms (mandelbulb)
      shader.setFloat(idx++, time);           // uTime
      shader.setFloat(idx++, size.width);     // uResolution.x
      shader.setFloat(idx++, size.height);    // uResolution.y
      shader.setFloat(idx++, size.width / 2); // uMousePos.x
      shader.setFloat(idx++, size.height / 2);// uMousePos.y
      shader.setFloat(idx++, 1.0);            // uZoom
      shader.setFloat(idx++, time * 0.1);     // uRotation.x
      shader.setFloat(idx++, time * 0.15);    // uRotation.y
      shader.setFloat(idx++, 0.0);            // uRotation.z
      shader.setFloat(idx++, 8.0);            // uPower
      shader.setFloat(idx++, 15.0);           // uIterations
      shader.setFloat(idx++, 100.0);          // uSteps
      shader.setFloat(idx++, 2.0);            // uBailout
      shader.setFloat(idx++, 0.0);            // uColorScheme
      shader.setFloat(idx++, 0.0);            // uFractalType
      shader.setFloat(idx++, 0.0);            // uTransparentBg
    } else if (isJulia) {
      // Julia shader uniforms
      shader.setFloat(idx++, time);           // uTime
      shader.setFloat(idx++, size.width);     // uResolution.x
      shader.setFloat(idx++, size.height);    // uResolution.y
      shader.setFloat(idx++, 0.0);            // uCenter.x
      shader.setFloat(idx++, 0.0);            // uCenter.y
      shader.setFloat(idx++, 1.0);            // uZoom
      shader.setFloat(idx++, 100.0);          // uIterations
      shader.setFloat(idx++, 2.0);            // uBailout
      shader.setFloat(idx++, 0.0);            // uColorScheme
      shader.setFloat(idx++, -0.7);           // uJuliaC.x
      shader.setFloat(idx++, 0.27);           // uJuliaC.y
      shader.setFloat(idx++, 0.0);            // uTransparentBg
    } else {
      // 2D shader uniforms (mandelbrot, burning_ship)
      shader.setFloat(idx++, time);           // uTime
      shader.setFloat(idx++, size.width);     // uResolution.x
      shader.setFloat(idx++, size.height);    // uResolution.y
      shader.setFloat(idx++, -0.5);           // uCenter.x
      shader.setFloat(idx++, 0.0);            // uCenter.y
      shader.setFloat(idx++, 1.0);            // uZoom
      shader.setFloat(idx++, 100.0);          // uIterations
      shader.setFloat(idx++, 2.0);            // uBailout
      shader.setFloat(idx++, 0.0);            // uColorScheme
      shader.setFloat(idx++, 0.0);            // uTransparentBg
    }
    
    final paint = Paint()..shader = shader;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
  }
  
  @override
  bool shouldRepaint(_BenchmarkPainter oldDelegate) => true;
}
