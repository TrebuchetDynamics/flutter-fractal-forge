// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0662_magnet_inverse_i_presets.dart';
import 'f0662_magnet_inverse_i_variants.dart';
import 'f0662_magnet_inverse_i_metadata.dart';

/// Magnet-Inverse I — Escape-Time (Complex Plane).
class F0662MagnetInverseI extends EscapeTimeModule {
  F0662MagnetInverseI()
      : super(
          id: 'f0662_magnet_inverse_i',
          shader: 'shaders/f0662_magnet_inverse_i_gpu.frag',
        );

  @override
  F0662MagnetInverseIMetadata get metadata => F0662MagnetInverseIMetadata.instance;

  @override
  List<F0662MagnetInverseIPreset> get presets => F0662MagnetInverseIPresets.all;

  @override
  List<F0662MagnetInverseIVariant> get variants => F0662MagnetInverseIVariants.all;

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
