// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0789_pascal_triangle_mod_5_presets.dart';
import 'f0789_pascal_triangle_mod_5_variants.dart';
import 'f0789_pascal_triangle_mod_5_metadata.dart';

/// Pascal Triangle Mod 5 — Number-Theory Fractals.
class F0789PascalTriangleMod5 extends CellularModule {
  F0789PascalTriangleMod5()
      : super(
          id: 'f0789_pascal_triangle_mod_5',
          shader: 'shaders/f0789_pascal_triangle_mod_5_gpu.frag',
        );

  @override
  F0789PascalTriangleMod5Metadata get metadata => F0789PascalTriangleMod5Metadata.instance;

  @override
  List<F0789PascalTriangleMod5Preset> get presets => F0789PascalTriangleMod5Presets.all;

  @override
  List<F0789PascalTriangleMod5Variant> get variants => F0789PascalTriangleMod5Variants.all;

  @override
  int get defaultGenerations => 100;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
