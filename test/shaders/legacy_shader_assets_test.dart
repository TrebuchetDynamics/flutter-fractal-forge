import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'support/shader_asset_expectations.dart';

void main() {
  group('legacy shader assets', () {
    const legacyShaderAssets = <String>[
      'shaders/legacy/diagnostics/mandelbrot.frag',
      'shaders/legacy/diagnostics/mandelbrot_hardgrad.frag',
      'shaders/legacy/diagnostics/mandelbrot_simple.frag',
      'shaders/legacy/escape_time/burning_ship.frag',
      'shaders/legacy/escape_time/julia.frag',
      'shaders/legacy/escape_time/mandel_step_escape.frag',
      'shaders/legacy/escape_time/mandel_step_smooth.frag',
      'shaders/legacy/escape_time/mandelbrot_et.frag',
      'shaders/legacy/escape_time/mandelbrot_tex.frag',
      'shaders/legacy/escape_time/phoenix.frag',
      'shaders/legacy/precision/mandelbrot_df2.frag',
      'shaders/legacy/raymarched_3d/mandelbulb.frag',
    ];

    test('declared legacy asset paths exist under responsibility folders', () {
      final declaredShaderAssets = loadDeclaredShaderAssets();
      final declaredLegacyShaderAssets = declaredShaderAssets
          .where((asset) => asset.startsWith('shaders/legacy/'))
          .toList()
        ..sort();

      expect(declaredLegacyShaderAssets, orderedEquals(legacyShaderAssets));
      expectAssetsDeclaredAndExist(
        legacyShaderAssets,
        declaredShaderAssets,
        fileReason: 'must stay at its declared legacy responsibility path',
      );
    });

    test('legacy root contains no fragment shaders', () {
      final rootFragmentFiles = Directory('shaders/legacy')
          .listSync()
          .whereType<File>()
          .where((file) => file.path.endsWith('.frag'))
          .map((file) => file.uri.pathSegments.last)
          .toList()
        ..sort();

      expect(
        rootFragmentFiles,
        isEmpty,
        reason: 'legacy shaders belong in responsibility subfolders, not root',
      );
    });
  });
}
