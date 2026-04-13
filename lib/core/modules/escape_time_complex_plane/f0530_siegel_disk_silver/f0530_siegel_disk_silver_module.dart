// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0530_siegel_disk_silver_presets.dart';
import 'f0530_siegel_disk_silver_variants.dart';
import 'f0530_siegel_disk_silver_metadata.dart';

/// Siegel Disk (silver) — Escape-Time (Complex Plane).
class F0530SiegelDiskSilver extends EscapeTimeModule {
  F0530SiegelDiskSilver()
      : super(
          id: 'f0530_siegel_disk_silver',
          shader: 'shaders/f0530_siegel_disk_silver_gpu.frag',
        );

  @override
  F0530SiegelDiskSilverMetadata get metadata => F0530SiegelDiskSilverMetadata.instance;

  @override
  List<F0530SiegelDiskSilverPreset> get presets => F0530SiegelDiskSilverPresets.all;

  @override
  List<F0530SiegelDiskSilverVariant> get variants => F0530SiegelDiskSilverVariants.all;

  @override
  double get defaultPower => 2.0;

  @override
  double get defaultBailout => 50.0;

  @override
  int get defaultIterations => 300;

  @override
  DeepZoomStrategy get deepZoom => DeepZoomStrategy.perturbation;

  @override
  void configureShader(ShaderParams p) {
    p.setFloat('power', defaultPower);
    p.setFloat('bailout', defaultBailout);
    p.setInt('iterations', defaultIterations);
  }
}
