// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/ifs_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0268_sierpinski_heptagon_ifs_presets.dart';
import 'f0268_sierpinski_heptagon_ifs_variants.dart';
import 'f0268_sierpinski_heptagon_ifs_metadata.dart';

/// Sierpinski Heptagon IFS — IFS & Geometric Construction.
class F0268SierpinskiHeptagonIfs extends IFSModule {
  F0268SierpinskiHeptagonIfs()
      : super(
          id: 'f0268_sierpinski_heptagon_ifs',
          shader: 'shaders/f0268_sierpinski_heptagon_ifs_gpu.frag',
        );

  @override
  F0268SierpinskiHeptagonIfsMetadata get metadata => F0268SierpinskiHeptagonIfsMetadata.instance;

  @override
  List<F0268SierpinskiHeptagonIfsPreset> get presets => F0268SierpinskiHeptagonIfsPresets.all;

  @override
  List<F0268SierpinskiHeptagonIfsVariant> get variants => F0268SierpinskiHeptagonIfsVariants.all;

  @override
  int get defaultIterations => 100000;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('iterations', defaultIterations);
  }
}
