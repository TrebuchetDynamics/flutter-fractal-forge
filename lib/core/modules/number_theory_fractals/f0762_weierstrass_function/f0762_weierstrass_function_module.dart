// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0762_weierstrass_function_presets.dart';
import 'f0762_weierstrass_function_variants.dart';
import 'f0762_weierstrass_function_metadata.dart';

/// Weierstrass Function — Number-Theory Fractals.
class F0762WeierstrassFunction extends CellularModule {
  F0762WeierstrassFunction()
      : super(
          id: 'f0762_weierstrass_function',
          shader: 'shaders/f0762_weierstrass_function_gpu.frag',
        );

  @override
  F0762WeierstrassFunctionMetadata get metadata => F0762WeierstrassFunctionMetadata.instance;

  @override
  List<F0762WeierstrassFunctionPreset> get presets => F0762WeierstrassFunctionPresets.all;

  @override
  List<F0762WeierstrassFunctionVariant> get variants => F0762WeierstrassFunctionVariants.all;

  @override
  int get defaultGenerations => 100;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
