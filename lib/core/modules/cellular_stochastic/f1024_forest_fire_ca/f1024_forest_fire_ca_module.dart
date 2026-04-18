// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f1024_forest_fire_ca_presets.dart';
import 'f1024_forest_fire_ca_variants.dart';
import 'f1024_forest_fire_ca_metadata.dart';

/// Forest Fire CA — Cellular & Stochastic.
class F1024ForestFireCa extends CellularModule {
  F1024ForestFireCa()
      : super(
          id: 'f1024_forest_fire_ca',
          shader: 'shaders/f1024_forest_fire_ca_gpu.frag',
        );

  @override
  F1024ForestFireCaMetadata get metadata => F1024ForestFireCaMetadata.instance;

  @override
  List<F1024ForestFireCaPreset> get presets => F1024ForestFireCaPresets.all;

  @override
  List<F1024ForestFireCaVariant> get variants => F1024ForestFireCaVariants.all;

  @override
  int get defaultGenerations => 256;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
