// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0812_cusp_map_presets.dart';
import 'f0812_cusp_map_variants.dart';
import 'f0812_cusp_map_metadata.dart';

/// Cusp Map — Strange Attractors.
class F0812CuspMap extends AttractorModule {
  F0812CuspMap()
      : super(
          id: 'f0812_cusp_map',
          shader: 'shaders/f0812_cusp_map_gpu.frag',
        );

  @override
  F0812CuspMapMetadata get metadata => F0812CuspMapMetadata.instance;

  @override
  List<F0812CuspMapPreset> get presets => F0812CuspMapPresets.all;

  @override
  List<F0812CuspMapVariant> get variants => F0812CuspMapVariants.all;

  @override
  int get defaultIterations => 50000;

  @override
  double get defaultStepSize => 0.01;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('iterations', defaultIterations);
    p.setFloat('stepSize', defaultStepSize);
  }
}
