// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/ifs_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0267_sierpinski_hexagon_ifs_presets.dart';
import 'f0267_sierpinski_hexagon_ifs_variants.dart';
import 'f0267_sierpinski_hexagon_ifs_metadata.dart';

/// Sierpinski Hexagon IFS — IFS & Geometric Construction.
class F0267SierpinskiHexagonIfs extends IFSModule {
  F0267SierpinskiHexagonIfs()
      : super(
          id: 'f0267_sierpinski_hexagon_ifs',
          shader: 'shaders/f0267_sierpinski_hexagon_ifs_gpu.frag',
        );

  @override
  F0267SierpinskiHexagonIfsMetadata get metadata => F0267SierpinskiHexagonIfsMetadata.instance;

  @override
  List<F0267SierpinskiHexagonIfsPreset> get presets => F0267SierpinskiHexagonIfsPresets.all;

  @override
  List<F0267SierpinskiHexagonIfsVariant> get variants => F0267SierpinskiHexagonIfsVariants.all;

  @override
  int get defaultIterations => 100000;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('iterations', defaultIterations);
  }
}
