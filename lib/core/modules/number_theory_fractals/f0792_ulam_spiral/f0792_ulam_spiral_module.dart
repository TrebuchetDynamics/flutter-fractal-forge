// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0792_ulam_spiral_presets.dart';
import 'f0792_ulam_spiral_variants.dart';
import 'f0792_ulam_spiral_metadata.dart';

/// Ulam Spiral — Number-Theory Fractals.
class F0792UlamSpiral extends CellularModule {
  F0792UlamSpiral()
      : super(
          id: 'f0792_ulam_spiral',
          shader: 'shaders/f0792_ulam_spiral_gpu.frag',
        );

  @override
  F0792UlamSpiralMetadata get metadata => F0792UlamSpiralMetadata.instance;

  @override
  List<F0792UlamSpiralPreset> get presets => F0792UlamSpiralPresets.all;

  @override
  List<F0792UlamSpiralVariant> get variants => F0792UlamSpiralVariants.all;

  @override
  int get defaultGenerations => 100;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
