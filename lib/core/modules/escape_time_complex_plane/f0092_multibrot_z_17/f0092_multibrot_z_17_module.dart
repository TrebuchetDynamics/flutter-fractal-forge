// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0092_multibrot_z_17_presets.dart';
import 'f0092_multibrot_z_17_variants.dart';
import 'f0092_multibrot_z_17_metadata.dart';

/// Multibrot z^17 — Escape-Time (Complex Plane).
class F0092MultibrotZ17 extends EscapeTimeModule {
  F0092MultibrotZ17()
      : super(
          id: 'f0092_multibrot_z_17',
          shader: 'shaders/f0092_multibrot_z_17_gpu.frag',
        );

  @override
  F0092MultibrotZ17Metadata get metadata => F0092MultibrotZ17Metadata.instance;

  @override
  List<F0092MultibrotZ17Preset> get presets => F0092MultibrotZ17Presets.all;

  @override
  List<F0092MultibrotZ17Variant> get variants => F0092MultibrotZ17Variants.all;

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
