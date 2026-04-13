// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0110_tricorn_d_13_presets.dart';
import 'f0110_tricorn_d_13_variants.dart';
import 'f0110_tricorn_d_13_metadata.dart';

/// Tricorn d=13 — Escape-Time (Complex Plane).
class F0110TricornD13 extends EscapeTimeModule {
  F0110TricornD13()
      : super(
          id: 'f0110_tricorn_d_13',
          shader: 'shaders/f0110_tricorn_d_13_gpu.frag',
        );

  @override
  F0110TricornD13Metadata get metadata => F0110TricornD13Metadata.instance;

  @override
  List<F0110TricornD13Preset> get presets => F0110TricornD13Presets.all;

  @override
  List<F0110TricornD13Variant> get variants => F0110TricornD13Variants.all;

  @override
  double get defaultPower => 2.0;

  @override
  double get defaultBailout => 4.0;

  @override
  int get defaultIterations => 500;

  @override
  DeepZoomStrategy get deepZoom => DeepZoomStrategy.perturbation;

  @override
  void configureShader(ShaderParams p) {
    p.setFloat('power', defaultPower);
    p.setFloat('bailout', defaultBailout);
    p.setInt('iterations', defaultIterations);
  }
}
