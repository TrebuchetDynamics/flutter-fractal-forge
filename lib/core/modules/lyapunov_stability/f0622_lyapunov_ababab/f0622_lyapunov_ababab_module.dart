// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0622_lyapunov_ababab_presets.dart';
import 'f0622_lyapunov_ababab_variants.dart';
import 'f0622_lyapunov_ababab_metadata.dart';

/// Lyapunov ABABAB — Lyapunov & Stability.
class F0622LyapunovAbabab extends EscapeTimeModule {
  F0622LyapunovAbabab()
      : super(
          id: 'f0622_lyapunov_ababab',
          shader: 'shaders/f0622_lyapunov_ababab_gpu.frag',
        );

  @override
  F0622LyapunovAbababMetadata get metadata => F0622LyapunovAbababMetadata.instance;

  @override
  List<F0622LyapunovAbababPreset> get presets => F0622LyapunovAbababPresets.all;

  @override
  List<F0622LyapunovAbababVariant> get variants => F0622LyapunovAbababVariants.all;

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
