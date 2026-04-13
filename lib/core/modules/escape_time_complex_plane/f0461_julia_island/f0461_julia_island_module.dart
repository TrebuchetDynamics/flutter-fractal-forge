// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0461_julia_island_presets.dart';
import 'f0461_julia_island_variants.dart';
import 'f0461_julia_island_metadata.dart';

/// Julia Island — Escape-Time (Complex Plane).
class F0461JuliaIsland extends EscapeTimeModule {
  F0461JuliaIsland()
      : super(
          id: 'f0461_julia_island',
          shader: 'shaders/f0461_julia_island_gpu.frag',
        );

  @override
  F0461JuliaIslandMetadata get metadata => F0461JuliaIslandMetadata.instance;

  @override
  List<F0461JuliaIslandPreset> get presets => F0461JuliaIslandPresets.all;

  @override
  List<F0461JuliaIslandVariant> get variants => F0461JuliaIslandVariants.all;

  @override
  double get defaultPower => 2.0;

  @override
  double get defaultBailout => 4.0;

  @override
  int get defaultIterations => 2000;

  @override
  DeepZoomStrategy get deepZoom => DeepZoomStrategy.perturbation;

  @override
  void configureShader(ShaderParams p) {
    p.setFloat('power', defaultPower);
    p.setFloat('bailout', defaultBailout);
    p.setInt('iterations', defaultIterations);
  }
}
