import 'package:flutter_fractals/core/modules/builders/shared_elementary_ca_catalog.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('registers reviewed elementary CA rule identities', () {
    final registry = ModuleRegistry();
    final modulesById = {
      for (final module in registry.modules) module.id: module
    };

    expect(sharedElementaryCaCatalogEntries, hasLength(121));
    for (final entry in sharedElementaryCaCatalogEntries) {
      final module = modulesById[entry.id];
      expect(module, isNotNull, reason: entry.id);
      expect(module!.shaderAsset,
          'shaders/cellular_and_stochastic/wolfram_rule30_gpu.frag');
      expect(module.defaultPreset.moduleId, entry.id);
      expect(module.defaultPreset.params['rule'], entry.rule);
    }
  });

  test('keeps generic Wolfram Rule 30 configured with rule uniform', () {
    final module = ModuleRegistry().byId('wolfram_rule30');

    expect(module.defaultPreset.params['rule'], 30.0);
  });
}
