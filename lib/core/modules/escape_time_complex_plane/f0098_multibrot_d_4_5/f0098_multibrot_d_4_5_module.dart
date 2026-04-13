// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0098_multibrot_d_4_5_presets.dart';
import 'f0098_multibrot_d_4_5_variants.dart';
import 'f0098_multibrot_d_4_5_metadata.dart';

/// Multibrot d=4.5 — Escape-Time (Complex Plane).
class F0098MultibrotD45 extends EscapeTimeModule {
  F0098MultibrotD45()
      : super(
          id: 'f0098_multibrot_d_4_5',
          shader: 'shaders/f0098_multibrot_d_4_5_gpu.frag',
        );

  @override
  F0098MultibrotD45Metadata get metadata => F0098MultibrotD45Metadata.instance;

  @override
  List<F0098MultibrotD45Preset> get presets => F0098MultibrotD45Presets.all;

  @override
  List<F0098MultibrotD45Variant> get variants => F0098MultibrotD45Variants.all;

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
