// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0091_multibrot_z_16_presets.dart';
import 'f0091_multibrot_z_16_variants.dart';
import 'f0091_multibrot_z_16_metadata.dart';

/// Multibrot z^16 — Escape-Time (Complex Plane).
class F0091MultibrotZ16 extends EscapeTimeModule {
  F0091MultibrotZ16()
      : super(
          id: 'f0091_multibrot_z_16',
          shader: 'shaders/f0091_multibrot_z_16_gpu.frag',
        );

  @override
  F0091MultibrotZ16Metadata get metadata => F0091MultibrotZ16Metadata.instance;

  @override
  List<F0091MultibrotZ16Preset> get presets => F0091MultibrotZ16Presets.all;

  @override
  List<F0091MultibrotZ16Variant> get variants => F0091MultibrotZ16Variants.all;

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
