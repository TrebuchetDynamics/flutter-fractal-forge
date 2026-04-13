// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0104_inverse_multibrot_d_4_presets.dart';
import 'f0104_inverse_multibrot_d_4_variants.dart';
import 'f0104_inverse_multibrot_d_4_metadata.dart';

/// Inverse Multibrot d=-4 — Escape-Time (Complex Plane).
class F0104InverseMultibrotD4 extends EscapeTimeModule {
  F0104InverseMultibrotD4()
      : super(
          id: 'f0104_inverse_multibrot_d_4',
          shader: 'shaders/f0104_inverse_multibrot_d_4_gpu.frag',
        );

  @override
  F0104InverseMultibrotD4Metadata get metadata => F0104InverseMultibrotD4Metadata.instance;

  @override
  List<F0104InverseMultibrotD4Preset> get presets => F0104InverseMultibrotD4Presets.all;

  @override
  List<F0104InverseMultibrotD4Variant> get variants => F0104InverseMultibrotD4Variants.all;

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
