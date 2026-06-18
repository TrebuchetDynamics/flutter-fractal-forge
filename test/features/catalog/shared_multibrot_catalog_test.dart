import 'package:flutter_fractals/core/modules/builders/shared_multibrot_catalog.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('registers reviewed Multibrot exponent identities', () {
    final registry = ModuleRegistry();
    final modulesById = {
      for (final module in registry.modules) module.id: module
    };

    expect(sharedMultibrotCatalogEntries, hasLength(20));
    for (final entry in sharedMultibrotCatalogEntries) {
      final module = modulesById[entry.id];
      expect(module, isNotNull, reason: entry.id);
      expect(
        module!.shaderAsset,
        'shaders/escape_time_family/families/multibrot/integer_powers/multibrot3_gpu.frag',
      );
      expect(module.defaultPreset.moduleId, entry.id);
      expect(module.defaultPreset.params['power'], entry.power);
    }
  });

  test('keeps generic Multibrot d=3 configured with power uniform', () {
    final module = ModuleRegistry().byId('multibrot3');

    expect(module.defaultPreset.params['power'], 3.0);
  });
}
