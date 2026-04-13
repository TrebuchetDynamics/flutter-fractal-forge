// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/ifs_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0263_barnsley_fern_variant_thistle_presets.dart';
import 'f0263_barnsley_fern_variant_thistle_variants.dart';
import 'f0263_barnsley_fern_variant_thistle_metadata.dart';

/// Barnsley Fern (Variant Thistle) — IFS & Geometric Construction.
class F0263BarnsleyFernVariantThistle extends IFSModule {
  F0263BarnsleyFernVariantThistle()
      : super(
          id: 'f0263_barnsley_fern_variant_thistle',
          shader: 'shaders/f0263_barnsley_fern_variant_thistle_gpu.frag',
        );

  @override
  F0263BarnsleyFernVariantThistleMetadata get metadata => F0263BarnsleyFernVariantThistleMetadata.instance;

  @override
  List<F0263BarnsleyFernVariantThistlePreset> get presets => F0263BarnsleyFernVariantThistlePresets.all;

  @override
  List<F0263BarnsleyFernVariantThistleVariant> get variants => F0263BarnsleyFernVariantThistleVariants.all;

  @override
  int get defaultIterations => 100000;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('iterations', defaultIterations);
  }
}
