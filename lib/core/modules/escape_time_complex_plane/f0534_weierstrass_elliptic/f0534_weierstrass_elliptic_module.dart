// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0534_weierstrass_elliptic_presets.dart';
import 'f0534_weierstrass_elliptic_variants.dart';
import 'f0534_weierstrass_elliptic_metadata.dart';

/// Weierstrass Elliptic — Escape-Time (Complex Plane).
class F0534WeierstrassElliptic extends EscapeTimeModule {
  F0534WeierstrassElliptic()
      : super(
          id: 'f0534_weierstrass_elliptic',
          shader: 'shaders/f0534_weierstrass_elliptic_gpu.frag',
        );

  @override
  F0534WeierstrassEllipticMetadata get metadata => F0534WeierstrassEllipticMetadata.instance;

  @override
  List<F0534WeierstrassEllipticPreset> get presets => F0534WeierstrassEllipticPresets.all;

  @override
  List<F0534WeierstrassEllipticVariant> get variants => F0534WeierstrassEllipticVariants.all;

  @override
  double get defaultPower => 2.0;

  @override
  double get defaultBailout => 50.0;

  @override
  int get defaultIterations => 300;

  @override
  DeepZoomStrategy get deepZoom => DeepZoomStrategy.perturbation;

  @override
  void configureShader(ShaderParams p) {
    p.setFloat('power', defaultPower);
    p.setFloat('bailout', defaultBailout);
    p.setInt('iterations', defaultIterations);
  }
}
