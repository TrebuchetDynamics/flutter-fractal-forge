// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/ifs_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0269_sierpinski_octagon_ifs_presets.dart';
import 'f0269_sierpinski_octagon_ifs_variants.dart';
import 'f0269_sierpinski_octagon_ifs_metadata.dart';

/// Sierpinski Octagon IFS — IFS & Geometric Construction.
class F0269SierpinskiOctagonIfs extends IFSModule {
  F0269SierpinskiOctagonIfs()
      : super(
          id: 'f0269_sierpinski_octagon_ifs',
          shader: 'shaders/f0269_sierpinski_octagon_ifs_gpu.frag',
        );

  @override
  F0269SierpinskiOctagonIfsMetadata get metadata => F0269SierpinskiOctagonIfsMetadata.instance;

  @override
  List<F0269SierpinskiOctagonIfsPreset> get presets => F0269SierpinskiOctagonIfsPresets.all;

  @override
  List<F0269SierpinskiOctagonIfsVariant> get variants => F0269SierpinskiOctagonIfsVariants.all;

  @override
  int get defaultIterations => 100000;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('iterations', defaultIterations);
  }
}
