// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/l_system_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0856_h_fractal_tree_order_1_presets.dart';
import 'f0856_h_fractal_tree_order_1_variants.dart';
import 'f0856_h_fractal_tree_order_1_metadata.dart';

/// H-Fractal Tree Order 1 — L-Systems & Space-Filling.
class F0856HFractalTreeOrder1 extends LSystemModule {
  F0856HFractalTreeOrder1()
      : super(
          id: 'f0856_h_fractal_tree_order_1',
          shader: 'shaders/f0856_h_fractal_tree_order_1_gpu.frag',
        );

  @override
  F0856HFractalTreeOrder1Metadata get metadata => F0856HFractalTreeOrder1Metadata.instance;

  @override
  List<F0856HFractalTreeOrder1Preset> get presets => F0856HFractalTreeOrder1Presets.all;

  @override
  List<F0856HFractalTreeOrder1Variant> get variants => F0856HFractalTreeOrder1Variants.all;

  @override
  int get defaultDepth => 4;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('depth', defaultDepth);
  }
}
