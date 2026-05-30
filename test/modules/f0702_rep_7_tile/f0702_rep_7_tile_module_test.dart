// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/tiling_aperiodic/f0702_rep_7_tile/f0702_rep_7_tile_module.dart';

void main() {
  test('F0702Rep7Tile instantiates', () {
    final m = F0702Rep7Tile();
    expect(m.id, 'f0702_rep_7_tile');
    expect(m.shader, 'shaders/f0702_rep_7_tile_gpu.frag');
  });

  test('F0702Rep7Tile presets are well-formed', () {
    final m = F0702Rep7Tile();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0702Rep7Tile metadata is consistent', () {
    final m = F0702Rep7Tile();
    expect(m.metadata.id, m.id);
  });
}
