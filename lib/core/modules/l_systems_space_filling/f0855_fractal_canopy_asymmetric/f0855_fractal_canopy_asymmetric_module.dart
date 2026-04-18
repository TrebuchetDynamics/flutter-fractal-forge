// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/l_system_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0855_fractal_canopy_asymmetric_presets.dart';
import 'f0855_fractal_canopy_asymmetric_variants.dart';
import 'f0855_fractal_canopy_asymmetric_metadata.dart';

/// Fractal Canopy Asymmetric — L-Systems & Space-Filling.
class F0855FractalCanopyAsymmetric extends LSystemModule {
  F0855FractalCanopyAsymmetric()
      : super(
          id: 'f0855_fractal_canopy_asymmetric',
          shader: 'shaders/f0855_fractal_canopy_asymmetric_gpu.frag',
        );

  @override
  F0855FractalCanopyAsymmetricMetadata get metadata => F0855FractalCanopyAsymmetricMetadata.instance;

  @override
  List<F0855FractalCanopyAsymmetricPreset> get presets => F0855FractalCanopyAsymmetricPresets.all;

  @override
  List<F0855FractalCanopyAsymmetricVariant> get variants => F0855FractalCanopyAsymmetricVariants.all;

  @override
  int get defaultDepth => 4;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('depth', defaultDepth);
  }
}
