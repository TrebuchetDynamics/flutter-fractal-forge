// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/ifs_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f1124_fractal_flame_v23_blob_presets.dart';
import 'f1124_fractal_flame_v23_blob_variants.dart';
import 'f1124_fractal_flame_v23_blob_metadata.dart';

/// Fractal Flame V23 Blob — IFS & Geometric Construction.
class F1124FractalFlameV23Blob extends IFSModule {
  F1124FractalFlameV23Blob()
      : super(
          id: 'f1124_fractal_flame_v23_blob',
          shader: 'shaders/f1124_fractal_flame_v23_blob_gpu.frag',
        );

  @override
  F1124FractalFlameV23BlobMetadata get metadata => F1124FractalFlameV23BlobMetadata.instance;

  @override
  List<F1124FractalFlameV23BlobPreset> get presets => F1124FractalFlameV23BlobPresets.all;

  @override
  List<F1124FractalFlameV23BlobVariant> get variants => F1124FractalFlameV23BlobVariants.all;

  @override
  int get defaultIterations => 250000;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('iterations', defaultIterations);
  }
}
