import 'package:flutter_test/flutter_test.dart';

import '../../support/shader_asset_expectations.dart';

void main() {
  const shaderRoot = 'shaders/escape_time_family/julia_variants/';
  late final Set<String> declaredShaderAssets;

  setUpAll(() {
    declaredShaderAssets = loadDeclaredShaderAssets();
  });

  test('declared Julia variant shader assets exist on disk', () {
    expectDeclaredShaderAssetsForRoot(declaredShaderAssets, shaderRoot);
  });

  test('catalog Julia variant shader assets are declared in pubspec', () {
    expectCatalogShaderAssetsForRoot(declaredShaderAssets, shaderRoot);
  });
}
