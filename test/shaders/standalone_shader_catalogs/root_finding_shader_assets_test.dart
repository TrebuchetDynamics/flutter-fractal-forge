import 'package:flutter_test/flutter_test.dart';

import '../support/shader_asset_expectations.dart';

void main() {
  const shaderRoot = 'shaders/root_finding/';
  late final Set<String> declaredShaderAssets;

  setUpAll(() {
    declaredShaderAssets = loadDeclaredShaderAssets();
  });

  test('declared root-finding shader assets exist on disk', () {
    final assets =
        declaredShaderAssetsStartingWith(declaredShaderAssets, shaderRoot);

    expect(assets, isNotEmpty);
    expectAssetsExist(assets);
  });

  test('catalog root-finding shader assets are declared in pubspec', () {
    final catalogAssets = escapeTimeShaderAssetsStartingWith(shaderRoot);

    expect(catalogAssets, isNotEmpty);
    expectAssetsDeclaredAndExist(catalogAssets, declaredShaderAssets);
  });
}
