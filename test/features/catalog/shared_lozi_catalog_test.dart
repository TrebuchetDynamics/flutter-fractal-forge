import 'package:flutter_fractals/core/modules/builders/shared_catalogs/shared_lozi_catalog.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('registers reviewed Lozi coefficient-map identities', () {
    final registry = ModuleRegistry();
    final modulesById = {
      for (final module in registry.modules) module.id: module
    };

    expect(sharedLoziCatalogEntries, hasLength(6));
    final coefficients = <String>{};
    for (final entry in sharedLoziCatalogEntries) {
      final module = modulesById[entry.id];

      expect(module, isNotNull, reason: entry.id);
      expect(module!.shaderAsset, 'shaders/strange_attractors/lozi_gpu.frag');
      expect(module.defaultPreset.moduleId, entry.id);
      expect(module.defaultPreset.params['a'], entry.a);
      expect(module.defaultPreset.params['b'], entry.b);
      expect(coefficients.add('${entry.a},${entry.b}'), isTrue);
    }
  });

  test('keeps generic Lozi configured with coefficient params', () {
    final module = ModuleRegistry().byId('lozi');

    expect(module.defaultPreset.params['a'], 1.7);
    expect(module.defaultPreset.params['b'], 0.5);
  });
}
