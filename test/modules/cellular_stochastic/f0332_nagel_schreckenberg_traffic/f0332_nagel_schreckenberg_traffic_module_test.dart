// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/cellular_stochastic/f0332_nagel_schreckenberg_traffic/f0332_nagel_schreckenberg_traffic_module.dart';

void main() {
  test('F0332NagelSchreckenbergTraffic instantiates', () {
    final m = F0332NagelSchreckenbergTraffic();
    expect(m.id, 'f0332_nagel_schreckenberg_traffic');
    expect(m.shader, 'shaders/f0332_nagel_schreckenberg_traffic_gpu.frag');
  });

  test('F0332NagelSchreckenbergTraffic presets are well-formed', () {
    final m = F0332NagelSchreckenbergTraffic();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0332NagelSchreckenbergTraffic metadata is consistent', () {
    final m = F0332NagelSchreckenbergTraffic();
    expect(m.metadata.id, m.id);
  });
}
