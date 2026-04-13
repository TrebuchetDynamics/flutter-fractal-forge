// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0171_western_rabbit_presets.dart';
import 'f0171_western_rabbit_variants.dart';
import 'f0171_western_rabbit_metadata.dart';

/// Western Rabbit — Escape-Time (Complex Plane).
class F0171WesternRabbit extends EscapeTimeModule {
  F0171WesternRabbit()
      : super(
          id: 'f0171_western_rabbit',
          shader: 'shaders/f0171_western_rabbit_gpu.frag',
        );

  @override
  F0171WesternRabbitMetadata get metadata => F0171WesternRabbitMetadata.instance;

  @override
  List<F0171WesternRabbitPreset> get presets => F0171WesternRabbitPresets.all;

  @override
  List<F0171WesternRabbitVariant> get variants => F0171WesternRabbitVariants.all;

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
