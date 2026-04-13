// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0537_newton_cos_presets.dart';
import 'f0537_newton_cos_variants.dart';
import 'f0537_newton_cos_metadata.dart';

/// Newton-cos — Escape-Time (Complex Plane).
class F0537NewtonCos extends EscapeTimeModule {
  F0537NewtonCos()
      : super(
          id: 'f0537_newton_cos',
          shader: 'shaders/f0537_newton_cos_gpu.frag',
        );

  @override
  F0537NewtonCosMetadata get metadata => F0537NewtonCosMetadata.instance;

  @override
  List<F0537NewtonCosPreset> get presets => F0537NewtonCosPresets.all;

  @override
  List<F0537NewtonCosVariant> get variants => F0537NewtonCosVariants.all;

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
