// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0759_ford_circles_apollonian_presets.dart';
import 'f0759_ford_circles_apollonian_variants.dart';
import 'f0759_ford_circles_apollonian_metadata.dart';

/// Ford Circles Apollonian — Number-Theory Fractals.
class F0759FordCirclesApollonian extends CellularModule {
  F0759FordCirclesApollonian()
      : super(
          id: 'f0759_ford_circles_apollonian',
          shader: 'shaders/f0759_ford_circles_apollonian_gpu.frag',
        );

  @override
  F0759FordCirclesApollonianMetadata get metadata => F0759FordCirclesApollonianMetadata.instance;

  @override
  List<F0759FordCirclesApollonianPreset> get presets => F0759FordCirclesApollonianPresets.all;

  @override
  List<F0759FordCirclesApollonianVariant> get variants => F0759FordCirclesApollonianVariants.all;

  @override
  int get defaultGenerations => 100;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
