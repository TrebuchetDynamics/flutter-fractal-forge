import 'package:flutter_test/flutter_test.dart';

import '../../support/shader_asset_expectations.dart';

void main() {
  const shaderRoot = 'shaders/escape_time_family/families/buffalo/';
  late final Set<String> declaredShaderAssets;

  setUpAll(() {
    declaredShaderAssets = loadDeclaredShaderAssets();
  });

  test('declared Buffalo shader assets exist on disk', () {
    expectDeclaredShaderAssetsForRoot(
      declaredShaderAssets,
      shaderRoot,
      matcher: hasLength(6),
    );
  });

  test('catalog Buffalo shader assets are declared in pubspec', () {
    // Families now share one parameterised shader across several entries, so
    // count distinct shaders rather than catalog references.
    final assets = expectCatalogShaderAssetsForRoot(
      declaredShaderAssets,
      shaderRoot,
      matcher: isNotEmpty,
    );
    expect(assets.toSet(), hasLength(6));
  });
}
