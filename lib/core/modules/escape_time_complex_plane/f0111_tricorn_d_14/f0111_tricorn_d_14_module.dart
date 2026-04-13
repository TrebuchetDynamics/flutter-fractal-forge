// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0111_tricorn_d_14_presets.dart';
import 'f0111_tricorn_d_14_variants.dart';
import 'f0111_tricorn_d_14_metadata.dart';

/// Tricorn d=14 — Escape-Time (Complex Plane).
class F0111TricornD14 extends EscapeTimeModule {
  F0111TricornD14()
      : super(
          id: 'f0111_tricorn_d_14',
          shader: 'shaders/f0111_tricorn_d_14_gpu.frag',
        );

  @override
  F0111TricornD14Metadata get metadata => F0111TricornD14Metadata.instance;

  @override
  List<F0111TricornD14Preset> get presets => F0111TricornD14Presets.all;

  @override
  List<F0111TricornD14Variant> get variants => F0111TricornD14Variants.all;

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
