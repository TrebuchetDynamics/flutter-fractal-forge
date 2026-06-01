import 'package:flutter_test/flutter_test.dart';

import '../support/shader_asset_expectations.dart';

void main() {
  const shaderRoot = 'shaders/kaleidoscopes/';
  late final Set<String> declaredShaderAssets;

  setUpAll(() {
    declaredShaderAssets = loadDeclaredShaderAssets();
  });

  test('declared kaleidoscope shader assets exist on disk', () {
    final assets =
        declaredShaderAssetsStartingWith(declaredShaderAssets, shaderRoot);

    expect(assets, isNotEmpty);
    expectAssetsExist(assets);
  });

  test('catalog kaleidoscope shader assets are declared in pubspec', () {
    final catalogAssets = escapeTimeShaderAssetsStartingWith(shaderRoot);

    expect(catalogAssets, isNotEmpty);
    expectAssetsDeclaredAndExist(catalogAssets, declaredShaderAssets);
  });
}
