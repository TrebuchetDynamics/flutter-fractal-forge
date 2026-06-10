import 'package:flutter_test/flutter_test.dart';

import '../support/shader_asset_expectations.dart';

void main() {
  const shaderRoot = 'shaders/cellular_and_stochastic/';
  late final Set<String> declaredShaderAssets;

  setUpAll(() {
    declaredShaderAssets = loadDeclaredShaderAssets();
  });

  test('declared cellular and stochastic shader assets exist on disk', () {
    final assets =
        declaredShaderAssetsStartingWith(declaredShaderAssets, shaderRoot);

    expect(assets, hasLength(20));
    expectAssetsExist(assets);
  });

  test('catalog cellular and stochastic shader assets are declared in pubspec',
      () {
    final catalogAssets = escapeTimeShaderAssetsStartingWith(shaderRoot);

    expect(catalogAssets, hasLength(20));
    expectAssetsDeclaredAndExist(catalogAssets, declaredShaderAssets);
  });
}
