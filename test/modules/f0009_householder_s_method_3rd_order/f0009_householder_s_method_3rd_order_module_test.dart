// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/newton_root_finding/f0009_householder_s_method_3rd_order/f0009_householder_s_method_3rd_order_module.dart';

void main() {
  test('F0009HouseholderSMethod3rdOrder instantiates', () {
    final m = F0009HouseholderSMethod3rdOrder();
    expect(m.id, 'f0009_householder_s_method_3rd_order');
    expect(m.shader, 'shaders/f0009_householder_s_method_3rd_order_gpu.frag');
  });

  test('F0009HouseholderSMethod3rdOrder presets are well-formed', () {
    final m = F0009HouseholderSMethod3rdOrder();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0009HouseholderSMethod3rdOrder metadata is consistent', () {
    final m = F0009HouseholderSMethod3rdOrder();
    expect(m.metadata.id, m.id);
  });
}
