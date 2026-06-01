import 'package:flutter_test/flutter_test.dart';

import '../support/shader_asset_expectations.dart';

void main() {
  const shaderRoot = 'shaders/strange_attractors/';
  late final Set<String> declaredShaderAssets;

  setUpAll(() {
    declaredShaderAssets = loadDeclaredShaderAssets();
  });

  test('declared strange-attractor shader assets exist on disk', () {
    final strangeAttractorAssets = declaredShaderAssetsStartingWith(
      declaredShaderAssets,
      shaderRoot,
    );

    expect(strangeAttractorAssets, isNotEmpty);
    expectAssetsExist(strangeAttractorAssets);
  });

  test('catalog strange-attractor shader assets are declared in pubspec', () {
    final catalogAssets = escapeTimeShaderAssetsStartingWith(shaderRoot);

    expect(catalogAssets, isNotEmpty);
    expectAssetsDeclaredAndExist(catalogAssets, declaredShaderAssets);
  });
}
