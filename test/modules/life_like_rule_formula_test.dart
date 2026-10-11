import 'package:flutter_fractals/core/modules/builders/shared_catalogs/shared_life_like_catalog.dart';
import 'package:flutter_fractals/core/modules/life_like_rule.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('every Maze shader caller supplies masks in the nine-bit domain', () {
    final callers = ModuleRegistry().modules.where((module) =>
        module.shaderAsset ==
        'shaders/cellular_and_stochastic/maze_ca_gpu.frag');
    expect(callers, isNotEmpty);
    for (final module in callers) {
      for (final key in ['birthMask', 'survivalMask']) {
        final parameter = module.parameters.singleWhere((p) => p.id == key);
        expect(parameter.min, 0, reason: module.id);
        expect(parameter.max, 511, reason: module.id);
        for (final preset in module.builtInPresets) {
          final mask = preset.params[key] as num;
          expect(mask, inInclusiveRange(0, 511), reason: module.id);
          expect(mask, mask.round(), reason: module.id);
        }
      }
    }
  });

  test('decodes every supported mask including empty and full rules', () {
    for (var mask = 0; mask <= 511; mask++) {
      final expected = <int>[];
      var remaining = mask;
      for (var count = 0; count <= 8; count++) {
        if (remaining.isOdd) expected.add(count);
        remaining ~/= 2;
      }
      expect(lifeLikeRuleName(mask, mask),
          'B${expected.join()}/S${expected.join()}',
          reason: '$mask');
    }
    expect(lifeLikeRuleName(8, 62), 'B3/S12345');
  });

  test('finite masks clamp and round like shader inputs', () {
    expect(lifeLikeRuleName(-1, 512), 'B/S012345678');
    expect(lifeLikeRuleName(7.49, 7.5), 'B012/S3');
    for (final invalid in [
      double.nan,
      double.infinity,
      double.negativeInfinity
    ]) {
      expect(() => lifeLikeRuleName(invalid, 0), throwsArgumentError);
      expect(() => lifeLikeRuleName(0, invalid), throwsArgumentError);
    }
  });

  test('Life-like names decode masks without changing persisted IDs', () {
    final entries = sharedLifeLikeCatalogEntries;
    expect(entries[0].name, 'Life-like B/S');
    expect(entries[8].name, 'Life-like B3/S');
    expect(entries[9].name, 'Life-like B03/S');
    expect(entries[17].name, 'Life-like B04/S');
    expect(entries[17].id, 'life_like_b017_s000');
  });
}
