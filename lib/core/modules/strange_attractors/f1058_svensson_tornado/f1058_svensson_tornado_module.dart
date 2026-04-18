// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f1058_svensson_tornado_presets.dart';
import 'f1058_svensson_tornado_variants.dart';
import 'f1058_svensson_tornado_metadata.dart';

/// Svensson Tornado — Strange Attractors.
class F1058SvenssonTornado extends AttractorModule {
  F1058SvenssonTornado()
      : super(
          id: 'f1058_svensson_tornado',
          shader: 'shaders/f1058_svensson_tornado_gpu.frag',
        );

  @override
  F1058SvenssonTornadoMetadata get metadata => F1058SvenssonTornadoMetadata.instance;

  @override
  List<F1058SvenssonTornadoPreset> get presets => F1058SvenssonTornadoPresets.all;

  @override
  List<F1058SvenssonTornadoVariant> get variants => F1058SvenssonTornadoVariants.all;

  @override
  int get defaultIterations => 200000;

  @override
  double get defaultStepSize => 0.01;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('iterations', defaultIterations);
    p.setFloat('stepSize', defaultStepSize);
  }
}
