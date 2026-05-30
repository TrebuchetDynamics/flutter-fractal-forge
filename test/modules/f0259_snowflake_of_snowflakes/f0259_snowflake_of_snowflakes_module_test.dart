// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/l_systems_space_filling/f0259_snowflake_of_snowflakes/f0259_snowflake_of_snowflakes_module.dart';

void main() {
  test('F0259SnowflakeOfSnowflakes instantiates', () {
    final m = F0259SnowflakeOfSnowflakes();
    expect(m.id, 'f0259_snowflake_of_snowflakes');
    expect(m.shader, 'shaders/f0259_snowflake_of_snowflakes_gpu.frag');
  });

  test('F0259SnowflakeOfSnowflakes presets are well-formed', () {
    final m = F0259SnowflakeOfSnowflakes();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0259SnowflakeOfSnowflakes metadata is consistent', () {
    final m = F0259SnowflakeOfSnowflakes();
    expect(m.metadata.id, m.id);
  });
}
