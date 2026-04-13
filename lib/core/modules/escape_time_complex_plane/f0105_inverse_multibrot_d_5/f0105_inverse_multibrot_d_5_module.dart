// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0105_inverse_multibrot_d_5_presets.dart';
import 'f0105_inverse_multibrot_d_5_variants.dart';
import 'f0105_inverse_multibrot_d_5_metadata.dart';

/// Inverse Multibrot d=-5 — Escape-Time (Complex Plane).
class F0105InverseMultibrotD5 extends EscapeTimeModule {
  F0105InverseMultibrotD5()
      : super(
          id: 'f0105_inverse_multibrot_d_5',
          shader: 'shaders/f0105_inverse_multibrot_d_5_gpu.frag',
        );

  @override
  F0105InverseMultibrotD5Metadata get metadata => F0105InverseMultibrotD5Metadata.instance;

  @override
  List<F0105InverseMultibrotD5Preset> get presets => F0105InverseMultibrotD5Presets.all;

  @override
  List<F0105InverseMultibrotD5Variant> get variants => F0105InverseMultibrotD5Variants.all;

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
