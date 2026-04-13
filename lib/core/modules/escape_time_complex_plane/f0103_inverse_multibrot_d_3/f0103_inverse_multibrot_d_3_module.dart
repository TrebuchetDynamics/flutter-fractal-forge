// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0103_inverse_multibrot_d_3_presets.dart';
import 'f0103_inverse_multibrot_d_3_variants.dart';
import 'f0103_inverse_multibrot_d_3_metadata.dart';

/// Inverse Multibrot d=-3 — Escape-Time (Complex Plane).
class F0103InverseMultibrotD3 extends EscapeTimeModule {
  F0103InverseMultibrotD3()
      : super(
          id: 'f0103_inverse_multibrot_d_3',
          shader: 'shaders/f0103_inverse_multibrot_d_3_gpu.frag',
        );

  @override
  F0103InverseMultibrotD3Metadata get metadata => F0103InverseMultibrotD3Metadata.instance;

  @override
  List<F0103InverseMultibrotD3Preset> get presets => F0103InverseMultibrotD3Presets.all;

  @override
  List<F0103InverseMultibrotD3Variant> get variants => F0103InverseMultibrotD3Variants.all;

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
