// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/ifs_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0264_barnsley_mutant_fern_presets.dart';
import 'f0264_barnsley_mutant_fern_variants.dart';
import 'f0264_barnsley_mutant_fern_metadata.dart';

/// Barnsley Mutant Fern — IFS & Geometric Construction.
class F0264BarnsleyMutantFern extends IFSModule {
  F0264BarnsleyMutantFern()
      : super(
          id: 'f0264_barnsley_mutant_fern',
          shader: 'shaders/f0264_barnsley_mutant_fern_gpu.frag',
        );

  @override
  F0264BarnsleyMutantFernMetadata get metadata => F0264BarnsleyMutantFernMetadata.instance;

  @override
  List<F0264BarnsleyMutantFernPreset> get presets => F0264BarnsleyMutantFernPresets.all;

  @override
  List<F0264BarnsleyMutantFernVariant> get variants => F0264BarnsleyMutantFernVariants.all;

  @override
  int get defaultIterations => 100000;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('iterations', defaultIterations);
  }
}
