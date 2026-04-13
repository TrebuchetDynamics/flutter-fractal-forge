// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0100_multibrot_d_6_5_presets.dart';
import 'f0100_multibrot_d_6_5_variants.dart';
import 'f0100_multibrot_d_6_5_metadata.dart';

/// Multibrot d=6.5 — Escape-Time (Complex Plane).
class F0100MultibrotD65 extends EscapeTimeModule {
  F0100MultibrotD65()
      : super(
          id: 'f0100_multibrot_d_6_5',
          shader: 'shaders/f0100_multibrot_d_6_5_gpu.frag',
        );

  @override
  F0100MultibrotD65Metadata get metadata => F0100MultibrotD65Metadata.instance;

  @override
  List<F0100MultibrotD65Preset> get presets => F0100MultibrotD65Presets.all;

  @override
  List<F0100MultibrotD65Variant> get variants => F0100MultibrotD65Variants.all;

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
