// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/ifs_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f1134_fractal_flame_v33_juliascope_presets.dart';
import 'f1134_fractal_flame_v33_juliascope_variants.dart';
import 'f1134_fractal_flame_v33_juliascope_metadata.dart';

/// Fractal Flame V33 JuliaScope — IFS & Geometric Construction.
class F1134FractalFlameV33Juliascope extends IFSModule {
  F1134FractalFlameV33Juliascope()
      : super(
          id: 'f1134_fractal_flame_v33_juliascope',
          shader: 'shaders/f1134_fractal_flame_v33_juliascope_gpu.frag',
        );

  @override
  F1134FractalFlameV33JuliascopeMetadata get metadata => F1134FractalFlameV33JuliascopeMetadata.instance;

  @override
  List<F1134FractalFlameV33JuliascopePreset> get presets => F1134FractalFlameV33JuliascopePresets.all;

  @override
  List<F1134FractalFlameV33JuliascopeVariant> get variants => F1134FractalFlameV33JuliascopeVariants.all;

  @override
  int get defaultIterations => 250000;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('iterations', defaultIterations);
  }
}
