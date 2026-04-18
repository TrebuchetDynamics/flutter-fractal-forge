// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/ifs_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f1140_fractal_flame_v39_curl_presets.dart';
import 'f1140_fractal_flame_v39_curl_variants.dart';
import 'f1140_fractal_flame_v39_curl_metadata.dart';

/// Fractal Flame V39 Curl — IFS & Geometric Construction.
class F1140FractalFlameV39Curl extends IFSModule {
  F1140FractalFlameV39Curl()
      : super(
          id: 'f1140_fractal_flame_v39_curl',
          shader: 'shaders/f1140_fractal_flame_v39_curl_gpu.frag',
        );

  @override
  F1140FractalFlameV39CurlMetadata get metadata => F1140FractalFlameV39CurlMetadata.instance;

  @override
  List<F1140FractalFlameV39CurlPreset> get presets => F1140FractalFlameV39CurlPresets.all;

  @override
  List<F1140FractalFlameV39CurlVariant> get variants => F1140FractalFlameV39CurlVariants.all;

  @override
  int get defaultIterations => 250000;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('iterations', defaultIterations);
  }
}
