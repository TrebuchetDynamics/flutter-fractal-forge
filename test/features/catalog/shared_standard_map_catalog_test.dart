import 'package:flutter_fractals/core/modules/builders/shared_standard_map_catalog.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('registers reviewed Standard Map K identities', () {
    final registry = ModuleRegistry();
    final modulesById = {
      for (final module in registry.modules) module.id: module
    };

    expect(sharedStandardMapCatalogEntries, hasLength(3));
    final coefficients = <double>{};
    for (final entry in sharedStandardMapCatalogEntries) {
      final module = modulesById[entry.id];

      expect(module, isNotNull, reason: entry.id);
      expect(module!.shaderAsset,
          'shaders/strange_attractors/standard_map_gpu.frag');
      expect(module.defaultPreset.moduleId, entry.id);
      expect(module.defaultPreset.params['k'], entry.k);
      expect(coefficients.add(entry.k), isTrue);
    }
  });

  test('keeps generic Standard Map configured with K param', () {
    final module = ModuleRegistry().byId('standard_map');

    expect(module.defaultPreset.params['k'], 0.9);
  });
}
