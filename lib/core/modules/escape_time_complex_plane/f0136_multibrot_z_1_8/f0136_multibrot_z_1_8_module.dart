// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0136_multibrot_z_1_8_presets.dart';
import 'f0136_multibrot_z_1_8_variants.dart';
import 'f0136_multibrot_z_1_8_metadata.dart';

/// Multibrot z^1.8 — Escape-Time (Complex Plane).
class F0136MultibrotZ18 extends EscapeTimeModule {
  F0136MultibrotZ18()
      : super(
          id: 'f0136_multibrot_z_1_8',
          shader: 'shaders/f0136_multibrot_z_1_8_gpu.frag',
        );

  @override
  F0136MultibrotZ18Metadata get metadata => F0136MultibrotZ18Metadata.instance;

  @override
  List<F0136MultibrotZ18Preset> get presets => F0136MultibrotZ18Presets.all;

  @override
  List<F0136MultibrotZ18Variant> get variants => F0136MultibrotZ18Variants.all;

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
