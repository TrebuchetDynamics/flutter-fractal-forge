// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/l_systems_space_filling/f0880_quadratic_snowflake/f0880_quadratic_snowflake_module.dart';

void main() {
  test('F0880QuadraticSnowflake instantiates', () {
    final m = F0880QuadraticSnowflake();
    expect(m.id, 'f0880_quadratic_snowflake');
    expect(m.shader, 'shaders/f0880_quadratic_snowflake_gpu.frag');
  });

  test('F0880QuadraticSnowflake presets are well-formed', () {
    final m = F0880QuadraticSnowflake();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0880QuadraticSnowflake metadata is consistent', () {
    final m = F0880QuadraticSnowflake();
    expect(m.metadata.id, m.id);
  });
}
