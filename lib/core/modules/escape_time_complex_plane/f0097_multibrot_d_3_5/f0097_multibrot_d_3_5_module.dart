// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0097_multibrot_d_3_5_presets.dart';
import 'f0097_multibrot_d_3_5_variants.dart';
import 'f0097_multibrot_d_3_5_metadata.dart';

/// Multibrot d=3.5 — Escape-Time (Complex Plane).
class F0097MultibrotD35 extends EscapeTimeModule {
  F0097MultibrotD35()
      : super(
          id: 'f0097_multibrot_d_3_5',
          shader: 'shaders/f0097_multibrot_d_3_5_gpu.frag',
        );

  @override
  F0097MultibrotD35Metadata get metadata => F0097MultibrotD35Metadata.instance;

  @override
  List<F0097MultibrotD35Preset> get presets => F0097MultibrotD35Presets.all;

  @override
  List<F0097MultibrotD35Variant> get variants => F0097MultibrotD35Variants.all;

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
