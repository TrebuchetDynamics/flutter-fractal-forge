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
      'shaders/ifs_and_geometric/raymarched_3d/kifs_menger_gpu.frag',
      'shaders/ifs_and_geometric/raymarched_3d/kifs_sierpinski_tetra_gpu.frag',
      'shaders/ifs_and_geometric/raymarched_3d/kifs_koch_fold_gpu.frag',
      'shaders/ifs_and_geometric/raymarched_3d/kifs_snowflake_fold_gpu.frag',
      'shaders/3d_and_hypercomplex/raymarched_volumes/quaternion_julia_3d_gpu.frag',
      'shaders/3d_and_hypercomplex/raymarched_volumes/dual_quaternion_julia_gpu.frag',
      'shaders/3d_and_hypercomplex/raymarched_volumes/mandelbox_shape_inversion_gpu.frag',
      'shaders/ifs_and_geometric/raymarched_3d/inversive_limit_set_3d_gpu.frag',
      'shaders/3d_and_hypercomplex/raymarched_volumes/mandelbulb_time_modulated_gpu.frag',
      'shaders/3d_and_hypercomplex/raymarched_volumes/amazing_box_gpu.frag',
      'shaders/3d_and_hypercomplex/raymarched_volumes/bulbils_gpu.frag',
      'shaders/3d_and_hypercomplex/raymarched_volumes/hartverdrahtet_gpu.frag',
      'shaders/3d_and_hypercomplex/raymarched_volumes/tglad_formula_gpu.frag',
      // Standalone 3D modules
      'shaders/legacy/raymarched_3d/mandelbulb.frag',
      'shaders/3d_and_hypercomplex/raymarched_volumes/mandelbox_3d_gpu.frag',
      'shaders/ifs_and_geometric/self_similar_sets/menger_sponge_gpu.frag',
      'shaders/ifs_and_geometric/self_similar_sets/menger_3d_slice_gpu.frag',
      'shaders/3d_and_hypercomplex/hypercomplex_escape_time/quaternion_julia_2d_gpu.frag',
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
