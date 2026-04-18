// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f1014_wireworld_presets.dart';
import 'f1014_wireworld_variants.dart';
import 'f1014_wireworld_metadata.dart';

/// Wireworld — Cellular & Stochastic.
class F1014Wireworld extends CellularModule {
  F1014Wireworld()
      : super(
          id: 'f1014_wireworld',
          shader: 'shaders/f1014_wireworld_gpu.frag',
        );

  @override
  F1014WireworldMetadata get metadata => F1014WireworldMetadata.instance;

  @override
  List<F1014WireworldPreset> get presets => F1014WireworldPresets.all;

  @override
  List<F1014WireworldVariant> get variants => F1014WireworldVariants.all;

  @override
  int get defaultGenerations => 256;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
