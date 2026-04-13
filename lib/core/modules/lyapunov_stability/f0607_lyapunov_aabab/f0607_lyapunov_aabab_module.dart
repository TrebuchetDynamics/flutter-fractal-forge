// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0607_lyapunov_aabab_presets.dart';
import 'f0607_lyapunov_aabab_variants.dart';
import 'f0607_lyapunov_aabab_metadata.dart';

/// Lyapunov AABAB — Lyapunov & Stability.
class F0607LyapunovAabab extends EscapeTimeModule {
  F0607LyapunovAabab()
      : super(
          id: 'f0607_lyapunov_aabab',
          shader: 'shaders/f0607_lyapunov_aabab_gpu.frag',
        );

  @override
  F0607LyapunovAababMetadata get metadata => F0607LyapunovAababMetadata.instance;

  @override
  List<F0607LyapunovAababPreset> get presets => F0607LyapunovAababPresets.all;

  @override
  List<F0607LyapunovAababVariant> get variants => F0607LyapunovAababVariants.all;

  @override
  double get defaultPower => 2.0;

  @override
  double get defaultBailout => 2.0;

  @override
  int get defaultIterations => 300;


  @override
  void configureShader(ShaderParams p) {
    p.setFloat('power', defaultPower);
    p.setFloat('bailout', defaultBailout);
    p.setInt('iterations', defaultIterations);
  }
}
