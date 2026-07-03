import 'dart:io';

import 'package:flutter_fractals/core/modules/builders/shared_catalogs/shared_clifford_catalog.dart';
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

  test('starts Clifford Coral with higher density detail', () {
    final params =
        ModuleRegistry().byId('f0352_clifford_coral').defaultPreset.params;

    expect(params['iterations'], 360);
    expect(params['a'], -1.7);
    expect(params['b'], 1.8);
    expect(params['c'], -1.9);
    expect(params['d'], -0.4);
  });

  test('bounds Clifford randomization near reviewed coefficients', () {
    final module = ModuleRegistry().byId('f0338_clifford_tornado');
    final paramsById = {for (final param in module.parameters) param.id: param};

    expect(module.defaultPreset.params['iterations'], 360);
    expect(paramsById['iterations']!.min, 300);
    expect(paramsById['iterations']!.max, 500);
    expect(242, lessThan(paramsById['iterations']!.min));
    expect(paramsById['a']!.min, closeTo(-1.7, 1e-9));
    expect(paramsById['a']!.max, closeTo(-1.1, 1e-9));
    expect(paramsById['b']!.min, closeTo(1.3, 1e-9));
    expect(paramsById['b']!.max, closeTo(1.9, 1e-9));
    expect(paramsById['c']!.min, closeTo(0.7, 1e-9));
    expect(paramsById['c']!.max, closeTo(1.3, 1e-9));
    expect(paramsById['d']!.min, closeTo(0.4, 1e-9));
    expect(paramsById['d']!.max, closeTo(1.0, 1e-9));

    expect(2.36, greaterThan(paramsById['a']!.max));
    expect(0.89, lessThan(paramsById['b']!.min));
    expect(-2.4, lessThan(paramsById['c']!.min));
    expect(-1.15, lessThan(paramsById['d']!.min));
  });

  test('bounds reported Clifford Crystal bad random coefficients', () {
    final module = ModuleRegistry().byId('f0348_clifford_crystal');
    final paramsById = {for (final param in module.parameters) param.id: param};

    expect(paramsById['a']!.min, closeTo(-1.6, 1e-9));
    expect(paramsById['a']!.max, closeTo(-1.0, 1e-9));
    expect(-1.84, lessThan(paramsById['a']!.min));
    expect(paramsById['b']!.min, closeTo(-1.6, 1e-9));
    expect(paramsById['b']!.max, closeTo(-1.0, 1e-9));
  });

  test('clamps incoming Clifford share coefficients before uniforms', () {
    final source = File(
      'lib/core/modules/builders/shared_catalogs/shared_coefficient_attractor_builder.dart',
    ).readAsStringSync();

    expect(source, contains('_safeIterations(readDouble(state.params'));
    expect(source, contains('_safeCoefficient(readDouble(state.params'));
    expect(source, contains('coefficientRadius'));
  });
}
