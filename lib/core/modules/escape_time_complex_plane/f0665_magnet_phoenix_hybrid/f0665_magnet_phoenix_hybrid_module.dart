// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0665_magnet_phoenix_hybrid_presets.dart';
import 'f0665_magnet_phoenix_hybrid_variants.dart';
import 'f0665_magnet_phoenix_hybrid_metadata.dart';

/// Magnet-Phoenix hybrid — Escape-Time (Complex Plane).
class F0665MagnetPhoenixHybrid extends EscapeTimeModule {
  F0665MagnetPhoenixHybrid()
      : super(
          id: 'f0665_magnet_phoenix_hybrid',
          shader: 'shaders/f0665_magnet_phoenix_hybrid_gpu.frag',
        );

  @override
  F0665MagnetPhoenixHybridMetadata get metadata => F0665MagnetPhoenixHybridMetadata.instance;

  @override
  List<F0665MagnetPhoenixHybridPreset> get presets => F0665MagnetPhoenixHybridPresets.all;

  @override
  List<F0665MagnetPhoenixHybridVariant> get variants => F0665MagnetPhoenixHybridVariants.all;

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
