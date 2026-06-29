import 'package:flutter_fractals/core/services/rendering/palette_service.dart';
import 'package:flutter_fractals/core/services/rendering/palette_shader_adapter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
      'returns cached 1x1 fallback sampler when palette service is unavailable',
      () {
    try {
      PaletteService.instance.dispose();
    } catch (_) {
      // Already unavailable.
    }

    final first = PaletteShaderAdapter.instance.samplerPaletteTexture(0);
    final second = PaletteShaderAdapter.instance.samplerPaletteTexture(1);

    expect(first.width, 1);
    expect(first.height, 1);
    expect(identical(first, second), isTrue);
  });
}
