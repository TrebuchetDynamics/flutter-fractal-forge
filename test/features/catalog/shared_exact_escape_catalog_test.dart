import 'dart:io';

import 'package:flutter_fractals/core/modules/builders/shared_exact_escape_catalog.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('registers reviewed exact escape/root/orbit formula identities', () {
    final registry = ModuleRegistry();
    final modulesById = {
      for (final module in registry.modules) module.id: module
    };

    expect(sharedExactEscapeCatalogEntries, hasLength(6));
    final shaderAssets = <String>{};
    for (final entry in sharedExactEscapeCatalogEntries) {
      final module = modulesById[entry.id];

      expect(module, isNotNull, reason: entry.id);
      expect(module!.shaderAsset, entry.shaderAsset);
      expect(File(entry.shaderAsset).existsSync(), isTrue,
          reason: entry.shaderAsset);
      expect(module.defaultPreset.moduleId, entry.id);
      expect(shaderAssets.add(entry.shaderAsset), isTrue,
          reason: entry.shaderAsset);
    }
  });
}
