import 'package:flutter_fractals/core/modules/builders/shared_de_jong_catalog.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_test/flutter_test.dart';

import 'shared_coefficient_catalog_expectations.dart';

void main() {
  test('registers reviewed Peter de Jong coefficient-map identities', () {
    expectSharedCoefficientCatalog(
      entries: sharedDeJongCatalogEntries,
      expectedLength: 22,
      shaderAsset: 'shaders/strange_attractors/peter_de_jong_gpu.frag',
    );
  });

  test('keeps generic Peter de Jong configured with coefficient params', () {
    final module = ModuleRegistry().byId('peter_de_jong');

    expect(module.defaultPreset.params['a'], 1.4);
    expect(module.defaultPreset.params['b'], -2.3);
    expect(module.defaultPreset.params['c'], 2.4);
    expect(module.defaultPreset.params['d'], -2.1);
  });
}
