// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0328_wireworld_presets.dart';
import 'f0328_wireworld_variants.dart';
import 'f0328_wireworld_metadata.dart';

/// Wireworld — Cellular & Stochastic.
class F0328Wireworld extends CellularModule {
  F0328Wireworld()
      : super(
          id: 'f0328_wireworld',
          shader: 'shaders/f0328_wireworld_gpu.frag',
        );

  @override
  F0328WireworldMetadata get metadata => F0328WireworldMetadata.instance;

  @override
  List<F0328WireworldPreset> get presets => F0328WireworldPresets.all;

  @override
  List<F0328WireworldVariant> get variants => F0328WireworldVariants.all;

  @override
  int get defaultGenerations => 256;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
