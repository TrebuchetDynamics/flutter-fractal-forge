import 'dart:io';

import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_fractals/features/catalog/catalog_repository.dart';
import 'package:flutter_test/flutter_test.dart';

bool _isDiagnosticModule(String id, String shaderAsset) {
  return id.startsWith('test_') ||
      id == 'gpu_gradient' ||
      id == 'gpu_sampler_diag' ||
      shaderAsset.startsWith('shaders/diagnostic/');
}

void main() {
  group('Curated catalog goal guardrails', () {
    test('live registry keeps the current shader-backed renderable floor', () {
      final registry = ModuleRegistry();
      final catalog = CatalogRepository.fromRegistry(registry);

      var nonDiagnostic = 0;
      var shaderBacked = 0;
      final missingShaders = <String>[];

      for (final entry in catalog.entries) {
        final module = entry.module;
        if (_isDiagnosticModule(module.id, module.shaderAsset)) continue;
        nonDiagnostic++;

        if (File(module.shaderAsset).existsSync()) {
          shaderBacked++;
        } else {
          missingShaders.add('${module.id}|${module.shaderAsset}');
        }
      }

      expect(missingShaders, isEmpty);
      expect(shaderBacked, nonDiagnostic);
      expect(shaderBacked, greaterThanOrEqualTo(890));
    });
  });
}
