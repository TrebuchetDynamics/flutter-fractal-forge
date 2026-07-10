import 'package:flutter_fractals/core/modules/builders/shared_catalogs/shared_legalize_fotd_catalog.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Legalize/XMission approximations are not registered as exact fractals',
      () {
    final ids = ModuleRegistry().modules.map((m) => m.id).toSet();

    for (final entry in sharedLegalizeFotdCatalogEntries) {
      expect(ids, isNot(contains(entry.id)),
          reason: '${entry.id} needs an exact Fractint formula port first');
    }
  });
}
