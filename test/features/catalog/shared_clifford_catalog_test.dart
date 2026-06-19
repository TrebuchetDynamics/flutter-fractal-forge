import 'package:flutter_fractals/core/modules/builders/shared_clifford_catalog.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_test/flutter_test.dart';

import 'shared_coefficient_catalog_expectations.dart';

void main() {
  test('registers reviewed Clifford coefficient-map identities', () {
    expectSharedCoefficientCatalog(
      entries: sharedCliffordCatalogEntries,
      expectedLength: 32,
      shaderAsset: 'shaders/strange_attractors/clifford_gpu.frag',
    );
  });

  test('keeps generic Clifford configured with coefficient params', () {
    final module = ModuleRegistry().byId('clifford');

    expect(module.defaultPreset.params['a'], -1.4);
    expect(module.defaultPreset.params['b'], 1.6);
    expect(module.defaultPreset.params['c'], 1.0);
    expect(module.defaultPreset.params['d'], 0.7);
  });
}
