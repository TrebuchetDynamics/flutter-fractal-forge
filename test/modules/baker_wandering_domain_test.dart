import 'dart:ui' as ui;
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:flutter_fractals/features/renderer/diagnostics/render_audit_metrics.dart';
import '../helpers/render_test_shader.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test(
      'Baker default and alternate views retain structure at full iteration depth',
      () async {
    const asset =
        'shaders/escape_time_family/transcendental_maps/baker_wandering_domain_gpu.frag';
    final program = await ui.FragmentProgram.fromAsset(asset);
    for (final zoom in [1.0, 0.75]) {
      for (final iterations in [120.0, 200.0]) {
        final bytes = await renderTestShaderFrame(
            program: program,
            shaderAsset: asset,
            width: 96,
            height: 96,
            uniforms: [0, 96, 96, 0, 0, zoom, iterations, 8, 2, 0, .5, .35]);
        final image = img.Image.fromBytes(
            width: 96, height: 96, bytes: bytes.buffer, numChannels: 4);
        final metrics = RenderAuditMetrics.fromImage(image);
        expect(metrics.verdict, 'pass',
            reason: 'zoom=$zoom iterations=$iterations');
        expect(metrics.uniqueRgbColors, greaterThan(32));
        expect(metrics.luminanceStdDev, greaterThan(5));
      }
    }
  });
}
