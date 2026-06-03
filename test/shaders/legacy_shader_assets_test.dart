import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'support/shader_asset_expectations.dart';

const legacyShaderAssetsByResponsibility = <String, List<String>>{
  'diagnostics': [
    'mandelbrot.frag',
    'mandelbrot_hardgrad.frag',
    'mandelbrot_simple.frag',
  ],
  'escape_time': [
    'burning_ship.frag',
    'julia.frag',
    'mandel_step_escape.frag',
    'mandel_step_smooth.frag',
    'mandelbrot_et.frag',
    'mandelbrot_tex.frag',
    'phoenix.frag',
  ],
  'precision': [
    'mandelbrot_df2.frag',
  ],
  'raymarched_3d': [
    'mandelbulb.frag',
  ],
};

List<String> expectedLegacyShaderAssets() {
  return [
    for (final responsibility in legacyShaderAssetsByResponsibility.entries)
      for (final fileName in responsibility.value)
        'shaders/legacy/${responsibility.key}/$fileName',
  ]..sort();
}

void main() {
  group('legacy shader assets', () {
    test('declared legacy asset paths exist under responsibility folders', () {
      final declaredShaderAssets = loadDeclaredShaderAssets();
      final declaredLegacyShaderAssets = declaredShaderAssets
          .where((asset) => asset.startsWith('shaders/legacy/'))
          .toList()
        ..sort();
      final legacyShaderAssets = expectedLegacyShaderAssets();

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
