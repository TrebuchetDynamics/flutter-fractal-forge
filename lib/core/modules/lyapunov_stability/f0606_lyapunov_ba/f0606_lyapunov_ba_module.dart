// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0606_lyapunov_ba_presets.dart';
import 'f0606_lyapunov_ba_variants.dart';
import 'f0606_lyapunov_ba_metadata.dart';

/// Lyapunov BA — Lyapunov & Stability.
class F0606LyapunovBa extends EscapeTimeModule {
  F0606LyapunovBa()
      : super(
          id: 'f0606_lyapunov_ba',
          shader: 'shaders/f0606_lyapunov_ba_gpu.frag',
        );

  @override
  F0606LyapunovBaMetadata get metadata => F0606LyapunovBaMetadata.instance;

  @override
  List<F0606LyapunovBaPreset> get presets => F0606LyapunovBaPresets.all;

  @override
  List<F0606LyapunovBaVariant> get variants => F0606LyapunovBaVariants.all;

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
