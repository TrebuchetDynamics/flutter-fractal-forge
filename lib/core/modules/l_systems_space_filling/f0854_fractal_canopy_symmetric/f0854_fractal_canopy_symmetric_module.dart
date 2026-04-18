// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/l_system_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0854_fractal_canopy_symmetric_presets.dart';
import 'f0854_fractal_canopy_symmetric_variants.dart';
import 'f0854_fractal_canopy_symmetric_metadata.dart';

/// Fractal Canopy Symmetric — L-Systems & Space-Filling.
class F0854FractalCanopySymmetric extends LSystemModule {
  F0854FractalCanopySymmetric()
      : super(
          id: 'f0854_fractal_canopy_symmetric',
          shader: 'shaders/f0854_fractal_canopy_symmetric_gpu.frag',
        );

  @override
  F0854FractalCanopySymmetricMetadata get metadata => F0854FractalCanopySymmetricMetadata.instance;

  @override
  List<F0854FractalCanopySymmetricPreset> get presets => F0854FractalCanopySymmetricPresets.all;

  @override
  List<F0854FractalCanopySymmetricVariant> get variants => F0854FractalCanopySymmetricVariants.all;

  @override
  int get defaultDepth => 4;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('depth', defaultDepth);
  }
}
