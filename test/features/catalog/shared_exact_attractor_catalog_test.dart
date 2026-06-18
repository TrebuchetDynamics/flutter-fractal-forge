import 'dart:io';

import 'package:flutter_fractals/core/modules/builders/shared_exact_attractor_catalog.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('registers reviewed exact strange-attractor formula identities', () {
    final registry = ModuleRegistry();
    final modulesById = {
      for (final module in registry.modules) module.id: module
    };

    expect(sharedExactAttractorCatalogEntries, hasLength(42));
    final shaderAssets = <String>{};
    for (final entry in sharedExactAttractorCatalogEntries) {
      final module = modulesById[entry.id];

      expect(module, isNotNull, reason: entry.id);
      expect(module!.shaderAsset, entry.shaderAsset);
      expect(File(entry.shaderAsset).existsSync(), isTrue,
          reason: entry.shaderAsset);
      expect(File('assets/catalog_thumbs/${entry.id}.png').existsSync(), isTrue,
          reason: entry.id);
      expect(module.defaultPreset.moduleId, entry.id);
      expect(module.defaultPreset.params['iterations'], 360);
      expect(shaderAssets.add(entry.shaderAsset), isTrue,
          reason: 'duplicate shader ${entry.shaderAsset}');
    }
  });
}
