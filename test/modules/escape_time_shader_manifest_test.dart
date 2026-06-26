import 'package:flutter_fractals/core/modules/builders/escape_time_catalog.dart';
import 'package:flutter_test/flutter_test.dart';

import '../shaders/support/shader_asset_expectations.dart';

void main() {
  late final Set<String> declaredShaderAssets;

  setUpAll(() {
    declaredShaderAssets = loadDeclaredShaderAssets();
  });

  test('every escape-time catalog shader asset is declared and exists', () {
    final catalogAssets = escapeTimeCatalog
        .map((config) => config.shaderAsset)
        .toSet()
        .toList()
      ..sort();

    expect(catalogAssets, isNotEmpty);
    expectAssetsDeclaredAndExist(catalogAssets, declaredShaderAssets);
  });
}
