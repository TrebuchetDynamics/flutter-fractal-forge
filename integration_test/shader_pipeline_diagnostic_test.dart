/// Targeted diagnostic: isolates whether black output is due to
/// (A) the capture mechanism (toImage) being broken, or
/// (B) shader execution itself being broken on this emulator.
///
/// Run on the Android emulator:
///   flutter test integration_test/shader_pipeline_diagnostic_test.dart -d emulator-5554
library;

import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Shader Pipeline Diagnostic', () {
    // ── Test A: baseline – plain drawColor, no shader at all ──────────────
    testWidgets('A: PictureRecorder.toImage captures plain red drawColor',
        (tester) async {
      final recorder = ui.PictureRecorder();
      final canvas = ui.Canvas(recorder);
      canvas.drawColor(const ui.Color(0xFFFF0000), ui.BlendMode.src);
      final picture = recorder.endRecording();
      final image = await picture.toImage(64, 64);
      final bytes = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
      expect(bytes, isNotNull, reason: 'toByteData returned null');

      final data = bytes!.buffer.asUint8List();
      final cx = 32;
      final cy = 32;
      final idx = (cy * 64 + cx) * 4;
      final r = data[idx];
      final g = data[idx + 1];
      final b = data[idx + 2];

      debugPrint(
          '[diag] A plain_color center R=$r G=$g B=$b  '
          '→ ${r > 128 && g < 32 && b < 32 ? "PASS (red)" : "FAIL (not red, captured wrong color)"}');

      expect(r, greaterThan(128),
          reason: 'Center pixel should be RED (R>128), got R=$r G=$g B=$b');
      expect(g, lessThan(32), reason: 'Green channel should be near 0');
      expect(b, lessThan(32), reason: 'Blue channel should be near 0');
    });

    // ── Test B: drawRect with solid color Paint (no shader) ───────────────
    testWidgets('B: PictureRecorder.toImage captures solid-blue drawRect',
        (tester) async {
      final recorder = ui.PictureRecorder();
      final canvas = ui.Canvas(recorder);
      canvas.drawRect(
        const ui.Rect.fromLTWH(0, 0, 64, 64),
        ui.Paint()..color = const ui.Color(0xFF0000FF),
      );
      final picture = recorder.endRecording();
      final image = await picture.toImage(64, 64);
      final bytes = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
      expect(bytes, isNotNull);

      final data = bytes!.buffer.asUint8List();
      final idx = (32 * 64 + 32) * 4;
      final r = data[idx];
      final g = data[idx + 1];
      final b = data[idx + 2];

      debugPrint(
          '[diag] B solid_rect center R=$r G=$g B=$b  '
          '→ ${b > 128 && r < 32 ? "PASS (blue)" : "FAIL"}');

      expect(b, greaterThan(128),
          reason: 'Center pixel should be BLUE (B>128), got R=$r G=$g B=$b');
    });

    // ── Test C: LinearGradient shader (built-in Skia shader, no GLSL) ────
    testWidgets('C: PictureRecorder.toImage captures LinearGradient shader',
        (tester) async {
      const rect = ui.Rect.fromLTWH(0, 0, 64, 64);
      final gradient = ui.Gradient.linear(
        const ui.Offset(0, 0),
        const ui.Offset(64, 0),
        [const ui.Color(0xFFFF0000), const ui.Color(0xFF0000FF)],
      );

      final recorder = ui.PictureRecorder();
      final canvas = ui.Canvas(recorder);
      canvas.drawRect(rect, ui.Paint()..shader = gradient);
      final picture = recorder.endRecording();
      final image = await picture.toImage(64, 64);
      final bytes = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
      expect(bytes, isNotNull);

      final data = bytes!.buffer.asUint8List();
      // Left edge should be red
      final idxLeft = (32 * 64 + 4) * 4;
      final rLeft = data[idxLeft];
      // Right edge should be blue
      final idxRight = (32 * 64 + 60) * 4;
      final bRight = data[idxRight + 2];

      debugPrint(
          '[diag] C gradient left_R=$rLeft right_B=$bRight  '
          '→ ${rLeft > 64 ? "left≈red" : "left≈black"} '
          '${bRight > 64 ? "right≈blue" : "right≈black"}');

      // At least the gradient should produce SOME non-black output
      final totalNonBlack = _countNonBlack(data);
      debugPrint('[diag] C nonBlack=$totalNonBlack / ${64 * 64}');
      expect(totalNonBlack, greaterThan(0),
          reason: 'Gradient shader should produce non-black pixels');
    });

    // ── Test D: custom FragmentProgram (the actual failing case) ─────────
    testWidgets('D: PictureRecorder.toImage with always-red FragmentShader',
        (tester) async {
      late ui.FragmentProgram program;
      try {
        program = await ui.FragmentProgram.fromAsset(
            'shaders/test_always_red.frag');
      } catch (e) {
        debugPrint('[diag] D shader_load_failed: $e');
        fail('Could not load test_always_red.frag: $e');
      }

      final shader = program.fragmentShader();
      const rect = ui.Rect.fromLTWH(0, 0, 64, 64);

      final recorder = ui.PictureRecorder();
      final canvas = ui.Canvas(recorder);
      canvas.drawRect(rect, ui.Paint()..shader = shader);
      final picture = recorder.endRecording();

      final image = await picture.toImage(64, 64);
      final bytes = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
      expect(bytes, isNotNull);

      final data = bytes!.buffer.asUint8List();
      final idx = (32 * 64 + 32) * 4;
      final r = data[idx];
      final g = data[idx + 1];
      final b = data[idx + 2];
      final nonBlack = _countNonBlack(data);

      debugPrint(
          '[diag] D frag_shader center R=$r G=$g B=$b  '
          'nonBlack=$nonBlack/${64 * 64}  '
          '→ ${r > 128 ? "PASS (shader works!)" : "FAIL (shader still black)"}');

      // This is the critical test — expect non-black (red) output
      expect(r, greaterThan(128),
          reason:
              'test_always_red.frag should output red pixels, '
              'but got R=$r G=$g B=$b. '
              'If tests A-C pass but D fails, shader execution is broken '
              'on this emulator GPU backend.');
    });
  });
}

int _countNonBlack(Uint8List data) {
  int count = 0;
  for (int i = 0; i + 3 < data.length; i += 4) {
    if (data[i] > 8 || data[i + 1] > 8 || data[i + 2] > 8) count++;
  }
  return count;
}
