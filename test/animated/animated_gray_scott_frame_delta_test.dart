import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter_fractals/features/renderer/validation/render_validation.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/render_test_shader.dart';

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
}) =>
    renderTestShaderFrame(
      program: program,
      shaderAsset: _shaderAsset,
      width: _width,
      height: _height,
      uniforms: [
        time,
        _width.toDouble(),
        _height.toDouble(),
        0.0, // uCenter.x
        0.0, // uCenter.y
        1.0, // uZoom
        120.0, // uIterations
        4.0, // uBailout
        0.0, // uColorScheme
        0.0, // uTransparentBg
        0.04, // uFeedRate
        0.06, // uKillRate
        8.0, // uScale
      ],
    );
