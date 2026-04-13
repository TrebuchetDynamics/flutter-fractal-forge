// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0138_tricorn_z_1_5_presets.dart';
import 'f0138_tricorn_z_1_5_variants.dart';
import 'f0138_tricorn_z_1_5_metadata.dart';

/// Tricorn z^1.5 — Escape-Time (Complex Plane).
class F0138TricornZ15 extends EscapeTimeModule {
  F0138TricornZ15()
      : super(
          id: 'f0138_tricorn_z_1_5',
          shader: 'shaders/f0138_tricorn_z_1_5_gpu.frag',
        );

  @override
  F0138TricornZ15Metadata get metadata => F0138TricornZ15Metadata.instance;

  @override
  List<F0138TricornZ15Preset> get presets => F0138TricornZ15Presets.all;

  @override
  List<F0138TricornZ15Variant> get variants => F0138TricornZ15Variants.all;

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
