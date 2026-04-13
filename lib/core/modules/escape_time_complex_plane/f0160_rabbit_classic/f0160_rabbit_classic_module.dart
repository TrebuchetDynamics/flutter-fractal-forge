// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0160_rabbit_classic_presets.dart';
import 'f0160_rabbit_classic_variants.dart';
import 'f0160_rabbit_classic_metadata.dart';

/// Rabbit (classic) — Escape-Time (Complex Plane).
class F0160RabbitClassic extends EscapeTimeModule {
  F0160RabbitClassic()
      : super(
          id: 'f0160_rabbit_classic',
          shader: 'shaders/f0160_rabbit_classic_gpu.frag',
        );

  @override
  F0160RabbitClassicMetadata get metadata => F0160RabbitClassicMetadata.instance;

  @override
  List<F0160RabbitClassicPreset> get presets => F0160RabbitClassicPresets.all;

  @override
  List<F0160RabbitClassicVariant> get variants => F0160RabbitClassicVariants.all;

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
