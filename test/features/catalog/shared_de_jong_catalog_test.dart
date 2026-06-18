import 'dart:io';

import 'package:flutter_fractals/core/modules/builders/shared_de_jong_catalog.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('registers reviewed Peter de Jong coefficient-map identities', () {
    final registry = ModuleRegistry();
    final modulesById = {
      for (final module in registry.modules) module.id: module
    };

    expect(sharedDeJongCatalogEntries, hasLength(22));
    final coefficients = <String>{};
    for (final entry in sharedDeJongCatalogEntries) {
      final module = modulesById[entry.id];

      expect(module, isNotNull, reason: entry.id);
      expect(module!.shaderAsset,
          'shaders/strange_attractors/peter_de_jong_gpu.frag');
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

  test('keeps generic Peter de Jong configured with coefficient params', () {
    final module = ModuleRegistry().byId('peter_de_jong');

    expect(module.defaultPreset.params['a'], 1.4);
    expect(module.defaultPreset.params['b'], -2.3);
    expect(module.defaultPreset.params['c'], 2.4);
    expect(module.defaultPreset.params['d'], -2.1);
  });
}
