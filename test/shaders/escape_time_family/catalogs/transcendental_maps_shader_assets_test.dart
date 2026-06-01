import 'package:flutter_test/flutter_test.dart';

import '../../support/shader_asset_expectations.dart';

void main() {
  const shaderRoot = 'shaders/escape_time_family/transcendental_maps/';
  late final Set<String> declaredShaderAssets;

  setUpAll(() {
    declaredShaderAssets = loadDeclaredShaderAssets();
  });

  test('declared transcendental map shader assets exist on disk', () {
    final assets =
        declaredShaderAssetsStartingWith(declaredShaderAssets, shaderRoot);

    expect(assets, isNotEmpty);
    expectAssetsExist(assets);
  });

  test('catalog transcendental map shader assets are declared in pubspec', () {
    final catalogAssets = escapeTimeShaderAssetsStartingWith(shaderRoot);

    expect(catalogAssets, isNotEmpty);
    expectAssetsDeclaredAndExist(catalogAssets, declaredShaderAssets);
  });
}
