import 'package:flutter_fractals/core/modules/builders/shared_catalogs/shared_quaternion_julia_catalog.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('registers reviewed Quaternion Julia constants', () {
    final registry = ModuleRegistry();
    final modulesById = {
      for (final module in registry.modules) module.id: module
    };

    expect(sharedQuaternionJuliaCatalogEntries, hasLength(3));
    for (final entry in sharedQuaternionJuliaCatalogEntries) {
      final module = modulesById[entry.id];
      expect(module, isNotNull, reason: entry.id);
      expect(
        module!.shaderAsset,
        'shaders/3d_and_hypercomplex/raymarched_volumes/quaternion_julia_3d_gpu.frag',
      );
      expect(module.defaultPreset.moduleId, entry.id);
      expect(module.defaultPreset.params['c0'], entry.c0);
      expect(module.defaultPreset.params['c1'], entry.c1);
      expect(module.defaultPreset.params['c2'], entry.c2);
      expect(module.defaultPreset.params['c3'], entry.c3);
      expect(
          module.parameters.where((p) => p.id.startsWith('c')), hasLength(5));
    }
  });
}
