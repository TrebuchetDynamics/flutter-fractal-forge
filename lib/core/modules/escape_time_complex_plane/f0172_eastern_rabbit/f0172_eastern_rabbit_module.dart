// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0172_eastern_rabbit_presets.dart';
import 'f0172_eastern_rabbit_variants.dart';
import 'f0172_eastern_rabbit_metadata.dart';

/// Eastern Rabbit — Escape-Time (Complex Plane).
class F0172EasternRabbit extends EscapeTimeModule {
  F0172EasternRabbit()
      : super(
          id: 'f0172_eastern_rabbit',
          shader: 'shaders/f0172_eastern_rabbit_gpu.frag',
        );

  @override
  F0172EasternRabbitMetadata get metadata => F0172EasternRabbitMetadata.instance;

  @override
  List<F0172EasternRabbitPreset> get presets => F0172EasternRabbitPresets.all;

  @override
  List<F0172EasternRabbitVariant> get variants => F0172EasternRabbitVariants.all;

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
