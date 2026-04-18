// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f1231_douady_hubbard_rabbit_rational_presets.dart';
import 'f1231_douady_hubbard_rabbit_rational_variants.dart';
import 'f1231_douady_hubbard_rabbit_rational_metadata.dart';

/// Douady-Hubbard Rabbit (Rational) — Escape-Time (Complex Plane).
class F1231DouadyHubbardRabbitRational extends EscapeTimeModule {
  F1231DouadyHubbardRabbitRational()
      : super(
          id: 'f1231_douady_hubbard_rabbit_rational',
          shader: 'shaders/f1231_douady_hubbard_rabbit_rational_gpu.frag',
        );

  @override
  F1231DouadyHubbardRabbitRationalMetadata get metadata => F1231DouadyHubbardRabbitRationalMetadata.instance;

  @override
  List<F1231DouadyHubbardRabbitRationalPreset> get presets => F1231DouadyHubbardRabbitRationalPresets.all;

  @override
  List<F1231DouadyHubbardRabbitRationalVariant> get variants => F1231DouadyHubbardRabbitRationalVariants.all;

  @override
  double get defaultPower => 2.0;

  @override
  double get defaultBailout => 100.0;

  @override
  int get defaultIterations => 200;

  @override
  DeepZoomStrategy get deepZoom => DeepZoomStrategy.perturbation;

  @override
  void configureShader(ShaderParams p) {
    p.setFloat('power', defaultPower);
    p.setFloat('bailout', defaultBailout);
    p.setInt('iterations', defaultIterations);
  }
}
