import 'package:flutter_fractals/core/modules/builders/shared_catalogs/shared_escape_power_catalog.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('registers reviewed Tricorn and Burning Ship power identities', () {
    final registry = ModuleRegistry();
    final modulesById = {
      for (final module in registry.modules) module.id: module
    };

    expect(sharedEscapePowerCatalogEntries, hasLength(17));
    for (final entry in sharedEscapePowerCatalogEntries) {
      final module = modulesById[entry.id];
      expect(module, isNotNull, reason: entry.id);
      expect(module!.defaultPreset.moduleId, entry.id);
      expect(module.defaultPreset.params['power'], entry.power);
      expect(module.parameters.any((p) => p.id == 'power'), isTrue);
    }
  });

  test('keeps generic Tricorn and Burning Ship configured with power uniform',
      () {
    final registry = ModuleRegistry();

    expect(registry.byId('tricorn').defaultPreset.params['power'], 2.0);
    expect(registry.byId('burning_ship').defaultPreset.params['power'], 2.0);
  });
}
