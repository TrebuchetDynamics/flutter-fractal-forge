import 'package:flutter_fractals/core/models/fractal_palette.dart';
import 'package:flutter_fractals/core/services/rendering/palette/palette_texture_cache.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('caches blended palette textures by quantized fractional index', () {
    final cache = PaletteTextureCache();
    addTearDown(cache.clear);
    final palettes = [
      FractalPalette(
        id: 'a',
        name: 'A',
        stops: const [
          FractalColorStop(position: 0, colorArgb: 0xFF000000),
          FractalColorStop(position: 1, colorArgb: 0xFFFFFFFF),
        ],
      ),
      FractalPalette(
        id: 'b',
        name: 'B',
        stops: const [
          FractalColorStop(position: 0, colorArgb: 0xFFFF0000),
          FractalColorStop(position: 1, colorArgb: 0xFF0000FF),
        ],
      ),
    ];

    final first = cache.paletteTextureForIndex(0, (i) => palettes[i]);
    final twoColor = cache.paletteTextureForIndex(
      0,
      (i) => palettes[i],
      colorCount: 2,
    );
    final blend = cache.paletteTextureForIndex(0.5, (i) => palettes[i]);
    final sameBlendBucket =
        cache.paletteTextureForIndex(0.501, (i) => palettes[i]);

    expect(first.width, PaletteTextureCache.textureWidth);
    expect(blend.height, 1);
    expect(identical(first, twoColor), isFalse);
    expect(identical(first, blend), isFalse);
    expect(identical(blend, sameBlendBucket), isTrue);
  });
}
