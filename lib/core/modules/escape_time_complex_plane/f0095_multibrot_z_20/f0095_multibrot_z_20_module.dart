// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0095_multibrot_z_20_presets.dart';
import 'f0095_multibrot_z_20_variants.dart';
import 'f0095_multibrot_z_20_metadata.dart';

/// Multibrot z^20 — Escape-Time (Complex Plane).
class F0095MultibrotZ20 extends EscapeTimeModule {
  F0095MultibrotZ20()
      : super(
          id: 'f0095_multibrot_z_20',
          shader: 'shaders/f0095_multibrot_z_20_gpu.frag',
        );

  @override
  F0095MultibrotZ20Metadata get metadata => F0095MultibrotZ20Metadata.instance;

  @override
  List<F0095MultibrotZ20Preset> get presets => F0095MultibrotZ20Presets.all;

  @override
  List<F0095MultibrotZ20Variant> get variants => F0095MultibrotZ20Variants.all;

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
