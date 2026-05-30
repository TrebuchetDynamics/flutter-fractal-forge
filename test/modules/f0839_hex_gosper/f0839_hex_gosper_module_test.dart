// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/l_systems_space_filling/f0839_hex_gosper/f0839_hex_gosper_module.dart';

void main() {
  test('F0839HexGosper instantiates', () {
    final m = F0839HexGosper();
    expect(m.id, 'f0839_hex_gosper');
    expect(m.shader, 'shaders/f0839_hex_gosper_gpu.frag');
  });

  test('F0839HexGosper presets are well-formed', () {
    final m = F0839HexGosper();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0839HexGosper metadata is consistent', () {
    final m = F0839HexGosper();
    expect(m.metadata.id, m.id);
  });
}
