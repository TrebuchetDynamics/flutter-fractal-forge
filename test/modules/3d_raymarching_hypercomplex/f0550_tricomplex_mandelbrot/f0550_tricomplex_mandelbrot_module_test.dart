// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/3d_raymarching_hypercomplex/f0550_tricomplex_mandelbrot/f0550_tricomplex_mandelbrot_module.dart';
import 'package:flutter_fractals/core/modules/3d_raymarching_hypercomplex/f0550_tricomplex_mandelbrot/f0550_tricomplex_mandelbrot_metadata.dart'
    as metadata_facade;
import 'package:flutter_fractals/core/modules/3d_raymarching_hypercomplex/f0550_tricomplex_mandelbrot/f0550_tricomplex_mandelbrot_presets.dart'
    as presets_facade;
import 'package:flutter_fractals/core/modules/3d_raymarching_hypercomplex/f0550_tricomplex_mandelbrot/f0550_tricomplex_mandelbrot_variants.dart'
    as variants_facade;

void main() {
  test('F0550TricomplexMandelbrot instantiates', () {
    final m = F0550TricomplexMandelbrot();
    expect(m.id, 'f0550_tricomplex_mandelbrot');
    expect(m.shader, 'shaders/f0550_tricomplex_mandelbrot_gpu.frag');
  });

  test('F0550TricomplexMandelbrot presets are well-formed', () {
    final m = F0550TricomplexMandelbrot();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0550TricomplexMandelbrot metadata is consistent', () {
    final m = F0550TricomplexMandelbrot();
    expect(m.metadata.id, m.id);
  });

  test('F0550TricomplexMandelbrot descriptor facades keep old import paths',
      () {
    expect(
      metadata_facade.F0550TricomplexMandelbrotMetadata.instance.id,
      'f0550_tricomplex_mandelbrot',
    );
    expect(presets_facade.F0550TricomplexMandelbrotPresets.all, isNotEmpty);
    expect(variants_facade.F0550TricomplexMandelbrotVariants.all, isEmpty);
  });
}
