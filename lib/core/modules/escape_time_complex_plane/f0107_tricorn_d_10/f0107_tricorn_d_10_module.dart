// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0107_tricorn_d_10_presets.dart';
import 'f0107_tricorn_d_10_variants.dart';
import 'f0107_tricorn_d_10_metadata.dart';

/// Tricorn d=10 — Escape-Time (Complex Plane).
class F0107TricornD10 extends EscapeTimeModule {
  F0107TricornD10()
      : super(
          id: 'f0107_tricorn_d_10',
          shader: 'shaders/f0107_tricorn_d_10_gpu.frag',
        );

  @override
  F0107TricornD10Metadata get metadata => F0107TricornD10Metadata.instance;

  @override
  List<F0107TricornD10Preset> get presets => F0107TricornD10Presets.all;

  @override
  List<F0107TricornD10Variant> get variants => F0107TricornD10Variants.all;

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
