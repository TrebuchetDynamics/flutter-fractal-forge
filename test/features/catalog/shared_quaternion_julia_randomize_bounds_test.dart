import 'package:flutter_fractals/core/modules/builders/shared_catalogs/shared_quaternion_julia_catalog.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Quaternion Julia randomizable constants stay in stable bounds', () {
    final registry = ModuleRegistry();
    final ids =
        sharedQuaternionJuliaCatalogEntries.map((entry) => entry.id).toSet();
    final modules = registry.modules.where((module) => ids.contains(module.id));

    expect(modules, hasLength(sharedQuaternionJuliaCatalogEntries.length));
    for (final module in modules) {
      for (final param in module.parameters
          .where((param) => RegExp(r'^c[0-3]$').hasMatch(param.id))) {
        expect(param.min, -0.95, reason: '${module.id}.${param.id} min');
        expect(param.max, 0.95, reason: '${module.id}.${param.id} max');
      }
    }
  });
}
