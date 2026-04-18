// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0771_gauss_map_fractal_presets.dart';
import 'f0771_gauss_map_fractal_variants.dart';
import 'f0771_gauss_map_fractal_metadata.dart';

/// Gauss Map Fractal — Number-Theory Fractals.
class F0771GaussMapFractal extends CellularModule {
  F0771GaussMapFractal()
      : super(
          id: 'f0771_gauss_map_fractal',
          shader: 'shaders/f0771_gauss_map_fractal_gpu.frag',
        );

  @override
  F0771GaussMapFractalMetadata get metadata => F0771GaussMapFractalMetadata.instance;

  @override
  List<F0771GaussMapFractalPreset> get presets => F0771GaussMapFractalPresets.all;

  @override
  List<F0771GaussMapFractalVariant> get variants => F0771GaussMapFractalVariants.all;

  @override
  int get defaultGenerations => 100;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
