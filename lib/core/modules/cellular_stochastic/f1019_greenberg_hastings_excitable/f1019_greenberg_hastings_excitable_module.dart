// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f1019_greenberg_hastings_excitable_presets.dart';
import 'f1019_greenberg_hastings_excitable_variants.dart';
import 'f1019_greenberg_hastings_excitable_metadata.dart';

/// Greenberg-Hastings Excitable — Cellular & Stochastic.
class F1019GreenbergHastingsExcitable extends CellularModule {
  F1019GreenbergHastingsExcitable()
      : super(
          id: 'f1019_greenberg_hastings_excitable',
          shader: 'shaders/f1019_greenberg_hastings_excitable_gpu.frag',
        );

  @override
  F1019GreenbergHastingsExcitableMetadata get metadata => F1019GreenbergHastingsExcitableMetadata.instance;

  @override
  List<F1019GreenbergHastingsExcitablePreset> get presets => F1019GreenbergHastingsExcitablePresets.all;

  @override
  List<F1019GreenbergHastingsExcitableVariant> get variants => F1019GreenbergHastingsExcitableVariants.all;

  @override
  int get defaultGenerations => 256;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
