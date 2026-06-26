import 'package:flutter_fractals/core/modules/builders/shared_gumowski_mira_catalog.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('registers reviewed Gumowski-Mira coefficient-map identities', () {
    final registry = ModuleRegistry();
    final modulesById = {
      for (final module in registry.modules) module.id: module
    };

    expect(sharedGumowskiMiraCatalogEntries, hasLength(16));
    final coefficients = <String>{};
    for (final entry in sharedGumowskiMiraCatalogEntries) {
      final module = modulesById[entry.id];

      expect(module, isNotNull, reason: entry.id);
      expect(module!.shaderAsset,
          'shaders/strange_attractors/gumowski_mira_gpu.frag');
      expect(module.defaultPreset.moduleId, entry.id);
      expect(module.defaultPreset.params['mu'], entry.mu);
      expect(module.defaultPreset.params['yScale'], entry.yScale);
      expect(coefficients.add('${entry.mu},${entry.yScale}'), isTrue);
    }
  });

  test('keeps generic Gumowski-Mira configured with exposed coefficient params',
      () {
    final module = ModuleRegistry().byId('gumowski_mira');

    expect(module.defaultPreset.params['mu'], 0.008);
    expect(module.defaultPreset.params['yScale'], 0.05);
  });
}
