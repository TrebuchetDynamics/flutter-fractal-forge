// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0788_pascal_triangle_mod_3_presets.dart';
import 'f0788_pascal_triangle_mod_3_variants.dart';
import 'f0788_pascal_triangle_mod_3_metadata.dart';

/// Pascal Triangle Mod 3 — Number-Theory Fractals.
class F0788PascalTriangleMod3 extends CellularModule {
  F0788PascalTriangleMod3()
      : super(
          id: 'f0788_pascal_triangle_mod_3',
          shader: 'shaders/f0788_pascal_triangle_mod_3_gpu.frag',
        );

  @override
  F0788PascalTriangleMod3Metadata get metadata => F0788PascalTriangleMod3Metadata.instance;

  @override
  List<F0788PascalTriangleMod3Preset> get presets => F0788PascalTriangleMod3Presets.all;

  @override
  List<F0788PascalTriangleMod3Variant> get variants => F0788PascalTriangleMod3Variants.all;

  @override
  int get defaultGenerations => 100;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
