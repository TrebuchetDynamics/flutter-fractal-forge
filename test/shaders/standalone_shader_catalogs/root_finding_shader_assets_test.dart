import 'package:flutter_test/flutter_test.dart';

import '../support/shader_asset_expectations.dart';

void main() {
  const shaderRoot = 'shaders/root_finding/';
  late final Set<String> declaredShaderAssets;

  setUpAll(() {
    declaredShaderAssets = loadDeclaredShaderAssets();
  });

  test('declared root-finding shader assets exist on disk', () {
    expectDeclaredShaderAssetsForRoot(declaredShaderAssets, shaderRoot);
  });

  test('catalog root-finding shader assets are declared in pubspec', () {
    expectCatalogShaderAssetsForRoot(declaredShaderAssets, shaderRoot);
  });
}
