import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_fractals/features/catalog/data/catalog_repository.dart';
import 'package:flutter_fractals/features/catalog/data/featured_launch_set.dart';
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
