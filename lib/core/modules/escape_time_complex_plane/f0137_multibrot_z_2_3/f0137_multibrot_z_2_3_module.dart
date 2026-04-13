// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0137_multibrot_z_2_3_presets.dart';
import 'f0137_multibrot_z_2_3_variants.dart';
import 'f0137_multibrot_z_2_3_metadata.dart';

/// Multibrot z^2.3 — Escape-Time (Complex Plane).
class F0137MultibrotZ23 extends EscapeTimeModule {
  F0137MultibrotZ23()
      : super(
          id: 'f0137_multibrot_z_2_3',
          shader: 'shaders/f0137_multibrot_z_2_3_gpu.frag',
        );

  @override
  F0137MultibrotZ23Metadata get metadata => F0137MultibrotZ23Metadata.instance;

  @override
  List<F0137MultibrotZ23Preset> get presets => F0137MultibrotZ23Presets.all;

  @override
  List<F0137MultibrotZ23Variant> get variants => F0137MultibrotZ23Variants.all;

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
