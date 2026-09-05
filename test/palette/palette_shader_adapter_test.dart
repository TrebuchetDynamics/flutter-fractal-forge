import 'dart:ui' as ui;

import 'package:flutter_fractals/core/services/rendering/palette/palette_service.dart';
import 'package:flutter_fractals/core/services/rendering/palette/palette_shader_adapter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
      'returns cached readable gradient fallback sampler when palette service is unavailable',
      () async {
    try {
      PaletteService.instance.dispose();
    } catch (_) {
      // Already unavailable.
    }

    final first = PaletteShaderAdapter.instance.samplerPaletteTexture(0);
    final second = PaletteShaderAdapter.instance.samplerPaletteTexture(1);

    expect(first.width, 256);
    expect(first.height, 1);
    expect(identical(first, second), isTrue);
    final bytes = (await first.toByteData(format: ui.ImageByteFormat.rawRgba))!
        .buffer
        .asUint8List();
    expect(bytes[0], lessThan(8));
    expect(bytes[255 * 4], greaterThan(247));
    expect(bytes[128 * 4], inInclusiveRange(120, 136));
    for (var i = 3; i < bytes.length; i += 4) {
      expect(bytes[i], 255);
    }
  });
}
