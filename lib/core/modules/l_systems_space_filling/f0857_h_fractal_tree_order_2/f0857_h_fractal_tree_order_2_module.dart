// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/l_system_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0857_h_fractal_tree_order_2_presets.dart';
import 'f0857_h_fractal_tree_order_2_variants.dart';
import 'f0857_h_fractal_tree_order_2_metadata.dart';

/// H-Fractal Tree Order 2 — L-Systems & Space-Filling.
class F0857HFractalTreeOrder2 extends LSystemModule {
  F0857HFractalTreeOrder2()
      : super(
          id: 'f0857_h_fractal_tree_order_2',
          shader: 'shaders/f0857_h_fractal_tree_order_2_gpu.frag',
        );

  @override
  F0857HFractalTreeOrder2Metadata get metadata => F0857HFractalTreeOrder2Metadata.instance;

  @override
  List<F0857HFractalTreeOrder2Preset> get presets => F0857HFractalTreeOrder2Presets.all;

  @override
  List<F0857HFractalTreeOrder2Variant> get variants => F0857HFractalTreeOrder2Variants.all;

  @override
  int get defaultDepth => 4;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('depth', defaultDepth);
  }
}
