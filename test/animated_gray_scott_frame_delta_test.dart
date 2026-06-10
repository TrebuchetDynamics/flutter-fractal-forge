import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_fractals/features/renderer/render_validation.dart';
import 'package:flutter_test/flutter_test.dart';

const _shaderAsset = 'shaders/cellular_and_stochastic/gray_scott_rd_gpu.frag';
const _width = 128;
const _height = 128;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'gray_scott_rd has measurable procedural frame progression',
    () async {
      final program = await ui.FragmentProgram.fromAsset(_shaderAsset);

      // This shader intentionally slows animation internally with
      // `float time = uTime * 0.01`, so use wider validation samples than the
      // fast Lichtenberg growth-front test.
      final frame0 = await _renderGrayScottFrame(program, time: 0.0);
      final frame10 = await _renderGrayScottFrame(program, time: 10.0);
      final frame50 = await _renderGrayScottFrame(program, time: 50.0);

      final stats0 = validateRenderFrame(
        frame: frame0,
        width: _width,
        height: _height,
      );
      final stats10 = validateRenderFrame(
        frame: frame10,
        width: _width,
        height: _height,
      );
      final stats50 = validateRenderFrame(
        frame: frame50,
        width: _width,
        height: _height,
      );
      final delta0To10 = sampleRenderPair(
        frameA: frame0,
        frameB: frame10,
        width: _width,
        height: _height,
      );
      final delta10To50 = sampleRenderPair(
        frameA: frame10,
        frameB: frame50,
        width: _width,
        height: _height,
      );

      expect(stats0.histogramSane, isTrue);
      expect(stats10.histogramSane, isTrue);
      expect(stats50.histogramSane, isTrue);
      expect(
        RenderValidationThresholds.defaults.frameProgressedFor(
          delta0To10.progressionRatio,
        ),
        isTrue,
      );
      expect(
        RenderValidationThresholds.defaults.frameProgressedFor(
          delta10To50.progressionRatio,
        ),
        isTrue,
      );
      expect(
        RenderValidationThresholds.defaults.iterationDeltaVisibleFor(
          delta10To50.progressionRatio,
        ),
        isTrue,
      );

      // Keep exact evidence visible in test logs for future threshold tuning.
      // ignore: avoid_print
      print(
        '[animated-gray-scott] '
        'nonBlack=t0:${stats0.nonBlackRatio.toStringAsFixed(4)} '
        't10:${stats10.nonBlackRatio.toStringAsFixed(4)} '
        't50:${stats50.nonBlackRatio.toStringAsFixed(4)} '
        'delta0_10:${delta0To10.progressionRatio.toStringAsFixed(4)} '
        'delta10_50:${delta10To50.progressionRatio.toStringAsFixed(4)}',
      );
    },
    timeout: const Timeout(Duration(seconds: 60)),
  );
}

Future<Uint8List> _renderGrayScottFrame(
  ui.FragmentProgram program, {
  required double time,
}) async {
  final shader = program.fragmentShader();
  shader.setFloat(0, time);
  shader.setFloat(1, _width.toDouble());
  shader.setFloat(2, _height.toDouble());
  shader.setFloat(3, 0.0); // uCenter.x
  shader.setFloat(4, 0.0); // uCenter.y
  shader.setFloat(5, 1.0); // uZoom
  shader.setFloat(6, 120.0); // uIterations
  shader.setFloat(7, 4.0); // uBailout
  shader.setFloat(8, 0.0); // uColorScheme
  shader.setFloat(9, 0.0); // uTransparentBg
  shader.setFloat(10, 0.04); // uFeedRate
  shader.setFloat(11, 0.06); // uKillRate
  shader.setFloat(12, 8.0); // uScale

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
