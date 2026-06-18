import 'package:flutter_fractals/core/modules/builders/shared_residual_ca_catalog.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('registers reviewed residual CA rule identities', () {
    final registry = ModuleRegistry();
    final modulesById = {
      for (final module in registry.modules) module.id: module
    };

    expect(sharedResidualCaCatalogEntries, hasLength(47));
    for (final entry in sharedResidualCaCatalogEntries) {
      final module = modulesById[entry.id];
      expect(module, isNotNull, reason: entry.id);
      expect(module!.shaderAsset, entry.shaderAsset);
      expect(module.defaultPreset.moduleId, entry.id);
      if (entry.kind == SharedResidualCaKind.cyclicStates) {
        expect(module.defaultPreset.params['states'], entry.states);
      } else if (entry.kind == SharedResidualCaKind.birthSurvival) {
        expect(module.defaultPreset.params['birthMask'], entry.birthMask);
        expect(module.defaultPreset.params['survivalMask'], entry.survivalMask);
      } else {
        expect(module.defaultPreset.params.containsKey('birthMask'), isFalse);
        expect(
            module.defaultPreset.params.containsKey('survivalMask'), isFalse);
        expect(module.defaultPreset.params.containsKey('states'), isFalse);
      }
    }
  });

  test('includes reviewed Life-like B/S source rules', () {
    final byId = {
      for (final entry in sharedResidualCaCatalogEntries) entry.id: entry
    };

    expect(byId['f0319_conway_s_game_of_life']!.birthMask, 8.0);
    expect(byId['f0319_conway_s_game_of_life']!.survivalMask, 12.0);
    expect(byId['f0320_seeds_ca']!.birthMask, 4.0);
    expect(byId['f0320_seeds_ca']!.survivalMask, 0.0);
  });

  test('keeps generic residual CA modules configured with explicit rule params',
      () {
    final registry = ModuleRegistry();

    expect(registry.byId('cyclic_ca').defaultPreset.params['states'], 8.0);
    expect(registry.byId('maze_ca').defaultPreset.params['birthMask'], 8.0);
    expect(registry.byId('maze_ca').defaultPreset.params['survivalMask'], 62.0);
    expect(registry.byId('replicator_ca').defaultPreset.params['birthMask'],
        170.0);
    expect(registry.byId('replicator_ca').defaultPreset.params['survivalMask'],
        170.0);
  });
}
