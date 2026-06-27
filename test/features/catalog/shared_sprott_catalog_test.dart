import 'package:flutter_fractals/core/modules/builders/shared_catalogs/shared_sprott_catalog.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('registers reviewed exact Sprott formula identities', () {
    final registry = ModuleRegistry();
    final modulesById = {
      for (final module in registry.modules) module.id: module
    };

    expect(sharedSprottCatalogEntries, hasLength(15));
    for (final entry in sharedSprottCatalogEntries) {
      final module = modulesById[entry.id];

      expect(module, isNotNull, reason: entry.id);
      expect(module!.shaderAsset, entry.shaderAsset);
      expect(module.defaultPreset.moduleId, entry.id);
      expect(module.defaultPreset.params['iterations'], 360);
    }
  });
}
