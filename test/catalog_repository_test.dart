import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_fractals/core/modules/fractal_module.dart';
import 'package:flutter_fractals/features/catalog/catalog_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CatalogRepository', () {
    test('creates stable prefixed IDs from module registry', () {
      final registry = ModuleRegistry();
      final repo = CatalogRepository.fromRegistry(registry);

      expect(repo.entries, isNotEmpty);
      expect(repo.entries.length, registry.modules.length);
      expect(repo.entries.first.catalogId, startsWith('core.'));
      expect(repo.byCatalogId('core.mandelbrot').module.id, 'mandelbrot');
    });

    test('catalog IDs are unique', () {
      final registry = ModuleRegistry();
      final repo = CatalogRepository.fromRegistry(registry);

      expect(repo.allIds().length, repo.entries.length);
    });

    test('keeps intended 3D runtime modules for implemented 3D catalog ids', () {
      final registry = ModuleRegistry();
      final repo = CatalogRepository.fromRegistry(registry);

      expect(
        repo.byCatalogId('core.quaternion_julia_3d').module.dimension,
        FractalDimension.threeD,
      );
      expect(
        repo.byCatalogId('core.dual_quaternion_julia').module.dimension,
        FractalDimension.threeD,
      );
      expect(
        repo.byCatalogId('core.mandelbox_shape_inversion').module.dimension,
        FractalDimension.threeD,
      );
    });
  });
}
