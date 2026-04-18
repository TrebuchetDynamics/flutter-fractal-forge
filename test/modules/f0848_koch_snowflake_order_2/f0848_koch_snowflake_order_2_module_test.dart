// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/l_systems_space_filling/f0848_koch_snowflake_order_2/f0848_koch_snowflake_order_2_module.dart';

void main() {
  test('F0848KochSnowflakeOrder2 instantiates', () {
    final m = F0848KochSnowflakeOrder2();
    expect(m.id, 'f0848_koch_snowflake_order_2');
    expect(m.shader, 'shaders/f0848_koch_snowflake_order_2_gpu.frag');
  });

  test('F0848KochSnowflakeOrder2 presets are well-formed', () {
    final m = F0848KochSnowflakeOrder2();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0848KochSnowflakeOrder2 metadata is consistent', () {
    final m = F0848KochSnowflakeOrder2();
    expect(m.metadata.id, m.id);
  });
}
