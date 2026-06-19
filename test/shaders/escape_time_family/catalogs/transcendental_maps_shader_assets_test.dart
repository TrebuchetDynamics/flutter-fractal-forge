import 'package:flutter_test/flutter_test.dart';

import '../../support/shader_asset_expectations.dart';

void main() {
  const shaderRoot = 'shaders/escape_time_family/transcendental_maps/';
  late final Set<String> declaredShaderAssets;

  setUpAll(() {
    declaredShaderAssets = loadDeclaredShaderAssets();
  });

  test('declared transcendental map shader assets exist on disk', () {
    expectDeclaredShaderAssetsForRoot(declaredShaderAssets, shaderRoot);
  });

  test('catalog transcendental map shader assets are declared in pubspec', () {
    expectCatalogShaderAssetsForRoot(declaredShaderAssets, shaderRoot);
  });
}
