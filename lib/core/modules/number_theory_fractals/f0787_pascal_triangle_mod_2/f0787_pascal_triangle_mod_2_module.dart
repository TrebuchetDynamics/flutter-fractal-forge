// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0787_pascal_triangle_mod_2_presets.dart';
import 'f0787_pascal_triangle_mod_2_variants.dart';
import 'f0787_pascal_triangle_mod_2_metadata.dart';

/// Pascal Triangle Mod 2 — Number-Theory Fractals.
class F0787PascalTriangleMod2 extends CellularModule {
  F0787PascalTriangleMod2()
      : super(
          id: 'f0787_pascal_triangle_mod_2',
          shader: 'shaders/f0787_pascal_triangle_mod_2_gpu.frag',
        );

  @override
  F0787PascalTriangleMod2Metadata get metadata => F0787PascalTriangleMod2Metadata.instance;

  @override
  List<F0787PascalTriangleMod2Preset> get presets => F0787PascalTriangleMod2Presets.all;

  @override
  List<F0787PascalTriangleMod2Variant> get variants => F0787PascalTriangleMod2Variants.all;

  @override
  int get defaultGenerations => 100;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
