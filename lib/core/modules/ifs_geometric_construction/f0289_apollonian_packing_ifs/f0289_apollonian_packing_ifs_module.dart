// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/ifs_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0289_apollonian_packing_ifs_presets.dart';
import 'f0289_apollonian_packing_ifs_variants.dart';
import 'f0289_apollonian_packing_ifs_metadata.dart';

/// Apollonian Packing IFS — IFS & Geometric Construction.
class F0289ApollonianPackingIfs extends IFSModule {
  F0289ApollonianPackingIfs()
      : super(
          id: 'f0289_apollonian_packing_ifs',
          shader: 'shaders/f0289_apollonian_packing_ifs_gpu.frag',
        );

  @override
  F0289ApollonianPackingIfsMetadata get metadata => F0289ApollonianPackingIfsMetadata.instance;

  @override
  List<F0289ApollonianPackingIfsPreset> get presets => F0289ApollonianPackingIfsPresets.all;

  @override
  List<F0289ApollonianPackingIfsVariant> get variants => F0289ApollonianPackingIfsVariants.all;

  @override
  int get defaultIterations => 100000;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('iterations', defaultIterations);
  }
}
