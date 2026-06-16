import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_fractals/core/models/fractal_parameter.dart';
import 'package:flutter_fractals/core/modules/builders/built_in_preset_contract.dart';
import 'package:flutter_fractals/core/models/fractal_view_state.dart';
import 'package:flutter_fractals/core/modules/fractal_module.dart';
import 'package:vector_math/vector_math.dart';

/// Diagnostic module: tests sampler2D path in FragmentShader.
FractalModule buildGpuSamplerDiagModule() {
  final defaultPreset = catalogPreset(
    id: 'gpu-sampler-diag-default',
    moduleId: 'gpu_sampler_diag',
    name: 'Default',
    params: const {},
    view: FractalViewState(
      pan: Vector2.zero(),
      zoom: 1.0,
      rotation: Vector3.zero(),
    ),
  );

  return FractalModule(
    id: 'gpu_sampler_diag',
    displayName: (l10n) => 'GPU Sampler (Diag)',
    dimension: FractalDimension.twoD,
    shaderAsset: 'shaders/diagnostic/diag_sampler.frag',
    parameters: const <FractalParameter>[],
    defaultPreset: defaultPreset,
    builtInPresets: [defaultPreset],
    setUniforms: (shader, state, size, time) {
      shader.setFloat(0, size.width);
      shader.setFloat(1, size.height);

      // Provide a tiny 1x1 red texture.
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder, const Rect.fromLTWH(0, 0, 1, 1));
      canvas.drawRect(const Rect.fromLTWH(0, 0, 1, 1),
          Paint()..color = const Color(0xFFFF0000));
      final picture = recorder.endRecording();
      final img = picture.toImageSync(1, 1);
      shader.setImageSampler(0, img);
    },
  );
}
