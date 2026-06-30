// ignore_for_file: avoid_print
library;

import 'dart:typed_data';

// ignore: depend_on_referenced_packages
import 'package:crypto/crypto.dart' show sha256;
import 'package:flutter_test/flutter_test.dart';
import 'package:vector_math/vector_math.dart' show Vector2;

import 'package:flutter_fractals/features/renderer/cpu/cpu_fractal_renderer.dart';

/// Golden test for palette-independent iteration buffers.
///
/// We assert on SHA256 of the raw Uint16 buffer bytes. This is stable across
/// platforms as long as the iteration logic is deterministic.
void main() {
  test('CPU iteration buffer goldens (sha256)', () async {
    const w = 128;
    const h = 128;
    const iterations = 200;
    const bailout = 4.0;

    final cases =
        <String, ({Vector2 pan, double zoom, Vector2 juliaC, String sha256})>{
      'mandelbrot': (
        pan: Vector2(-0.5, 0.0),
        zoom: 1.0,
        juliaC: Vector2(-0.8, 0.156),
        sha256:
            'aab217182dde83af4ec653d0fd9115e673f028d1c8f3d4c4c7cb0d45604268b9',
      ),
      'burning_ship': (
        pan: Vector2(-1.75, -0.03),
        zoom: 1.4,
        juliaC: Vector2(-0.8, 0.156),
        sha256:
            '9d78a1e17f1c522d00cf364255cf6e27d53de35ddac636198ca7c3fd6093492f',
      ),
      'tricorn': (
        pan: Vector2(-0.5, 0.0),
        zoom: 1.0,
        juliaC: Vector2(-0.8, 0.156),
        sha256:
            'dbd5f0f1a085556a3233bbc880515877c405fe89942df13f666ad3433a7f3542',
      ),
      'julia': (
        pan: Vector2(0.0, 0.0),
        zoom: 1.2,
        juliaC: Vector2(-0.8, 0.156),
        sha256:
            'c03aa8feab73ec6691dd8402fd53a7ce9f2d12ecff53e1b5cd1fe72a402d0886',
      ),
    };

    for (final e in cases.entries) {
      final buf = await renderCpuIterationBuffer(
        moduleId: e.key,
        viewPan: e.value.pan,
        viewZoom: e.value.zoom,
        iterations: iterations,
        bailout: bailout,
        juliaC: e.value.juliaC,
        width: w,
        height: h,
      );
      expect(buf, isNotNull,
          reason: 'Iteration buffer must be supported for ${e.key}');
      final bytes = Uint8List.view(buf!.buffer);
      final digest = sha256.convert(bytes).toString();
      print('${e.key} sha256=$digest');

      // First run will print digests; then replace TBD.
      expect(digest, e.value.sha256);
    }
  });
}
