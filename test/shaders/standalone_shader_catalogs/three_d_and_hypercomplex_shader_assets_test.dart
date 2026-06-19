import 'package:flutter_fractals/core/modules/builders/raymarched_3d_catalog.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/shader_asset_expectations.dart';

void main() {
  const shaderRoot = 'shaders/3d_and_hypercomplex/';
  late final Set<String> declaredShaderAssets;

  setUpAll(() {
    declaredShaderAssets = loadDeclaredShaderAssets();
  });

  test('declared 3D and hypercomplex shader assets exist on disk', () {
    expectDeclaredShaderAssetsForRoot(declaredShaderAssets, shaderRoot);
  });

  test('catalog 3D and hypercomplex shader assets are declared in pubspec', () {
    final catalogAssets = [
      ...escapeTimeShaderAssetsStartingWith(shaderRoot),
      ...raymarched3DCatalog
          .map((module) => module.shaderAsset)
          .where((asset) => asset.startsWith(shaderRoot)),
    ]..sort();

    expect(catalogAssets, isNotEmpty);
    expectAssetsDeclaredAndExist(catalogAssets, declaredShaderAssets);
  });
}
