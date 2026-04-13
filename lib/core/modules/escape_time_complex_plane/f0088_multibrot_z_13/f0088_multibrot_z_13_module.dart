// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0088_multibrot_z_13_presets.dart';
import 'f0088_multibrot_z_13_variants.dart';
import 'f0088_multibrot_z_13_metadata.dart';

/// Multibrot z^13 — Escape-Time (Complex Plane).
class F0088MultibrotZ13 extends EscapeTimeModule {
  F0088MultibrotZ13()
      : super(
          id: 'f0088_multibrot_z_13',
          shader: 'shaders/f0088_multibrot_z_13_gpu.frag',
        );

  @override
  F0088MultibrotZ13Metadata get metadata => F0088MultibrotZ13Metadata.instance;

  @override
  List<F0088MultibrotZ13Preset> get presets => F0088MultibrotZ13Presets.all;

  @override
  List<F0088MultibrotZ13Variant> get variants => F0088MultibrotZ13Variants.all;

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
