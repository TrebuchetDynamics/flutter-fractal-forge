import 'dart:io';

import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_fractals/features/catalog/catalog_repository.dart';
import 'package:flutter_fractals/features/catalog/catalog_thumbnail_plan.dart';
import 'package:flutter_fractals/features/catalog/featured_launch_set.dart';
import 'package:flutter_fractals/features/renderer/providers/fractal_provider.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Featured Launch Set', () {
    test('is small, unique, and maps to stable catalog IDs', () {
      expect(kFeaturedLaunchSetModuleIds, hasLength(lessThanOrEqualTo(12)));
      expect(
        kFeaturedLaunchSetModuleIds.toSet(),
        hasLength(kFeaturedLaunchSetModuleIds.length),
      );
      expect(
        kFeaturedLaunchSetCatalogIds,
        kFeaturedLaunchSetModuleIds.map((id) => 'core.$id').toList(),
      );
    });

    test('contains only real registry modules with catalog entries', () {
      final registry = ModuleRegistry();
      final catalog = CatalogRepository.fromRegistry(registry);
      final catalogIds = catalog.allIds();

      for (final moduleId in kFeaturedLaunchSetModuleIds) {
        final module = registry.byId(moduleId);
        expect(module.id, moduleId);
        expect(
          module.shaderAsset.startsWith('shaders/diagnostic/'),
          isFalse,
          reason: '$moduleId must not be a diagnostic module',
        );
        expect(catalogIds, contains('core.$moduleId'));
      }
    });

    test('has exact bundled thumbnail assets for every launch module', () {
      for (final catalogId in kFeaturedLaunchSetCatalogIds) {
        final plan = CatalogThumbnailPlan.fromCatalogId(catalogId);
        expect(
          File(plan.assetPath).existsSync(),
          isTrue,
          reason:
              '$catalogId must have an exact thumbnail at ${plan.assetPath}',
        );
      }
    });

    test('can be selected by FractalController without shader work', () {
      final registry = ModuleRegistry();
      final controller = FractalController(registry);
      addTearDown(controller.dispose);

      for (final moduleId in kFeaturedLaunchSetModuleIds) {
        controller.selectModule(registry.byId(moduleId), animate: false);
        expect(controller.module.id, moduleId);
        expect(controller.params, isNotEmpty, reason: moduleId);
      }
    });
  });
}
