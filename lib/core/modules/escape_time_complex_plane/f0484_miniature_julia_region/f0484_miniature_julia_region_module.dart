// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0484_miniature_julia_region_presets.dart';
import 'f0484_miniature_julia_region_variants.dart';
import 'f0484_miniature_julia_region_metadata.dart';

/// Miniature Julia Region — Escape-Time (Complex Plane).
class F0484MiniatureJuliaRegion extends EscapeTimeModule {
  F0484MiniatureJuliaRegion()
      : super(
          id: 'f0484_miniature_julia_region',
          shader: 'shaders/f0484_miniature_julia_region_gpu.frag',
        );

  @override
  F0484MiniatureJuliaRegionMetadata get metadata => F0484MiniatureJuliaRegionMetadata.instance;

  @override
  List<F0484MiniatureJuliaRegionPreset> get presets => F0484MiniatureJuliaRegionPresets.all;

  @override
  List<F0484MiniatureJuliaRegionVariant> get variants => F0484MiniatureJuliaRegionVariants.all;

  @override
  double get defaultPower => 2.0;

  @override
  double get defaultBailout => 4.0;

  @override
  int get defaultIterations => 2500;

  @override
  DeepZoomStrategy get deepZoom => DeepZoomStrategy.perturbation;

  @override
  void configureShader(ShaderParams p) {
    p.setFloat('power', defaultPower);
    p.setFloat('bailout', defaultBailout);
    p.setInt('iterations', defaultIterations);
  }
}
