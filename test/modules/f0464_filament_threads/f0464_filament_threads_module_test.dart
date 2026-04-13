// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/escape_time_complex_plane/f0464_filament_threads/f0464_filament_threads_module.dart';

void main() {
  test('F0464FilamentThreads instantiates', () {
    final m = F0464FilamentThreads();
    expect(m.id, 'f0464_filament_threads');
    expect(m.shader, 'shaders/f0464_filament_threads_gpu.frag');
  });

  test('F0464FilamentThreads presets are well-formed', () {
    final m = F0464FilamentThreads();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0464FilamentThreads metadata is consistent', () {
    final m = F0464FilamentThreads();
    expect(m.metadata.id, m.id);
  });
}
