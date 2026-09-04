import 'dart:ui' as ui;

import 'package:flutter_fractals/core/models/fractal_palette.dart';
import 'package:flutter_fractals/core/services/rendering/palette/palette_texture_cache.dart';
import 'package:flutter_test/flutter_test.dart';

final _palettes = [
  FractalPalette(id: 'highlight', name: 'Highlight', stops: const [
    FractalColorStop(position: 0, colorArgb: 0xFF14092A),
    FractalColorStop(position: 0.22, colorArgb: 0xFF14092A),
    FractalColorStop(position: 0.25, colorArgb: 0xFFFFEEC0),
    FractalColorStop(position: 0.28, colorArgb: 0xFF14092A),
    FractalColorStop(position: 1, colorArgb: 0xFF00C9FF),
  ]),
  FractalPalette(id: 'alpha', name: 'Alpha', stops: const [
    FractalColorStop(position: 0, colorArgb: 0x0000FF00),
    FractalColorStop(position: 0.35, colorArgb: 0x80FF0080),
    FractalColorStop(position: 0.35, colorArgb: 0xFF00FFFF),
    FractalColorStop(position: 1, colorArgb: 0x20FFFFFF),
  ]),
];

// Frozen per-pixel reference, independent of the optimized band renderer.
// Keep the floating-point pixel lookup: at count=51, x=155 rounds into band 30.
ui.Image _referenceTexture(int count, double mix) {
  ui.Color sample(FractalPalette palette, double t) {
    final stops = palette.stops;
    for (var i = 1; i < stops.length; i++) {
      if (t <= stops[i].position) {
        final previous = stops[i - 1];
        final next = stops[i];
        final span = next.position - previous.position;
        return ui.Color.lerp(previous.color, next.color,
            span <= 0 ? 0 : (t - previous.position) / span)!;
      }
    }
    return stops.last.color;
  }

  final recorder = ui.PictureRecorder();
  final canvas = ui.Canvas(recorder);
  final paint = ui.Paint();
  for (var x = 0; x < 256; x++) {
    final band = (x / 255 * count).floor().clamp(0, count - 1);
    final t = (band + 0.5) / count;
    paint.color =
        ui.Color.lerp(sample(_palettes[0], t), sample(_palettes[1], t), mix)!;
    canvas.drawRect(ui.Rect.fromLTWH(x.toDouble(), 0, 1, 1), paint);
  }
  final picture = recorder.endRecording();
  try {
    return picture.toImageSync(256, 1);
  } finally {
    picture.dispose();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('all band counts preserve RGBA pixels, highlights and blend boundaries',
      () async {
    final cache = PaletteTextureCache();
    addTearDown(cache.clear);
    for (var count = 2; count <= 64; count++) {
      for (final mix in [0.0, 0.25, 0.5, 0.75, 1.0]) {
        final expected = _referenceTexture(count, mix);
        try {
          final actual = cache.paletteTextureForIndex(
            mix,
            (index) => _palettes[index],
            colorCount: count,
          );
          expect(
            (await actual.toByteData())!.buffer.asUint8List(),
            orderedEquals((await expected.toByteData())!.buffer.asUint8List()),
            reason: 'colorCount=$count, mix=$mix',
          );
        } finally {
          expected.dispose();
        }
      }
    }
  });

  // Opt in with --dart-define=PALETTE_BENCHMARK=true. Report timings without
  // asserting machine-dependent thresholds in the regular test suite.
  test('palette cache-miss benchmark', () async {
    final cache = PaletteTextureCache();
    addTearDown(cache.clear);
    for (final count in [2, 24, 64]) {
      final samples = <double>[];
      for (var round = 0; round < 9; round++) {
        cache.clear();
        final watch = Stopwatch()..start();
        late ui.Image last;
        for (var i = 1; i < 256; i++) {
          last = cache.paletteTextureForIndex(
            i / 256,
            (index) => _palettes[index],
            colorCount: count,
          );
        }
        watch.stop();
        // Drain raster work before the next batch; measure UI-thread creation.
        await last.toByteData();
        if (round >= 2) samples.add(watch.elapsedMicroseconds / 255);
      }
      samples.sort();
      // ignore: avoid_print
      print('PALETTE_BENCH count=$count median_us=${samples[3]}');
    }
  }, skip: !const bool.fromEnvironment('PALETTE_BENCHMARK'));
}
