import 'package:flutter_test/flutter_test.dart';

import '../support/shader_asset_expectations.dart';

void main() {
  const shaderRoot = 'shaders/cellular_and_stochastic/';
  late final Set<String> declaredShaderAssets;

  setUpAll(() {
    declaredShaderAssets = loadDeclaredShaderAssets();
  });

  test('declared cellular and stochastic shader assets exist on disk', () {
    expectDeclaredShaderAssetsForRoot(
      declaredShaderAssets,
      shaderRoot,
      matcher: hasLength(23),
    );
  });

  test('catalog cellular and stochastic shader assets are declared in pubspec',
      () {
    expectCatalogShaderAssetsForRoot(
      declaredShaderAssets,
      shaderRoot,
      matcher: hasLength(25),
    );
  });
}
