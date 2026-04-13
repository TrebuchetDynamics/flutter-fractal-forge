// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0620_lyapunov_baaba_presets.dart';
import 'f0620_lyapunov_baaba_variants.dart';
import 'f0620_lyapunov_baaba_metadata.dart';

/// Lyapunov BAABA — Lyapunov & Stability.
class F0620LyapunovBaaba extends EscapeTimeModule {
  F0620LyapunovBaaba()
      : super(
          id: 'f0620_lyapunov_baaba',
          shader: 'shaders/f0620_lyapunov_baaba_gpu.frag',
        );

  @override
  F0620LyapunovBaabaMetadata get metadata => F0620LyapunovBaabaMetadata.instance;

  @override
  List<F0620LyapunovBaabaPreset> get presets => F0620LyapunovBaabaPresets.all;

  @override
  List<F0620LyapunovBaabaVariant> get variants => F0620LyapunovBaabaVariants.all;

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
