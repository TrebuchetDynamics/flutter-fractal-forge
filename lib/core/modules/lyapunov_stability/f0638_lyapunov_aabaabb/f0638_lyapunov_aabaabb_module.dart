// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0638_lyapunov_aabaabb_presets.dart';
import 'f0638_lyapunov_aabaabb_variants.dart';
import 'f0638_lyapunov_aabaabb_metadata.dart';

/// Lyapunov AABAABB — Lyapunov & Stability.
class F0638LyapunovAabaabb extends EscapeTimeModule {
  F0638LyapunovAabaabb()
      : super(
          id: 'f0638_lyapunov_aabaabb',
          shader: 'shaders/f0638_lyapunov_aabaabb_gpu.frag',
        );

  @override
  F0638LyapunovAabaabbMetadata get metadata => F0638LyapunovAabaabbMetadata.instance;

  @override
  List<F0638LyapunovAabaabbPreset> get presets => F0638LyapunovAabaabbPresets.all;

  @override
  List<F0638LyapunovAabaabbVariant> get variants => F0638LyapunovAabaabbVariants.all;

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
