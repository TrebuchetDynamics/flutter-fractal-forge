// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/ifs_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0266_sierpinski_pentagon_ifs_presets.dart';
import 'f0266_sierpinski_pentagon_ifs_variants.dart';
import 'f0266_sierpinski_pentagon_ifs_metadata.dart';

/// Sierpinski Pentagon IFS — IFS & Geometric Construction.
class F0266SierpinskiPentagonIfs extends IFSModule {
  F0266SierpinskiPentagonIfs()
      : super(
          id: 'f0266_sierpinski_pentagon_ifs',
          shader: 'shaders/f0266_sierpinski_pentagon_ifs_gpu.frag',
        );

  @override
  F0266SierpinskiPentagonIfsMetadata get metadata => F0266SierpinskiPentagonIfsMetadata.instance;

  @override
  List<F0266SierpinskiPentagonIfsPreset> get presets => F0266SierpinskiPentagonIfsPresets.all;

  @override
  List<F0266SierpinskiPentagonIfsVariant> get variants => F0266SierpinskiPentagonIfsVariants.all;

  @override
  int get defaultIterations => 100000;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('iterations', defaultIterations);
  }
}
