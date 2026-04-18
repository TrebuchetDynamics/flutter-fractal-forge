// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f1017_byl_s_self_reproducer_presets.dart';
import 'f1017_byl_s_self_reproducer_variants.dart';
import 'f1017_byl_s_self_reproducer_metadata.dart';

/// Byl's Self-Reproducer — Cellular & Stochastic.
class F1017BylSSelfReproducer extends CellularModule {
  F1017BylSSelfReproducer()
      : super(
          id: 'f1017_byl_s_self_reproducer',
          shader: 'shaders/f1017_byl_s_self_reproducer_gpu.frag',
        );

  @override
  F1017BylSSelfReproducerMetadata get metadata => F1017BylSSelfReproducerMetadata.instance;

  @override
  List<F1017BylSSelfReproducerPreset> get presets => F1017BylSSelfReproducerPresets.all;

  @override
  List<F1017BylSSelfReproducerVariant> get variants => F1017BylSSelfReproducerVariants.all;

  @override
  int get defaultGenerations => 256;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
