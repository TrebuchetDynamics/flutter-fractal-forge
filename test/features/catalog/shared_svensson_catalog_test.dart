import 'dart:io';

import 'package:flutter_fractals/core/modules/builders/shared_svensson_catalog.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('registers reviewed Svensson coefficient-map identities', () {
    final registry = ModuleRegistry();
    final modulesById = {
      for (final module in registry.modules) module.id: module
    };

    expect(sharedSvenssonCatalogEntries, hasLength(20));
    final coefficients = <String>{};
    for (final entry in sharedSvenssonCatalogEntries) {
      final module = modulesById[entry.id];

      expect(module, isNotNull, reason: entry.id);
      expect(
          module!.shaderAsset, 'shaders/strange_attractors/svensson_gpu.frag');
      expect(File('assets/catalog_thumbs/${entry.id}.png').existsSync(), isTrue,
          reason: entry.id);
      expect(module.defaultPreset.moduleId, entry.id);
      expect(module.defaultPreset.params['a'], entry.a);
      expect(module.defaultPreset.params['b'], entry.b);
      expect(module.defaultPreset.params['c'], entry.c);
      expect(module.defaultPreset.params['d'], entry.d);
      expect(coefficients.add('${entry.a},${entry.b},${entry.c},${entry.d}'),
          isTrue);
    }
  });

  test('keeps generic Svensson configured with coefficient params', () {
    final module = ModuleRegistry().byId('svensson');

    expect(module.defaultPreset.params['a'], 1.5);
    expect(module.defaultPreset.params['b'], -1.8);
    expect(module.defaultPreset.params['c'], 1.6);
    expect(module.defaultPreset.params['d'], 0.9);
  });
}
