import 'package:flutter_fractals/core/modules/builders/shared_direct_transcendental_catalog.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('registers reviewed direct transcendental formula identities', () {
    final registry = ModuleRegistry();
    final modulesById = {
      for (final module in registry.modules) module.id: module
    };

    expect(sharedDirectTranscendentalCatalogEntries, hasLength(10));
    for (final entry in sharedDirectTranscendentalCatalogEntries) {
      final module = modulesById[entry.id];
      expect(module, isNotNull, reason: entry.id);
      expect(module!.shaderAsset, entry.shaderAsset);
      expect(module.defaultPreset.moduleId, entry.id);
      expect(module.defaultPreset.params['iterations'], isA<num>());
      if (entry.variant != null) {
        expect(module.defaultPreset.params['variant'], entry.variant);
      }
    }
  });
}
