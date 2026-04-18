// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f1001_slow_blob_b367_s23478_presets.dart';
import 'f1001_slow_blob_b367_s23478_variants.dart';
import 'f1001_slow_blob_b367_s23478_metadata.dart';

/// Slow Blob (B367/S23478) — Cellular & Stochastic.
class F1001SlowBlobB367S23478 extends CellularModule {
  F1001SlowBlobB367S23478()
      : super(
          id: 'f1001_slow_blob_b367_s23478',
          shader: 'shaders/f1001_slow_blob_b367_s23478_gpu.frag',
        );

  @override
  F1001SlowBlobB367S23478Metadata get metadata => F1001SlowBlobB367S23478Metadata.instance;

  @override
  List<F1001SlowBlobB367S23478Preset> get presets => F1001SlowBlobB367S23478Presets.all;

  @override
  List<F1001SlowBlobB367S23478Variant> get variants => F1001SlowBlobB367S23478Variants.all;

  @override
  int get defaultGenerations => 256;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
