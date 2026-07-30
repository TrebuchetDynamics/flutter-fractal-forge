import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Quaternion Julia randomizable constants stay in stable bounds', () {
    final module = ModuleRegistry().byId('quaternion_julia_3d');

    for (final param in module.parameters
        .where((param) => RegExp(r'^c[0-3]$').hasMatch(param.id))) {
      expect(param.min, -0.95, reason: '${param.id} min');
      expect(param.max, 0.95, reason: '${param.id} max');
    }
  });
}
