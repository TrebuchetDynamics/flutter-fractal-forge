import 'package:flutter_fractals/core/modules/builders/shared_direct_3d_catalog.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('registers reviewed direct 3D KIFS identities', () {
    final registry = ModuleRegistry();
    final modulesById = {
      for (final module in registry.modules) module.id: module
    };

    expect(sharedDirect3DCatalogEntries, hasLength(2));
    for (final entry in sharedDirect3DCatalogEntries) {
      final module = modulesById[entry.id];
      expect(module, isNotNull, reason: entry.id);
      expect(module!.shaderAsset, entry.shaderAsset);
      expect(module.defaultPreset.moduleId, entry.id);
      expect(module.defaultPreset.params['power'], entry.defaultPower);
    }
  });
}
