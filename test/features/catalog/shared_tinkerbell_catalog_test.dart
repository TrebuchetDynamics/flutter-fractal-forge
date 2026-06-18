import 'dart:io';

import 'package:flutter_fractals/core/modules/builders/shared_tinkerbell_catalog.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('registers reviewed unique Tinkerbell a-coefficient identities', () {
    final registry = ModuleRegistry();
    final modulesById = {
      for (final module in registry.modules) module.id: module
    };

    expect(sharedTinkerbellCatalogEntries, hasLength(4));
    final coefficients = <double>{};
    for (final entry in sharedTinkerbellCatalogEntries) {
      final module = modulesById[entry.id];

      expect(module, isNotNull, reason: entry.id);
      expect(module!.shaderAsset,
          'shaders/strange_attractors/tinkerbell_gpu.frag');
      expect(File('assets/catalog_thumbs/${entry.id}.png').existsSync(), isTrue,
          reason: entry.id);
      expect(module.defaultPreset.moduleId, entry.id);
      expect(module.defaultPreset.params['a'], entry.a);
      expect(coefficients.add(entry.a), isTrue);
    }
  });

  test('keeps generic Tinkerbell configured with a coefficient param', () {
    final module = ModuleRegistry().byId('tinkerbell');

    expect(module.defaultPreset.params['a'], 0.9);
  });
}
