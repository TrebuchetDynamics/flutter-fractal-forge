import 'dart:io';

import 'package:flutter_fractals/core/modules/builders/shared_clifford_catalog.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('registers reviewed Clifford coefficient-map identities', () {
    final registry = ModuleRegistry();
    final modulesById = {
      for (final module in registry.modules) module.id: module
    };

    expect(sharedCliffordCatalogEntries, hasLength(32));
    final coefficients = <String>{};
    for (final entry in sharedCliffordCatalogEntries) {
      final module = modulesById[entry.id];

      expect(module, isNotNull, reason: entry.id);
      expect(
          module!.shaderAsset, 'shaders/strange_attractors/clifford_gpu.frag');
      expect(File('assets/catalog_thumbs/${entry.id}.png').existsSync(), isTrue,
          reason: entry.id);
      expect(module.defaultPreset.moduleId, entry.id);
      expect(module.defaultPreset.params['a'], entry.a);
      expect(module.defaultPreset.params['b'], entry.b);
      expect(module.defaultPreset.params['c'], entry.c);
      expect(module.defaultPreset.params['d'], entry.d);
      expect(coefficients.add('${entry.a},${entry.b},${entry.c},${entry.d}'),
          isTrue);
    }
  });

  test('keeps generic Clifford configured with coefficient params', () {
    final module = ModuleRegistry().byId('clifford');

    expect(module.defaultPreset.params['a'], -1.4);
    expect(module.defaultPreset.params['b'], 1.6);
    expect(module.defaultPreset.params['c'], 1.0);
    expect(module.defaultPreset.params['d'], 0.7);
  });
}
