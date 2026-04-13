// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0099_multibrot_d_5_5_presets.dart';
import 'f0099_multibrot_d_5_5_variants.dart';
import 'f0099_multibrot_d_5_5_metadata.dart';

/// Multibrot d=5.5 — Escape-Time (Complex Plane).
class F0099MultibrotD55 extends EscapeTimeModule {
  F0099MultibrotD55()
      : super(
          id: 'f0099_multibrot_d_5_5',
          shader: 'shaders/f0099_multibrot_d_5_5_gpu.frag',
        );

  @override
  F0099MultibrotD55Metadata get metadata => F0099MultibrotD55Metadata.instance;

  @override
  List<F0099MultibrotD55Preset> get presets => F0099MultibrotD55Presets.all;

  @override
  List<F0099MultibrotD55Variant> get variants => F0099MultibrotD55Variants.all;

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
