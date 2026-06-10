import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_fractals/features/renderer/render_validation.dart';
import 'package:flutter_test/flutter_test.dart';

const _shaderAsset =
    'shaders/escape_time_family/geometry_and_ifs/fractal_flame_gpu.frag';
const _width = 128;
const _height = 128;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'fractal_flame preview has measurable time-parametric progression',
    () async {
      final program = await ui.FragmentProgram.fromAsset(_shaderAsset);

      // This validates the current single-pass IFS preview shader. It is not a
      // claim that true progressive flame histogram accumulation exists yet.
      final frame0 = await _renderFractalFlameFrame(program, time: 0.0);
      final frame1 = await _renderFractalFlameFrame(program, time: 1.0);
      final frame10 = await _renderFractalFlameFrame(program, time: 10.0);

      final stats0 = validateRenderFrame(
        frame: frame0,
        width: _width,
        height: _height,
      );
      final stats1 = validateRenderFrame(
        frame: frame1,
        width: _width,
        height: _height,
      );
      final stats10 = validateRenderFrame(
        frame: frame10,
        width: _width,
        height: _height,
      );
      final delta0To1 = sampleRenderPair(
        frameA: frame0,
        frameB: frame1,
        width: _width,
        height: _height,
      );
      final delta1To10 = sampleRenderPair(
        frameA: frame1,
        frameB: frame10,
        width: _width,
        height: _height,
      );

      expect(stats0.histogramSane, isTrue);
      expect(stats1.histogramSane, isTrue);
      expect(stats10.histogramSane, isTrue);
      expect(
        RenderValidationThresholds.defaults.frameProgressedFor(
          delta0To1.progressionRatio,
        ),
        isTrue,
      );
      expect(
        RenderValidationThresholds.defaults.frameProgressedFor(
          delta1To10.progressionRatio,
        ),
        isTrue,
      );
      expect(
        RenderValidationThresholds.defaults.iterationDeltaVisibleFor(
          delta1To10.progressionRatio,
        ),
        isTrue,
      );

      // Keep exact evidence visible in test logs for future threshold tuning.
      // ignore: avoid_print
      print(
        '[animated-fractal-flame] '
        'nonBlack=t0:${stats0.nonBlackRatio.toStringAsFixed(4)} '
        't1:${stats1.nonBlackRatio.toStringAsFixed(4)} '
        't10:${stats10.nonBlackRatio.toStringAsFixed(4)} '
        'delta0_1:${delta0To1.progressionRatio.toStringAsFixed(4)} '
        'delta1_10:${delta1To10.progressionRatio.toStringAsFixed(4)}',
      );
    },
    timeout: const Timeout(Duration(seconds: 60)),
  );
}

Future<Uint8List> _renderFractalFlameFrame(
  ui.FragmentProgram program, {
  required double time,
}) async {
  final shader = program.fragmentShader();
  shader.setFloat(0, time);
  shader.setFloat(1, _width.toDouble());
  shader.setFloat(2, _height.toDouble());
  shader.setFloat(3, 0.0); // uCenter.x
  shader.setFloat(4, 0.0); // uCenter.y
  shader.setFloat(5, 0.7); // uZoom
  shader.setFloat(6, 120.0); // uIterations
  shader.setFloat(7, 4.0); // uBailout
  shader.setFloat(8, 0.0); // uColorScheme
  shader.setFloat(9, 0.0); // uTransparentBg
  shader.setFloat(10, 3.0); // uVariation: swirl
  shader.setFloat(11, 2.0); // uSymmetry: 3-fold

  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  canvas.drawRect(
    Rect.fromLTWH(0, 0, _width.toDouble(), _height.toDouble()),
    Paint()..shader = shader,
  );
  final picture = recorder.endRecording();
  final image = await picture.toImage(_width, _height);
  final bytes = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
  picture.dispose();
  image.dispose();

  if (bytes == null) {
    throw StateError('Unable to read raw RGBA bytes from $_shaderAsset');
  }
  return bytes.buffer.asUint8List();
}
