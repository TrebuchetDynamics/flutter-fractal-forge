import 'package:flutter_fractals/core/modules/builders/shared_julia_catalog.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('registers reviewed shared Julia formula identities', () {
    final registry = ModuleRegistry();
    final modulesById = {
      for (final module in registry.modules) module.id: module
    };

    expect(sharedJuliaCatalogEntries, hasLength(50));
    for (final entry in sharedJuliaCatalogEntries) {
      final module = modulesById[entry.id];
      expect(module, isNotNull, reason: entry.id);
      expect(
        module!.shaderAsset,
        'shaders/escape_time_family/core/julia_gpu.frag',
      );
      expect(module.defaultPreset.moduleId, entry.id);
      expect(module.defaultPreset.params['juliaCReal'], entry.cReal);
      expect(module.defaultPreset.params['juliaCImag'], entry.cImag);
    }
  });
}
