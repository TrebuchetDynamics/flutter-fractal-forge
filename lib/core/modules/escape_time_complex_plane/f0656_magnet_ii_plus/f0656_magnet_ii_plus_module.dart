// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0656_magnet_ii_plus_presets.dart';
import 'f0656_magnet_ii_plus_variants.dart';
import 'f0656_magnet_ii_plus_metadata.dart';

/// Magnet II Plus — Escape-Time (Complex Plane).
class F0656MagnetIiPlus extends EscapeTimeModule {
  F0656MagnetIiPlus()
      : super(
          id: 'f0656_magnet_ii_plus',
          shader: 'shaders/f0656_magnet_ii_plus_gpu.frag',
        );

  @override
  F0656MagnetIiPlusMetadata get metadata => F0656MagnetIiPlusMetadata.instance;

  @override
  List<F0656MagnetIiPlusPreset> get presets => F0656MagnetIiPlusPresets.all;

  @override
  List<F0656MagnetIiPlusVariant> get variants => F0656MagnetIiPlusVariants.all;

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
