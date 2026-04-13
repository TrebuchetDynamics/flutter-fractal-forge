// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0151_siegel_disk_julia_presets.dart';
import 'f0151_siegel_disk_julia_variants.dart';
import 'f0151_siegel_disk_julia_metadata.dart';

/// Siegel Disk Julia — Escape-Time (Complex Plane).
class F0151SiegelDiskJulia extends EscapeTimeModule {
  F0151SiegelDiskJulia()
      : super(
          id: 'f0151_siegel_disk_julia',
          shader: 'shaders/f0151_siegel_disk_julia_gpu.frag',
        );

  @override
  F0151SiegelDiskJuliaMetadata get metadata => F0151SiegelDiskJuliaMetadata.instance;

  @override
  List<F0151SiegelDiskJuliaPreset> get presets => F0151SiegelDiskJuliaPresets.all;

  @override
  List<F0151SiegelDiskJuliaVariant> get variants => F0151SiegelDiskJuliaVariants.all;

  @override
  double get defaultPower => 2.0;

  @override
  double get defaultBailout => 4.0;

  @override
  int get defaultIterations => 500;

  @override
  DeepZoomStrategy get deepZoom => DeepZoomStrategy.perturbation;

  @override
  void configureShader(ShaderParams p) {
    p.setFloat('power', defaultPower);
    p.setFloat('bailout', defaultBailout);
    p.setInt('iterations', defaultIterations);
  }
}
