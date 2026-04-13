// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0539_newton_exp_presets.dart';
import 'f0539_newton_exp_variants.dart';
import 'f0539_newton_exp_metadata.dart';

/// Newton-exp — Escape-Time (Complex Plane).
class F0539NewtonExp extends EscapeTimeModule {
  F0539NewtonExp()
      : super(
          id: 'f0539_newton_exp',
          shader: 'shaders/f0539_newton_exp_gpu.frag',
        );

  @override
  F0539NewtonExpMetadata get metadata => F0539NewtonExpMetadata.instance;

  @override
  List<F0539NewtonExpPreset> get presets => F0539NewtonExpPresets.all;

  @override
  List<F0539NewtonExpVariant> get variants => F0539NewtonExpVariants.all;

  @override
  double get defaultPower => 2.0;

  @override
  double get defaultBailout => 50.0;

  @override
  int get defaultIterations => 300;

  @override
  DeepZoomStrategy get deepZoom => DeepZoomStrategy.perturbation;

  @override
  void configureShader(ShaderParams p) {
    p.setFloat('power', defaultPower);
    p.setFloat('bailout', defaultBailout);
    p.setInt('iterations', defaultIterations);
  }
}
