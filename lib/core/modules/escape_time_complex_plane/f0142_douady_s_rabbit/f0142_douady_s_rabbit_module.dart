// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0142_douady_s_rabbit_presets.dart';
import 'f0142_douady_s_rabbit_variants.dart';
import 'f0142_douady_s_rabbit_metadata.dart';

/// Douady's Rabbit — Escape-Time (Complex Plane).
class F0142DouadySRabbit extends EscapeTimeModule {
  F0142DouadySRabbit()
      : super(
          id: 'f0142_douady_s_rabbit',
          shader: 'shaders/f0142_douady_s_rabbit_gpu.frag',
        );

  @override
  F0142DouadySRabbitMetadata get metadata => F0142DouadySRabbitMetadata.instance;

  @override
  List<F0142DouadySRabbitPreset> get presets => F0142DouadySRabbitPresets.all;

  @override
  List<F0142DouadySRabbitVariant> get variants => F0142DouadySRabbitVariants.all;

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
