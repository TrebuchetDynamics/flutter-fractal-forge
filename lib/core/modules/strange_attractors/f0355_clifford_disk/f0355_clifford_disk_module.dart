// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0355_clifford_disk_presets.dart';
import 'f0355_clifford_disk_variants.dart';
import 'f0355_clifford_disk_metadata.dart';

/// Clifford Disk — Strange Attractors.
class F0355CliffordDisk extends AttractorModule {
  F0355CliffordDisk()
      : super(
          id: 'f0355_clifford_disk',
          shader: 'shaders/f0355_clifford_disk_gpu.frag',
        );

  @override
  F0355CliffordDiskMetadata get metadata => F0355CliffordDiskMetadata.instance;

  @override
  List<F0355CliffordDiskPreset> get presets => F0355CliffordDiskPresets.all;

  @override
  List<F0355CliffordDiskVariant> get variants => F0355CliffordDiskVariants.all;

  @override
  int get defaultIterations => 150000;

  @override
  double get defaultStepSize => 0.01;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('iterations', defaultIterations);
    p.setFloat('stepSize', defaultStepSize);
  }
}
