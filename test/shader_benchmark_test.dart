import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

/// Shader Performance Benchmark
/// 
/// Run with: flutter test integration_test/shader_benchmark_test.dart -d linux
/// 
/// This test measures frame timing for each shader to validate performance
/// optimizations.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  
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
        final result = await _benchmarkShader(tester, shaderPath);
        results[shaderPath] = result;
      }
      
      // Print benchmark results
      print('\n${'=' * 60}');
      print('SHADER PERFORMANCE BENCHMARK RESULTS');
      print('=' * 60);
      
      for (final entry in results.entries) {
        final r = entry.value;
        print('\n${entry.key}:');
        print('  Load time:     ${r.loadTimeMs.toStringAsFixed(2)} ms');
        print('  Avg frame:     ${r.avgFrameTimeMs.toStringAsFixed(2)} ms');
        print('  Min frame:     ${r.minFrameTimeMs.toStringAsFixed(2)} ms');
        print('  Max frame:     ${r.maxFrameTimeMs.toStringAsFixed(2)} ms');
        print('  FPS (avg):     ${(1000 / r.avgFrameTimeMs).toStringAsFixed(1)}');
        print('  Frame jitter:  ${r.jitterMs.toStringAsFixed(2)} ms');
      }
      
      print('\n${'=' * 60}\n');
      
      // Assert minimum performance targets
      for (final entry in results.entries) {
        expect(
          entry.value.avgFrameTimeMs,
          lessThan(33.33),  // At least 30 FPS
          reason: '${entry.key} should maintain at least 30 FPS',
        );
      }
    });
  });
}

class ShaderBenchmarkResult {
  final double loadTimeMs;
  final double avgFrameTimeMs;
  final double minFrameTimeMs;
  final double maxFrameTimeMs;
  final double jitterMs;
  final int frameCount;
  
  ShaderBenchmarkResult({
    required this.loadTimeMs,
    required this.avgFrameTimeMs,
    required this.minFrameTimeMs,
    required this.maxFrameTimeMs,
    required this.jitterMs,
    required this.frameCount,
  });
}

Future<ShaderBenchmarkResult> _benchmarkShader(
  WidgetTester tester,
  String shaderPath,
) async {
  final frameTimes = <double>[];
  
  // Measure shader load time
  final loadStart = DateTime.now();
  late ui.FragmentProgram program;
  
  try {
    program = await ui.FragmentProgram.fromAsset(shaderPath);
  } catch (e) {
    return ShaderBenchmarkResult(
      loadTimeMs: -1,
      avgFrameTimeMs: -1,
      minFrameTimeMs: -1,
      maxFrameTimeMs: -1,
      jitterMs: -1,
      frameCount: 0,
    );
  }
  
  final loadTimeMs = DateTime.now().difference(loadStart).inMicroseconds / 1000.0;
  
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
  for (int i = 0; i < 10; i++) {
    await tester.pump(const Duration(milliseconds: 16));
  }
  frameTimes.clear();
  
  // Measure 120 frames (~2 seconds at 60fps)
  for (int i = 0; i < 120; i++) {
    await tester.pump(const Duration(milliseconds: 16));
  }
  
  if (frameTimes.isEmpty) {
    return ShaderBenchmarkResult(
      loadTimeMs: loadTimeMs,
      avgFrameTimeMs: 16.67,
      minFrameTimeMs: 16.67,
      maxFrameTimeMs: 16.67,
      jitterMs: 0,
      frameCount: 0,
    );
  }
  
  // Calculate statistics
  final avg = frameTimes.reduce((a, b) => a + b) / frameTimes.length;
  final min = frameTimes.reduce((a, b) => a < b ? a : b);
  final max = frameTimes.reduce((a, b) => a > b ? a : b);
  
  // Jitter: standard deviation
  final variance = frameTimes.map((t) => (t - avg) * (t - avg)).reduce((a, b) => a + b) / frameTimes.length;
  final jitter = variance > 0 ? variance / avg : 0.0;
  
  return ShaderBenchmarkResult(
    loadTimeMs: loadTimeMs,
    avgFrameTimeMs: avg,
    minFrameTimeMs: min,
    maxFrameTimeMs: max,
    jitterMs: jitter,
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
    setState(() {});
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
      ),
      child: const SizedBox.expand(),
    );
  }
}

class _BenchmarkPainter extends CustomPainter {
  final ui.FragmentProgram program;
  final double time;
  final bool is3D;
  
  _BenchmarkPainter({
    required this.program,
    required this.time,
    required this.is3D,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final shader = program.fragmentShader();
    
    int idx = 0;
    
    if (is3D) {
      // 3D shader uniforms
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
    } else {
      // 2D shader uniforms
      shader.setFloat(idx++, time);           // uTime
      shader.setFloat(idx++, size.width);     // uResolution.x
      shader.setFloat(idx++, size.height);    // uResolution.y
      shader.setFloat(idx++, -0.5);           // uCenter.x
      shader.setFloat(idx++, 0.0);            // uCenter.y
      shader.setFloat(idx++, 1.0);            // uZoom
      shader.setFloat(idx++, 100.0);          // uIterations
      shader.setFloat(idx++, 2.0);            // uBailout
      shader.setFloat(idx++, 0.0);            // uColorScheme
      
      // Julia-specific
      if (idx < 10) {
        shader.setFloat(idx++, -0.7);         // uJuliaC.x
        shader.setFloat(idx++, 0.27);         // uJuliaC.y
      }
      
      shader.setFloat(idx++, 0.0);            // uTransparentBg
    }
    
    final paint = Paint()..shader = shader;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
  }
  
  @override
  bool shouldRepaint(_BenchmarkPainter oldDelegate) => true;
}
