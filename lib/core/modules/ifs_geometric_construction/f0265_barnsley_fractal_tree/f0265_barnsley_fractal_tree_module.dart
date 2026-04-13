// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/ifs_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0265_barnsley_fractal_tree_presets.dart';
import 'f0265_barnsley_fractal_tree_variants.dart';
import 'f0265_barnsley_fractal_tree_metadata.dart';

/// Barnsley Fractal Tree — IFS & Geometric Construction.
class F0265BarnsleyFractalTree extends IFSModule {
  F0265BarnsleyFractalTree()
      : super(
          id: 'f0265_barnsley_fractal_tree',
          shader: 'shaders/f0265_barnsley_fractal_tree_gpu.frag',
        );

  @override
  F0265BarnsleyFractalTreeMetadata get metadata => F0265BarnsleyFractalTreeMetadata.instance;

  @override
  List<F0265BarnsleyFractalTreePreset> get presets => F0265BarnsleyFractalTreePresets.all;

  @override
  List<F0265BarnsleyFractalTreeVariant> get variants => F0265BarnsleyFractalTreeVariants.all;

  @override
  int get defaultIterations => 100000;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('iterations', defaultIterations);
  }
}
