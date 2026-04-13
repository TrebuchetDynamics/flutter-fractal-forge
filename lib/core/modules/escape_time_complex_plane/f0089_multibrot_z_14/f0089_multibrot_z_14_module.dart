// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0089_multibrot_z_14_presets.dart';
import 'f0089_multibrot_z_14_variants.dart';
import 'f0089_multibrot_z_14_metadata.dart';

/// Multibrot z^14 — Escape-Time (Complex Plane).
class F0089MultibrotZ14 extends EscapeTimeModule {
  F0089MultibrotZ14()
      : super(
          id: 'f0089_multibrot_z_14',
          shader: 'shaders/f0089_multibrot_z_14_gpu.frag',
        );

  @override
  F0089MultibrotZ14Metadata get metadata => F0089MultibrotZ14Metadata.instance;

  @override
  List<F0089MultibrotZ14Preset> get presets => F0089MultibrotZ14Presets.all;

  @override
  List<F0089MultibrotZ14Variant> get variants => F0089MultibrotZ14Variants.all;

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
