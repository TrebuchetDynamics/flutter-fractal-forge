// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0659_magnet_v_presets.dart';
import 'f0659_magnet_v_variants.dart';
import 'f0659_magnet_v_metadata.dart';

/// Magnet V — Escape-Time (Complex Plane).
class F0659MagnetV extends EscapeTimeModule {
  F0659MagnetV()
      : super(
          id: 'f0659_magnet_v',
          shader: 'shaders/f0659_magnet_v_gpu.frag',
        );

  @override
  F0659MagnetVMetadata get metadata => F0659MagnetVMetadata.instance;

  @override
  List<F0659MagnetVPreset> get presets => F0659MagnetVPresets.all;

  @override
  List<F0659MagnetVVariant> get variants => F0659MagnetVVariants.all;

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
