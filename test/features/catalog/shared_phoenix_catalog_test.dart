import 'package:flutter_fractals/core/modules/builders/shared_catalogs/shared_phoenix_catalog.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('registers reviewed shared Phoenix degree identities', () {
    final registry = ModuleRegistry();
    final modulesById = {
      for (final module in registry.modules) module.id: module
    };

    expect(sharedPhoenixCatalogEntries, hasLength(3));
    for (final entry in sharedPhoenixCatalogEntries) {
      final module = modulesById[entry.id];
      expect(module, isNotNull, reason: entry.id);
      expect(
        module!.shaderAsset,
        'shaders/escape_time_family/core/phoenix_gpu.frag',
      );
      expect(module.defaultPreset.moduleId, entry.id);
      expect(module.defaultPreset.params['phoenixPower'], entry.power);
    }
  });

  test('uses custom Phoenix module for core Phoenix uniform layout', () {
    final phoenix = ModuleRegistry().byId('phoenix');

    expect(phoenix.shaderAsset,
        'shaders/escape_time_family/core/phoenix_gpu.frag');
    expect(phoenix.defaultPreset.params, containsPair('phoenixP', -0.5));
  });
}
