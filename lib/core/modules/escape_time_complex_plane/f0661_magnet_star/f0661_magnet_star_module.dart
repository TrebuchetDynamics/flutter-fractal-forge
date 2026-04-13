// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0661_magnet_star_presets.dart';
import 'f0661_magnet_star_variants.dart';
import 'f0661_magnet_star_metadata.dart';

/// Magnet-Star — Escape-Time (Complex Plane).
class F0661MagnetStar extends EscapeTimeModule {
  F0661MagnetStar()
      : super(
          id: 'f0661_magnet_star',
          shader: 'shaders/f0661_magnet_star_gpu.frag',
        );

  @override
  F0661MagnetStarMetadata get metadata => F0661MagnetStarMetadata.instance;

  @override
  List<F0661MagnetStarPreset> get presets => F0661MagnetStarPresets.all;

  @override
  List<F0661MagnetStarVariant> get variants => F0661MagnetStarVariants.all;

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
