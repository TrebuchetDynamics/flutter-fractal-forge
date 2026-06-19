import 'package:flutter_test/flutter_test.dart';

import '../../support/shader_asset_expectations.dart';

void main() {
  const shaderRoot = 'shaders/escape_time_family/families/celtic/';
  late final Set<String> declaredShaderAssets;

  setUpAll(() {
    declaredShaderAssets = loadDeclaredShaderAssets();
  });

  test('declared Celtic shader assets exist on disk', () {
    expectDeclaredShaderAssetsForRoot(
      declaredShaderAssets,
      shaderRoot,
      matcher: hasLength(14),
    );
  });

  test('catalog Celtic shader assets are declared in pubspec', () {
    expectCatalogShaderAssetsForRoot(
      declaredShaderAssets,
      shaderRoot,
      matcher: hasLength(14),
    );
  });
}
