// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0093_multibrot_z_18_presets.dart';
import 'f0093_multibrot_z_18_variants.dart';
import 'f0093_multibrot_z_18_metadata.dart';

/// Multibrot z^18 — Escape-Time (Complex Plane).
class F0093MultibrotZ18 extends EscapeTimeModule {
  F0093MultibrotZ18()
      : super(
          id: 'f0093_multibrot_z_18',
          shader: 'shaders/f0093_multibrot_z_18_gpu.frag',
        );

  @override
  F0093MultibrotZ18Metadata get metadata => F0093MultibrotZ18Metadata.instance;

  @override
  List<F0093MultibrotZ18Preset> get presets => F0093MultibrotZ18Presets.all;

  @override
  List<F0093MultibrotZ18Variant> get variants => F0093MultibrotZ18Variants.all;

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
