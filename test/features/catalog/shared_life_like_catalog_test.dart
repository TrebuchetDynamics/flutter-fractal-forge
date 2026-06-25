import 'package:flutter_fractals/core/modules/builders/shared_life_like_catalog.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('generates deterministic Life-like B/S rule identities', () {
    final entries = sharedLifeLikeCatalogEntries;

    expect(sharedLifeLikeTotalRuleSpace, 262144);
    expect(sharedLifeLikeCatalogSize, lessThan(sharedLifeLikeTotalRuleSpace));
    expect(entries, hasLength(sharedLifeLikeCatalogSize));
    expect(entries.first.id, 'life_like_b000_s000');
    expect(entries.first.birthMask, 0.0);
    expect(entries.first.survivalMask, 0.0);
    expect(entries[17].id, 'life_like_b017_s000');
    expect(entries.last.id, 'life_like_b017_s000');
    expect(entries.map((entry) => entry.id).toSet(), hasLength(entries.length));
  });

  test('registers Life-like rules with birth and survival masks', () {
    final registry = ModuleRegistry();
    final module = registry.byId('life_like_b017_s000');

    expect(
        module.shaderAsset, 'shaders/cellular_and_stochastic/maze_ca_gpu.frag');
    expect(module.defaultPreset.params['birthMask'], 17.0);
    expect(module.defaultPreset.params['survivalMask'], 0.0);
  });
}
