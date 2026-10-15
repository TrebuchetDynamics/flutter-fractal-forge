import 'package:flutter_fractals/core/modules/builders/shared_catalogs/shared_orbit_trap_catalog.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('legacy multi-line ID names its existing cross without locking selector',
      () {
    const id = 'f1162_orbit_trap_multi_lines_cross';
    final entry =
        sharedOrbitTrapCatalogEntries.singleWhere((entry) => entry.id == id);
    expect(entry.name, 'Orbit Trap: Cross');
    expect(entry.trapMode, 7);
    final module = ModuleRegistry().byId(id);
    expect(module.defaultPreset.params['trapMode'], 7);
    final selector = module.parameters.singleWhere((p) => p.id == 'trapMode');
    expect(selector.min, 0);
    expect(selector.max, 24);
  });
}
