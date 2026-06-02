import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../support/shader_asset_expectations.dart';

void main() {
  const shaderRoot = 'shaders/escape_time_family/experimental_named/';
  const responsibilityFolders = <String>{
    'coupled_orbits',
    'discrete_attractors',
    'physical_simulation',
    'polynomial_variants',
    'rational_singularities',
    'root_finding',
    'transcendental_deformations',
  };
  late final Set<String> declaredShaderAssets;

  setUpAll(() {
    declaredShaderAssets = loadDeclaredShaderAssets();
  });

  test('catalog experimental named shader assets are declared and present', () {
    final assets = escapeTimeShaderAssetsStartingWith(shaderRoot);

    expect(assets, isNotEmpty);
    expectAssetsDeclaredAndExist(assets, declaredShaderAssets,
        fileReason: 'file must exist');
  });

  test('catalog experimental named shader assets are grouped by responsibility',
      () {
    final assets = escapeTimeShaderAssetsStartingWith(shaderRoot);

    expect(assets, isNotEmpty);
    for (final asset in assets) {
      final relativePath = asset.substring(shaderRoot.length);
      expect(relativePath, contains('/'),
          reason: '$asset must not stay at the experimental_named root');
      expect(responsibilityFolders, contains(relativePath.split('/').first),
          reason:
              '$asset must use an experimental_named responsibility folder');
    }
  });

  test('experimental named root has no orphan shader files', () {
    final rootShaderFiles = Directory(shaderRoot)
        .listSync()
        .whereType<File>()
        .where((file) => file.path.endsWith('.frag'))
        .map((file) => file.uri.pathSegments.last)
        .toList()
      ..sort();

    expect(rootShaderFiles, isEmpty);
  });
}
