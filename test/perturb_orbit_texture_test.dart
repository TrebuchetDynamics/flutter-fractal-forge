import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter_fractals/core/modules/escape_time_perturb_module.dart';
import 'package:flutter_fractals/core/services/rendering/perturb_orbit_texture.dart';
import 'package:flutter_test/flutter_test.dart';

/// The pre-existing per-pixel drawRect rasterization, kept here as the
/// behavioral reference the batched implementation must match byte-for-byte.
ui.Image legacyDrawRectRasterize(Uint8List bytes, int totalPx) {
  final recorder = ui.PictureRecorder();
  final canvas = ui.Canvas(
    recorder,
    ui.Rect.fromLTWH(0, 0, totalPx.toDouble(), 1),
  );
  final paint = ui.Paint();
  for (int x = 0; x < totalPx; x++) {
    final i = x * 4;
    paint.color = ui.Color.fromARGB(
      bytes[i + 3],
      bytes[i + 0],
      bytes[i + 1],
      bytes[i + 2],
    );
    canvas.drawRect(ui.Rect.fromLTWH(x.toDouble(), 0, 1, 1), paint);
  }
  final picture = recorder.endRecording();
  try {
    return picture.toImageSync(totalPx, 1);
  } finally {
    picture.dispose();
  }
}

Future<Uint8List> readback(ui.Image image) async {
  final data = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
  return data!.buffer.asUint8List();
}

/// Adversarial pattern exercising every byte value in every channel
/// (alpha fixed at 255, matching the orbit encoding contract).
Uint8List adversarialBytes(int totalPx) {
  final bytes = Uint8List(totalPx * 4);
  for (int x = 0; x < totalPx; x++) {
    final i = x * 4;
    bytes[i] = x % 256;
    bytes[i + 1] = (x * 7 + 3) % 256;
    bytes[i + 2] = (x * 13 + 11) % 256;
    bytes[i + 3] = 255;
  }
  return bytes;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('perturb orbit texture rasterization (data-exactness contract)', () {
    test('batched output returns input bytes exactly (adversarial pattern)',
        () async {
      const totalPx = 4000; // 2000 iterations — the module clamp maximum.
      final bytes = adversarialBytes(totalPx);
      final image = rasterizePerturbOrbitBytes(bytes, totalPx);
      expect(image.width, totalPx);
      expect(image.height, 1);
      final out = await readback(image);
      expect(out, bytes, reason: 'rasterization must not alter orbit data');
      image.dispose();
    });

    test('batched output matches legacy drawRect path exactly', () async {
      const totalPx = 1000;
      final bytes = adversarialBytes(totalPx);
      final batched = rasterizePerturbOrbitBytes(bytes, totalPx);
      final legacy = legacyDrawRectRasterize(bytes, totalPx);
      expect(await readback(batched), await readback(legacy));
      batched.dispose();
      legacy.dispose();
    });

    test('real orbit bytes survive rasterization exactly', () async {
      const iterations = 500;
      final orbit = computeEscapeTimePerturbOrbitBytes(
        moduleId: 'mandelbrot',
        centerX: -1.9,
        centerY: 0.0,
        iterations: iterations,
      );
      final image = rasterizePerturbOrbitBytes(orbit.bytes, iterations * 2);
      expect(await readback(image), orbit.bytes);
      image.dispose();
    });

    test('consecutive different sizes do not corrupt buffer reuse', () async {
      for (final totalPx in [320, 4000, 320]) {
        final bytes = adversarialBytes(totalPx);
        final image = rasterizePerturbOrbitBytes(bytes, totalPx);
        expect(await readback(image), bytes, reason: 'size $totalPx');
        image.dispose();
      }
    });
  });
}
