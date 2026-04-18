// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/l_system_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0836_peano_curve_original_1890_presets.dart';
import 'f0836_peano_curve_original_1890_variants.dart';
import 'f0836_peano_curve_original_1890_metadata.dart';

/// Peano Curve (Original 1890) — L-Systems & Space-Filling.
class F0836PeanoCurveOriginal1890 extends LSystemModule {
  F0836PeanoCurveOriginal1890()
      : super(
          id: 'f0836_peano_curve_original_1890',
          shader: 'shaders/f0836_peano_curve_original_1890_gpu.frag',
        );

  @override
  F0836PeanoCurveOriginal1890Metadata get metadata => F0836PeanoCurveOriginal1890Metadata.instance;

  @override
  List<F0836PeanoCurveOriginal1890Preset> get presets => F0836PeanoCurveOriginal1890Presets.all;

  @override
  List<F0836PeanoCurveOriginal1890Variant> get variants => F0836PeanoCurveOriginal1890Variants.all;

  @override
  int get defaultDepth => 4;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('depth', defaultDepth);
  }
}
