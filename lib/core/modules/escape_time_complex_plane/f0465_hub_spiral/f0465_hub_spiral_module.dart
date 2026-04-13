// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0465_hub_spiral_presets.dart';
import 'f0465_hub_spiral_variants.dart';
import 'f0465_hub_spiral_metadata.dart';

/// Hub Spiral — Escape-Time (Complex Plane).
class F0465HubSpiral extends EscapeTimeModule {
  F0465HubSpiral()
      : super(
          id: 'f0465_hub_spiral',
          shader: 'shaders/f0465_hub_spiral_gpu.frag',
        );

  @override
  F0465HubSpiralMetadata get metadata => F0465HubSpiralMetadata.instance;

  @override
  List<F0465HubSpiralPreset> get presets => F0465HubSpiralPresets.all;

  @override
  List<F0465HubSpiralVariant> get variants => F0465HubSpiralVariants.all;

  @override
  double get defaultPower => 2.0;

  @override
  double get defaultBailout => 4.0;

  @override
  int get defaultIterations => 3500;

  @override
  DeepZoomStrategy get deepZoom => DeepZoomStrategy.perturbation;

  @override
  void configureShader(ShaderParams p) {
    p.setFloat('power', defaultPower);
    p.setFloat('bailout', defaultBailout);
    p.setInt('iterations', defaultIterations);
  }
}
