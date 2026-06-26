import 'package:flutter_fractals/core/modules/builders/shared_hopalong_catalog.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('registers reviewed Martin/Hopalong coefficient-map identities', () {
    final registry = ModuleRegistry();
    final modulesById = {
      for (final module in registry.modules) module.id: module
    };

    expect(sharedHopalongCatalogEntries, hasLength(13));
    final coefficients = <String>{};
    for (final entry in sharedHopalongCatalogEntries) {
      final module = modulesById[entry.id];

      expect(module, isNotNull, reason: entry.id);
      expect(
          module!.shaderAsset, 'shaders/strange_attractors/hopalong_gpu.frag');
      expect(module.defaultPreset.moduleId, entry.id);
      expect(module.defaultPreset.params['a'], entry.a);
      expect(module.defaultPreset.params['b'], entry.b);
      expect(module.defaultPreset.params['c'], entry.c);
      expect(coefficients.add('${entry.a},${entry.b},${entry.c}'), isTrue);
    }
  });

  test('keeps generic Hopalong configured with coefficient params', () {
    final module = ModuleRegistry().byId('hopalong');

    expect(module.defaultPreset.params['a'], 2.0);
    expect(module.defaultPreset.params['b'], 1.0);
    expect(module.defaultPreset.params['c'], 7.5);
  });
}
