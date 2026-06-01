import 'package:flutter_test/flutter_test.dart';

import '../../support/shader_asset_expectations.dart';

void main() {
  const shaderRoot = 'shaders/escape_time_family/experimental_named/';
  late final Set<String> declaredShaderAssets;

  setUpAll(() {
    declaredShaderAssets = loadDeclaredShaderAssets();
  });

  test('catalog experimental named shader assets are declared and present', () {
    final assets = escapeTimeShaderAssetsStartingWith(shaderRoot);

    expect(assets, isNotEmpty);
    expectAssetsDeclaredAndExist(assets, declaredShaderAssets,
        fileReason: 'file must exist');
  });
}
