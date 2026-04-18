// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0825_arnold_cat_map_presets.dart';
import 'f0825_arnold_cat_map_variants.dart';
import 'f0825_arnold_cat_map_metadata.dart';

/// Arnold Cat Map — Strange Attractors.
class F0825ArnoldCatMap extends AttractorModule {
  F0825ArnoldCatMap()
      : super(
          id: 'f0825_arnold_cat_map',
          shader: 'shaders/f0825_arnold_cat_map_gpu.frag',
        );

  @override
  F0825ArnoldCatMapMetadata get metadata => F0825ArnoldCatMapMetadata.instance;

  @override
  List<F0825ArnoldCatMapPreset> get presets => F0825ArnoldCatMapPresets.all;

  @override
  List<F0825ArnoldCatMapVariant> get variants => F0825ArnoldCatMapVariants.all;

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
