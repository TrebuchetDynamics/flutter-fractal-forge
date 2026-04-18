// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0757_stern_brocot_tree_fractal_presets.dart';
import 'f0757_stern_brocot_tree_fractal_variants.dart';
import 'f0757_stern_brocot_tree_fractal_metadata.dart';

/// Stern-Brocot Tree Fractal — Number-Theory Fractals.
class F0757SternBrocotTreeFractal extends CellularModule {
  F0757SternBrocotTreeFractal()
      : super(
          id: 'f0757_stern_brocot_tree_fractal',
          shader: 'shaders/f0757_stern_brocot_tree_fractal_gpu.frag',
        );

  @override
  F0757SternBrocotTreeFractalMetadata get metadata => F0757SternBrocotTreeFractalMetadata.instance;

  @override
  List<F0757SternBrocotTreeFractalPreset> get presets => F0757SternBrocotTreeFractalPresets.all;

  @override
  List<F0757SternBrocotTreeFractalVariant> get variants => F0757SternBrocotTreeFractalVariants.all;

  @override
  int get defaultGenerations => 100;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
