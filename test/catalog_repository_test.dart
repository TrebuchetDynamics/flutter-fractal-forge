import 'package:flutter_fractals/core/modules/module_registry.dart';
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
  });
}
