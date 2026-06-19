import 'dart:io';

import 'package:flutter_fractals/core/modules/nova_module.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/shader_asset_expectations.dart';

void main() {
  const shaderRoot = 'shaders/escape_time_family/families/nova/';
  const parameterPlaneRoot = '${shaderRoot}parameter_plane/';
  const juliaSetsRoot = '${shaderRoot}julia_sets/';
  late final Set<String> declaredShaderAssets;

  setUpAll(() {
    declaredShaderAssets = loadDeclaredShaderAssets();
  });

  test('declared Nova shader assets exist on disk', () {
    final assets =
        declaredShaderAssetsStartingWith(declaredShaderAssets, shaderRoot);

    expect(assets, hasLength(9));
    expect(assets.where((asset) => asset.startsWith(parameterPlaneRoot)),
        hasLength(5));
    expect(
        assets.where((asset) => asset.startsWith(juliaSetsRoot)), hasLength(4));
    expectAssetsUnderSubfolders(
      assets,
      shaderRoot,
      matcher: hasLength(9),
      reason: 'Nova shaders belong in responsibility subfolders',
    );
    expectAssetsExist(assets);
  });

  test('catalog Nova shader assets are declared in pubspec', () {
    final catalogAssets = escapeTimeShaderAssetsStartingWith(shaderRoot);

    expect(catalogAssets, hasLength(9));
    expect(catalogAssets.where((asset) => asset.startsWith(parameterPlaneRoot)),
        hasLength(5));
    expect(catalogAssets.where((asset) => asset.startsWith(juliaSetsRoot)),
        hasLength(4));
    expectAssetsDeclaredAndExist(catalogAssets, declaredShaderAssets);
  });

  test('custom Nova module shader asset remains declared and loadable', () {
    final asset = buildNovaModule().shaderAsset;

    expect(asset, startsWith(parameterPlaneRoot));
    expect(declaredShaderAssets, contains(asset));
    expect(File(asset).existsSync(), isTrue, reason: '$asset should exist');
  });
}
