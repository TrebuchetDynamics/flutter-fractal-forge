// ignore_for_file: avoid_print
// ignore_for_file: dangling_library_doc_comments
/// Diagnostic test to verify 3D shader compilation.
///
/// Run this test to verify that 3D fractal shaders can be loaded:
///   flutter test test/shader_3d_diagnostic_test.dart
///
/// This test attempts to load each 3D ray-marched shader and reports
/// success/failure with timing information.

import 'dart:ui' as ui;

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('3D Shader Compilation Diagnostic', () {
    // All 3D ray-marched shaders from raymarched_3d_catalog.dart
    final List<String> shaderAssets = [
      'shaders/kifs_menger_gpu.frag',
      'shaders/kifs_sierpinski_tetra_gpu.frag',
      'shaders/kifs_koch_fold_gpu.frag',
      'shaders/kifs_snowflake_fold_gpu.frag',
      'shaders/quaternion_julia_3d_gpu.frag',
      'shaders/dual_quaternion_julia_gpu.frag',
      'shaders/mandelbox_shape_inversion_gpu.frag',
      'shaders/inversive_limit_set_3d_gpu.frag',
      'shaders/mandelbulb_time_modulated_gpu.frag',
      // Standalone 3D modules
      'shaders/mandelbulb.frag',
      'shaders/mandelbox_3d_gpu.frag',
      'shaders/menger_sponge_gpu.frag',
      'shaders/menger_3d_slice_gpu.frag',
      'shaders/quaternion_julia_2d_gpu.frag',
    ];

    for (final asset in shaderAssets) {
      test('loads $asset', () async {
        final stopwatch = Stopwatch()..start();
        try {
          final program = await ui.FragmentProgram.fromAsset(asset);
          stopwatch.stop();
          print('[OK] $asset compiled in ${stopwatch.elapsedMilliseconds}ms');
          expect(program, isNotNull);
        } catch (e) {
          stopwatch.stop();
          print(
              '[FAIL] $asset failed after ${stopwatch.elapsedMilliseconds}ms: $e');
          rethrow;
        }
      }, timeout: const Timeout(Duration(seconds: 60)));
    }
  });
}
