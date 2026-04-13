// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0473_spiral_galaxy_zoom_presets.dart';
import 'f0473_spiral_galaxy_zoom_variants.dart';
import 'f0473_spiral_galaxy_zoom_metadata.dart';

/// Spiral Galaxy Zoom — Escape-Time (Complex Plane).
class F0473SpiralGalaxyZoom extends EscapeTimeModule {
  F0473SpiralGalaxyZoom()
      : super(
          id: 'f0473_spiral_galaxy_zoom',
          shader: 'shaders/f0473_spiral_galaxy_zoom_gpu.frag',
        );

  @override
  F0473SpiralGalaxyZoomMetadata get metadata => F0473SpiralGalaxyZoomMetadata.instance;

  @override
  List<F0473SpiralGalaxyZoomPreset> get presets => F0473SpiralGalaxyZoomPresets.all;

  @override
  List<F0473SpiralGalaxyZoomVariant> get variants => F0473SpiralGalaxyZoomVariants.all;

  @override
  double get defaultPower => 2.0;

  @override
  double get defaultBailout => 4.0;

  @override
  int get defaultIterations => 4000;

  @override
  DeepZoomStrategy get deepZoom => DeepZoomStrategy.perturbation;

  @override
  void configureShader(ShaderParams p) {
    p.setFloat('power', defaultPower);
    p.setFloat('bailout', defaultBailout);
    p.setInt('iterations', defaultIterations);
  }
}
