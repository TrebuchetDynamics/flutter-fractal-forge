import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import '../../integration_test/helpers/linux_audit_visual_metrics.dart';

void main() {
  test('uniform image has zero spatial detail and zero entropy', () {
    final image = img.Image(width: 320, height: 320);
    img.fill(image, color: img.ColorRgb8(64, 64, 64));
    final signals = linuxAuditVisualSignals(image);
    expect(signals['edgeEnergy'], 0);
    expect(signals['edgeDensity'], 0);
    expect(signals['luminanceEntropy'], 0);
    expect((signals['fingerprint']! as List).toSet().length, 1);
  });

  test('smooth gradient is distinguished from dense spatial noise', () {
    final gradient = img.Image(width: 64, height: 64);
    final noise = img.Image(width: 64, height: 64);
    final random = Random(1234);
    for (var y = 0; y < 64; y++) {
      for (var x = 0; x < 64; x++) {
        final g = x * 4;
        final n = random.nextBool() ? 255 : 0;
        gradient.setPixelRgb(x, y, g, g, g);
        noise.setPixelRgb(x, y, n, n, n);
      }
    }
    final a = linuxAuditVisualSignals(gradient);
    final b = linuxAuditVisualSignals(noise);
    expect(a['edgeDensity'], 0);
    expect(b['edgeDensity'], greaterThan(.45));
    expect(a['luminanceEntropy'], greaterThan(3));
    expect((a['fingerprint']! as List).length, 256);
    expect(a['fingerprint'], isNot(b['fingerprint']));
  });
}
