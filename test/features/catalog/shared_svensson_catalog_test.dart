import 'package:flutter_fractals/core/modules/builders/shared_svensson_catalog.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_test/flutter_test.dart';

import 'shared_coefficient_catalog_expectations.dart';

void main() {
  test('registers reviewed Svensson coefficient-map identities', () {
    expectSharedCoefficientCatalog(
      entries: sharedSvenssonCatalogEntries,
      expectedLength: 20,
      shaderAsset: 'shaders/strange_attractors/svensson_gpu.frag',
    );
  });

  test('keeps generic Svensson configured with coefficient params', () {
    final module = ModuleRegistry().byId('svensson');

    expect(module.defaultPreset.params['a'], 1.5);
    expect(module.defaultPreset.params['b'], -1.8);
    expect(module.defaultPreset.params['c'], 1.6);
    expect(module.defaultPreset.params['d'], 0.9);
  });
}
