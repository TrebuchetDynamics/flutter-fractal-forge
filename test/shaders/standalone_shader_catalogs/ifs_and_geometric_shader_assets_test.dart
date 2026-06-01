import 'package:flutter_fractals/core/modules/builders/escape_time_catalog.dart';
import 'package:flutter_fractals/core/modules/builders/raymarched_3d_catalog.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/shader_asset_expectations.dart';

void main() {
  const shaderRoot = 'shaders/ifs_and_geometric/';
  late final Set<String> declaredShaderAssets;

  setUpAll(() {
    declaredShaderAssets = loadDeclaredShaderAssets();
  });

  test('declared IFS and geometric shader assets exist on disk', () {
    final ifsAssets =
        declaredShaderAssetsStartingWith(declaredShaderAssets, shaderRoot);

    expect(ifsAssets, isNotEmpty);
    expectAssetsExist(ifsAssets);
  });

  test('catalog IFS and geometric shader assets are declared in pubspec', () {
    final catalogAssets = [
      ...escapeTimeCatalog.map((config) => config.shaderAsset),
      ...raymarched3DCatalog.map((module) => module.shaderAsset),
    ].where((asset) => asset.startsWith(shaderRoot)).toList()
      ..sort();

    expect(catalogAssets, isNotEmpty);
    expectAssetsDeclaredAndExist(catalogAssets, declaredShaderAssets);
  });
}
