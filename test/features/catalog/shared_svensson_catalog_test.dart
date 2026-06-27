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

  test('uses reported Svensson Coral coefficients', () {
    final params =
        ModuleRegistry().byId('f1047_svensson_coral').defaultPreset.params;

    expect(params['a'], 0.77);
    expect(params['b'], 2.39);
    expect(params['c'], 6.34);
    expect(params['d'], -6.36);
  });

  test('allows Svensson Halo to keep its high bailout default', () {
    final module = ModuleRegistry().byId('f1054_svensson_halo');
    final bailout = module.parameters.singleWhere((p) => p.id == 'bailout');

    expect(module.defaultPreset.params['bailout'], 24.0);
    expect(bailout.max, 24.0);
  });
}
