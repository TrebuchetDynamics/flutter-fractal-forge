// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0159_rabbit_baby_presets.dart';
import 'f0159_rabbit_baby_variants.dart';
import 'f0159_rabbit_baby_metadata.dart';

/// Rabbit Baby — Escape-Time (Complex Plane).
class F0159RabbitBaby extends EscapeTimeModule {
  F0159RabbitBaby()
      : super(
          id: 'f0159_rabbit_baby',
          shader: 'shaders/f0159_rabbit_baby_gpu.frag',
        );

  @override
  F0159RabbitBabyMetadata get metadata => F0159RabbitBabyMetadata.instance;

  @override
  List<F0159RabbitBabyPreset> get presets => F0159RabbitBabyPresets.all;

  @override
  List<F0159RabbitBabyVariant> get variants => F0159RabbitBabyVariants.all;

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
