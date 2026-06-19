import 'package:flutter_test/flutter_test.dart';

import '../../support/shader_asset_expectations.dart';

void main() {
  const shaderRoot = 'shaders/escape_time_family/families/multibrot/';
  late final Set<String> declaredShaderAssets;

  setUpAll(() {
    declaredShaderAssets = loadDeclaredShaderAssets();
  });

  group('Multibrot shader assets', () {
    test('catalog multibrot assets exist on disk', () {
      expectCatalogShaderAssetsForRoot(declaredShaderAssets, shaderRoot);
    });

    test('catalog multibrot assets are registered in pubspec', () {
      expectCatalogShaderAssetsForRoot(declaredShaderAssets, shaderRoot);
    });
  });
}
