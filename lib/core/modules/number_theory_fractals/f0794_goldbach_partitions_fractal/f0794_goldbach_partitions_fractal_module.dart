// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0794_goldbach_partitions_fractal_presets.dart';
import 'f0794_goldbach_partitions_fractal_variants.dart';
import 'f0794_goldbach_partitions_fractal_metadata.dart';

/// Goldbach Partitions Fractal — Number-Theory Fractals.
class F0794GoldbachPartitionsFractal extends CellularModule {
  F0794GoldbachPartitionsFractal()
      : super(
          id: 'f0794_goldbach_partitions_fractal',
          shader: 'shaders/f0794_goldbach_partitions_fractal_gpu.frag',
        );

  @override
  F0794GoldbachPartitionsFractalMetadata get metadata => F0794GoldbachPartitionsFractalMetadata.instance;

  @override
  List<F0794GoldbachPartitionsFractalPreset> get presets => F0794GoldbachPartitionsFractalPresets.all;

  @override
  List<F0794GoldbachPartitionsFractalVariant> get variants => F0794GoldbachPartitionsFractalVariants.all;

  @override
  int get defaultGenerations => 100;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
