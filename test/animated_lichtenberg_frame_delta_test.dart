import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_fractals/features/renderer/render_validation.dart';
import 'package:flutter_test/flutter_test.dart';

const _shaderAsset = 'shaders/cellular_and_stochastic/lichtenberg_growth_gpu.frag';
const _width = 128;
const _height = 128;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'lichtenberg_growth has measurable frame progression at t=0, 0.5, 1.0',
    () async {
      final program = await ui.FragmentProgram.fromAsset(_shaderAsset);

      final frame0 = await _renderLichtenbergFrame(program, time: 0.0);
      final frame05 = await _renderLichtenbergFrame(program, time: 0.5);
      final frame1 = await _renderLichtenbergFrame(program, time: 1.0);

      final stats0 = validateRenderFrame(
        frame: frame0,
        width: _width,
        height: _height,
      );
      final stats05 = validateRenderFrame(
        frame: frame05,
        width: _width,
        height: _height,
      );
      final stats1 = validateRenderFrame(
        frame: frame1,
        width: _width,
        height: _height,
      );
      final delta0To05 = sampleRenderPair(
        frameA: frame0,
        frameB: frame05,
        width: _width,
        height: _height,
      );
      final delta05To1 = sampleRenderPair(
        frameA: frame05,
        frameB: frame1,
        width: _width,
        height: _height,
      );

      // t=0 is allowed to be the seed state before any visible growth. Later
      // requested frames must prove visible content and measurable progression.
      expect(stats0.nonBlackRatio, 0.0);
      expect(stats05.histogramSane, isTrue);
      expect(stats1.histogramSane, isTrue);
      expect(
        RenderValidationThresholds.defaults.frameProgressedFor(
          delta0To05.progressionRatio,
        ),
        isTrue,
      );
      expect(
        RenderValidationThresholds.defaults.frameProgressedFor(
          delta05To1.progressionRatio,
        ),
        isTrue,
      );
      expect(
        RenderValidationThresholds.defaults.iterationDeltaVisibleFor(
          delta05To1.progressionRatio,
        ),
        isTrue,
      );

      // Keep exact evidence visible in test logs for future threshold tuning.
      // ignore: avoid_print
      print(
        '[animated-lichtenberg] '
        'nonBlack=t0:${stats0.nonBlackRatio.toStringAsFixed(4)} '
        't05:${stats05.nonBlackRatio.toStringAsFixed(4)} '
        't1:${stats1.nonBlackRatio.toStringAsFixed(4)} '
        'delta0_05:${delta0To05.progressionRatio.toStringAsFixed(4)} '
        'delta05_1:${delta05To1.progressionRatio.toStringAsFixed(4)}',
      );
    },
    timeout: const Timeout(Duration(seconds: 60)),
  );
}

Future<Uint8List> _renderLichtenbergFrame(
  ui.FragmentProgram program, {
  required double time,
}) async {
  final shader = program.fragmentShader();
  shader.setFloat(0, time);
  shader.setFloat(1, _width.toDouble());
  shader.setFloat(2, _height.toDouble());
  shader.setFloat(3, 0.0); // uCenter.x
  shader.setFloat(4, 0.0); // uCenter.y
  shader.setFloat(5, 8.0); // uZoom: zoomed in so early growth is measurable
  shader.setFloat(6, 50.0); // uIterations
  shader.setFloat(7, 4.0); // uBailout
  shader.setFloat(8, 0.0); // uColorScheme
  shader.setFloat(9, 0.0); // uTransparentBg
  shader.setFloat(10, 1.0); // uGrowthSpeed
  shader.setFloat(11, 0.8); // uBranchAngle
  shader.setFloat(12, 8.0); // uComplexity

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
