import 'package:flutter_fractals/core/modules/builders/shared_catalogs/shared_kifs_menger_catalog.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('registers reviewed KIFS/Menger family identities', () {
    final registry = ModuleRegistry();
    final modulesById = {
      for (final module in registry.modules) module.id: module
    };

    expect(sharedKifsMengerCatalogEntries, hasLength(2));
    for (final entry in sharedKifsMengerCatalogEntries) {
      final module = modulesById[entry.id];
      expect(module, isNotNull, reason: entry.id);
      expect(
        module!.shaderAsset,
        'shaders/ifs_and_geometric/raymarched_3d/kifs_menger_gpu.frag',
      );
      expect(module.defaultPreset.moduleId, entry.id);
      expect(module.defaultPreset.params['fractalType'], entry.fractalType);
      expect(module.parameters.any((p) => p.id == 'fractalType'), isTrue);
    }
  });
}
