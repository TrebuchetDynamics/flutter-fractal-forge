// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0090_multibrot_z_15_presets.dart';
import 'f0090_multibrot_z_15_variants.dart';
import 'f0090_multibrot_z_15_metadata.dart';

/// Multibrot z^15 — Escape-Time (Complex Plane).
class F0090MultibrotZ15 extends EscapeTimeModule {
  F0090MultibrotZ15()
      : super(
          id: 'f0090_multibrot_z_15',
          shader: 'shaders/f0090_multibrot_z_15_gpu.frag',
        );

  @override
  F0090MultibrotZ15Metadata get metadata => F0090MultibrotZ15Metadata.instance;

  @override
  List<F0090MultibrotZ15Preset> get presets => F0090MultibrotZ15Presets.all;

  @override
  List<F0090MultibrotZ15Variant> get variants => F0090MultibrotZ15Variants.all;

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
