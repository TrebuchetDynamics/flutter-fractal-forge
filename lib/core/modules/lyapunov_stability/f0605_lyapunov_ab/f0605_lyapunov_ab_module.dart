// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0605_lyapunov_ab_presets.dart';
import 'f0605_lyapunov_ab_variants.dart';
import 'f0605_lyapunov_ab_metadata.dart';

/// Lyapunov AB — Lyapunov & Stability.
class F0605LyapunovAb extends EscapeTimeModule {
  F0605LyapunovAb()
      : super(
          id: 'f0605_lyapunov_ab',
          shader: 'shaders/f0605_lyapunov_ab_gpu.frag',
        );

  @override
  F0605LyapunovAbMetadata get metadata => F0605LyapunovAbMetadata.instance;

  @override
  List<F0605LyapunovAbPreset> get presets => F0605LyapunovAbPresets.all;

  @override
  List<F0605LyapunovAbVariant> get variants => F0605LyapunovAbVariants.all;

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
