import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter_fractals/core/modules/escape_time_perturb_module.dart';
import 'package:flutter_fractals/core/services/rendering/perturb_orbit_texture.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

/// On-device acceptance check for the batched orbit-texture rasterizer.
///
/// The orbit texture is a DATA texture: the shader decodes 24-bit fixed point
/// from the raw channel bytes, so real-GPU rasterization (unlike the software
/// rasterizer used by `flutter test`) must be proven to return every byte
/// unchanged. Run with e.g.:
///   flutter test integration_test/rendering/perturb_orbit_texture_gpu_test.dart -d linux
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  Future<Uint8List> readback(ui.Image image) async {
    final data = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
    return data!.buffer.asUint8List();
  }

  testWidgets('GPU rasterization returns orbit bytes exactly',
      (tester) async {
    await tester.runAsync(() async {
      // Adversarial pattern: every byte value in every channel.
      const totalPx = 4000;
      final bytes = Uint8List(totalPx * 4);
      for (int x = 0; x < totalPx; x++) {
        final i = x * 4;
        bytes[i] = x % 256;
        bytes[i + 1] = (x * 7 + 3) % 256;
        bytes[i + 2] = (x * 13 + 11) % 256;
        bytes[i + 3] = 255;
      }
      final image = rasterizePerturbOrbitBytes(bytes, totalPx);
      final out = await readback(image);
      expect(out, bytes,
          reason: 'GPU rasterization altered orbit data bytes');
      image.dispose();
    });
  });

  testWidgets('GPU rasterization preserves a real reference orbit',
      (tester) async {
    await tester.runAsync(() async {
      const iterations = 2000;
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
  });
}
